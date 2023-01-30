// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// Transparent upgradeable proxy pattern
// storage for implementation and admin
// separate user / admin interfaces

contract CounterV1 {
    // we need to add these 2 lines, so the storage layout matches with the Buggy Proxy
    uint public count;

    function inc() external {
        count += 1;
    }
}

contract CounterV2 {
    uint public count;

    function inc() external {
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}

contract Proxy {
    // open zeppelin upgreadable proxy
    bytes32 public constant IMPLEMENTATION_SLOT = bytes32(
        uint(keccak256("eip1967.proxy.implementation")) - 1
    );

    // if we use -1 we don't know the pre-image that was used to compute the admin slot
    // for avoiding collision attacks
    bytes32 public constant ADMIN_SLOT = bytes32(
        uint(keccak256("eip1967.proxy.admin")) - 1
    );

    constructor() {
        _setAdmin(msg.sender);
    }

    function _delegate(address _implementation) private {
        assembly {

            // (1) copy incoming call data into memory at 0 position
            calldatacopy(0, 0, calldatasize())

            // (2) forward call to logic contract
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // (3) retrieve return data
            returndatacopy(0, 0, returndatasize())

            // (4) forward return data back to caller
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
            }
    }

    fallback() external payable {
        // the fallback cannot return any data, so we cannot get the count from the counter
        _delegate(_getImplementation());
    }

    receive() external payable {
        _delegate(_getImplementation());
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == _getAdmin(), "not admin");

        _setImplementation(_implementation);
    }

    function _getAdmin() private view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;

    }

    function _setAdmin(address _admin) private {
        require(_admin != address(0), "admin is 0 address");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

    function _getImplementation() private view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;

    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0, "not a contract");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }

    function admin() external view returns (address) {
        return _getAdmin();
    }

    function implementation() external view returns (address) {
        return _getImplementation();
    }

}

library StorageSlot {
    // the storage of a solidity smart contract is an array of length 2 **256
    // on each slot we can store up to 32 bytes
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

contract TestSlot {
    bytes32 public constant SLOT = keccak256("TEST SLOT");

    function getSlot() external view returns (address) {
        return StorageSlot.getAddressSlot(SLOT).value;
    }

    function writeSlot(address addr) external {
        StorageSlot.getAddressSlot(SLOT).value = addr;
    }
}
