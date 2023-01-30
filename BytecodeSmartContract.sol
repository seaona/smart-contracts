// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// RUNTIME CODE
// always return 42, no matter what func you call
// use op code RETURN

/* 
mstore(p, v) - store v at memory p to p + 32

PUSH1 0x2a //v
PUSH1 0 //p
MSTORE


return(p, s) - end execution and return data from memory p to p + s

Return 32 bytes from memory:
PUSH1 0X20
PUSH1 0
RETURN
*/

// Runtime bytecode - return 42
// 602a60005260206000f3


// CREATION CODE: when the contract is deployed for the first time it will executre the creation code
/* Store run time code to memory 0

602a60005260206000f3

PUSH10 0x602a60005260206000f3
PUSH1 0
MSTORE

0x000000000000000000000000602a60005260206000f3
Runtime code is stored as 32 bytes in memory
Return 10 bytes from memory starting at offset 22

PUSH1 0x0a //10
PUSH1 0x16 //22
RETURN

*/

// FACTORY CONTRACT


contract Factory {
    event Log(address addr);

    function deploy() external {
        bytes memory bytecode = hex"69602a60005260206000f3600052600a6016f3";
        address addr;
        assembly {
            addr := create(0, add(bytecode, 0x20), 0x13) //amount ETH, memory position, length of bytecode (32/2)
        }

        require(addr != address(0), "deploy failed");

        emit Log(addr);
    }
}

interface IContract {
    function getMeaningOfLife() external view returns (uint);
}
