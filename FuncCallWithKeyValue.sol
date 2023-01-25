// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FunctionCallWithKeyValues {
    function someFuncWithManyInputs(
        uint x, uint y, uint z, address a, bool b, string memory c
    ) public pure returns (uint) {
    
    }

    function callFunc() external pure returns (uint) {
        return someFuncWithManyInputs(1, 2, 3, address(0), true, "c");
    }

    function callFuncWithKeyValues() external pure returns (uint) {
        return someFuncWithManyInputs({
            a: address(0),
            b: true,
            c: "c",
            x: 1,
            y: 2,
            z: 3

        });
    }
}
