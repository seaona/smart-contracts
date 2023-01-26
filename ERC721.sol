// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 {
    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint tokenId, bytes calldata data) external returns (bytes4);
}

contract ERC721 is IERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    mapping(uint => address) internal _ownerOf;
    mapping(address => uint) internal _balanceOf;
    mapping(uint => address) internal _approvals;
    mapping(address => mapping(address => bool)) public override isApprovedForAll;

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function balanceOf(address owner) external override view returns (uint256) {
        require(owner != address(0), "owner = zero address");
        return _balanceOf[owner];
    }

    function ownerOf(uint256 tokenId) external override view returns (address owner) {
        owner = _ownerOf[tokenId];
        require(owner != address(0), "owner = zero address");
    }

    function _isApprovedOrOwner(address owner, address spender, uint tokenId) internal view returns (bool) {
        return(
            spender == owner ||
            isApprovedForAll[owner][spender] ||
            spender == _approvals[tokenId]
        );
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external override payable {
        transferFrom(from, to, tokenId);
        require(
            to.code.length == 0 ||
            IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) == 
            IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external override payable {
        transferFrom(from, to, tokenId);
        require(
            to.code.length == 0 ||
            IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, "") == 
            IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function transferFrom(address from, address to, uint256 tokenId) public override payable {
        require(from == _ownerOf[tokenId], "from != owner");
        require(to != address(0), "to = zero address");
        require(_isApprovedOrOwner(from, msg.sender, tokenId), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[tokenId] = to;

        delete _approvals[tokenId];

        emit Transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external override payable {
        address owner = _ownerOf[tokenId];
        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "not authorized"
        );
        _approvals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) override external {
        isApprovedForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 tokenId) external override view returns (address) {
        require(_ownerOf[tokenId] != address(0), "token doesn't exist");
        return _approvals[tokenId];
    }

    function _mint(address to, uint tokenId) internal {
        require(to != address(0), "to = zero address");
        require(_ownerOf[tokenId] == address(0), "token exists");

        _balanceOf[to]++;
        _ownerOf[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }


    function _burn(uint tokenId) internal {
        address owner = _ownerOf[tokenId];
        require(owner != address(0), "tooken does not exist");

        _balanceOf[owner]--;
        delete _ownerOf[tokenId];
        delete _approvals[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }
}

contract MyNFT is ERC721 {
    function mint(address to, uint tokenId) external {
        _mint(to, tokenId);
    }

    function burn(uint tokenId) external {
        require(msg.sender == _ownerOf[tokenId], "not owner");
        _burn(tokenId);
    }
}
