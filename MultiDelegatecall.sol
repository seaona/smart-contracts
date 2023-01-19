// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// if we want to preserve the context i.e. msg.sender, we use delegatecall
// alice -- multi call --- call --- test (msg.sender = multi call

contract MultiDelegatecall {
    error DelegatecallFailed(); // custome error from solidity 0.8

    function multiDelegatecall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results)
    {
        results= new bytes[](data.length);
        for (uint i; i < data.length; i++) {
            (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
            if(!ok) {
                revert  DelegatecallFailed();
            }
            results[i] = res;
        }
    }    
}

contract TestMultiDelegatecall is MultiDelegatecall {
    event Log(address caller, string func, uint i);

    function func1(uint x, uint y) external {
        emit Log(msg.sender, "func1", x+y);
    }

     function func2() external returns (uint) {
        emit Log(msg.sender, "func2", 2);
        return 111;
    }

    // WARNING: UNSAFE, if we use multidelegate call and call mint x3 in one func call, the msg.value will be 1 but
    // the balance increment will be x3
    mapping(address => uint) public balanceOf;

    function mint() external payable {
        balanceOf[msg.sender] += msg.value;
    }
}

contract Helper {
    function getFunc1Data(uint x, uint y) external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecall.func1.selector, x, y);
    }

     function getFunc2Data() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecall.func2.selector);
    }

    function getMintData() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecall.mint.selector);
    }
}
