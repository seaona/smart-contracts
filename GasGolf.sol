// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// start gas 58545

contract GasGolf {
    uint public total;

    function sumIfEvenAndLessThan99(uint[] memory nums) external {
        for (uint i = 0; i < nums.length; i += 1) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if(isEven && isLessThan99) {
                total += nums[i];
            }
        }
    }
 
}

// Gas Optimized
// change memory for calldata
// access to a memory variable instead of state variable multiple times, by creating a memory _total
// short circuit: if() the first expression is false, we don't need to do the second condition
// loop increments. ++i
// cache array length
// load array elements to memory

contract GasGolfOptimized {
    uint public total;

    function sumIfEvenAndLessThan99(uint[] calldata nums) external {
        uint _total = total;
        uint len = nums.length;
        for (uint i = 0; i < len; ++i) {
            uint num = nums[i];
            if(num % 2 == 0 && num < 99) {
                _total += num;
            }
        }
        total = _total;
    }
 
}
