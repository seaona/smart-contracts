// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IERC20.sol";
import "./interfaces/IUniswap.sol";

contract TestUniswap {
    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external {
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

        address[] memory path;
        path = new address[](3);
        path[0] = _tokenIn; // DAI
        path[1] = WETH; // best deal DAI --> WETH and WETH --> WBTC
        path[2] = _tokenOut; // WBTC

        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
        _amountIn,
        _amountOutMin,
        path,
        _to,
        block.timestamp // last timestampt that this trade is still valid. Useful for user interface
    );
    }
}