// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


// ex 8 --- 2**3 = 3
// ex 9 --- 2**3 + 1 = 3
// ex 16 --- 2**4 = 4
contract MostSignificantBit {
    function findMostSignificantBit(uint x) external pure returns(uint8 r) {
        // find the middle number
        // x >= 2 ** 128 ?
        if(x >= 2 ** 128) {
            x >>= 128;
            r += 128;
        }

        // x >= 2 ** 64 ?
        if(x >= 2 ** 64) {
            x >>= 64;
            r += 64;
        }

        // x >= 2 ** 32 ?
        if(x >= 2 ** 32) {
            x >>= 32;
            r += 32;
        }

        // x >= 2 ** 16 ?
        if(x >= 2 ** 16) {
            x >>= 16;
            r += 16;
        }

        // x >= 2 ** 8 ?
        if(x >= 2 ** 8) {
            x >>= 8;
            r += 8;
        }

        // x >= 2 ** 4 ?
        if(x >= 2 ** 4) {
            x >>= 4;
            r += 4;
        }

        // x >= 2 ** 2 ?
        if(x >= 2 ** 2) {
            x >>= 2;
            r += 2;
        }

        // x >= 2 ** 1 ?
        if(x >= 2) {
            r += 1;
        }
    }
}
