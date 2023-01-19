// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;


interface IERC721 {
    function transferFrom (
        address from,
        address to,
        uint nftId
    ) external;
}

contract EnglishAuction {
    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address highestBidder, uint amount);

    IERC721 public immutable nft;
    uint public immutable nftId;

    address payable public immutable seller;

    //it can store up to 100 years from now
    uint32 public endAt;
    bool public started;
    bool public ended;

    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public bids;

    constructor(
        address _nft,
        uint _nftId,
        uint _startingBid
    ) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        highestBid = _startingBid;
    }

    function start() external {
        require(msg.sender == seller, "not seller");
        require(!started, "started");

        started = true;
        // since block.timestamp is a uint256 we have to cast it to uint32
        endAt = uint32(block.timestamp + 60); //60 secs, as we don't want to wait
        nft.transferFrom(seller, address(this), nftId);

        emit Start();
    }

    function bid() external payable {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value not enough");

        if(highestBidder != address(0)) {
            bids[highestBidder] += highestBid;  // keeps track all the bids that were outbidded
        }
       
        highestBid = msg.value;
        highestBidder = msg.sender;

        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external {
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0; //to protect from re-entrancy
        payable(msg.sender).transfer(bal);
        emit Withdraw(msg.sender, bal);
    }

    function end() external {
        // anyone can call it. So the owner does not keep the auction open, and the bidder have the fund locked
        require(started, "not started");
        require(!ended, "not ended");
        require(block.timestamp >= endAt, "not ended");

        ended = true;

        if(highestBidder != address(0)) {
            nft.transferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.transferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }

}
