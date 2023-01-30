// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract CounterV1 {
    // we need to add these 2 lines, so the storage layout matches with the Buggy Proxy
    address public implementation;
    address public admin;


    uint public count;

    function inc() external {
        count += 1;
    }
}

contract CounterV2 {
    address public implementation;
    address public admin;
    uint public count;

    function inc() external {
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}

contract BuggyProxy {
    address public implementation;
    address public admin;

    constructor() {
        admin = msg.sender;
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
        _delegate(implementation);
    }

    receive() external payable {
        _delegate(implementation);
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == admin, "not admin");

        implementation = _implementation;
    }
}
