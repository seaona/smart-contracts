// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// wrong way to build upgradable proxy

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

    function _delegate() private {
        (bool ok, bytes memory res) = implementation.delegatecall(msg.data);
        require(ok, "delegate call failed");
    }

    fallback() external payable {
        // the fallback cannot return any data, so we cannot get the count from the counter
        _delegate();
    }

    receive() external payable {
        _delegate();
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == admin, "not admin");

        implementation = _implementation;
    }
}
