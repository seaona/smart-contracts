// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;


interface IERC721 {
    function transferFrom (
        address _from,
        address _to,
        uint _nftId
    ) external;
}

contract DutchAuction {
    uint private constant DURATION = 7 days;

    IERC721 public immutable nft;
    uint public immutable nftId;

    address payable public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable expiresAt;
    uint public immutable discountRate;

    constructor(
        uint _startingPrice,
        uint _discountRate,
        address _nft,
        uint _nftId
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;

        require(
            // for immutable variables, the state variable cannot be accessed inside the constructor
            // so we access the variable from the constructor params
            _startingPrice >= _discountRate * DURATION,
            "starting price is less than discount"
        );

        nft = IERC721(_nft);
        nftId = _nftId;

    }

    function getPrice() public view returns (uint) {
        uint timeElapsed = block.timestamp - startAt;
        uint discount = discountRate * timeElapsed;
        
        return startingPrice - discount;
    }

    function buy() external payable {
        require(block.timestamp < expiresAt, "auction expired");

        uint price = getPrice();
        require(msg.value >= price, "ETH less than price");

        nft.transferFrom(seller, msg.sender, nftId);
        uint refund = msg.value - price;

        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }

        // send all of the ETH to seller and close the auction, by deleting the contract
        self.destruct(seller);
    }
}
