# Uniswap V2

## Pricing

Uniswap DAI/ETH Liquidity Provider
1. https://etherscan.io/token/0xa478c2975ab1ea89e8196811f51a7b7ade33eb11#readContract
2. getReserves from token 0 and token 1
3. Calculate amountOut

Python3

```
>>> x = 7539459268147080188467316 // paste reserve0
>>> y = 4517131075984818258740 // paste reserve1
>>> dx = 10 ** 18
>>> dy = y * 0.997 * dx / (x + 0.997 * dx)
>>> dy
597334494032114.6
```

4. Check that dy calculated in Python is the same as the one return by Uniswap V2 Router.
https://etherscan.io/address/0x7a250d5630b4cf539739df2c5dacb4c659f2488d#readContract

```
dy = getAmountOut(
        amountIn: dx
        reserveIn: x
        reserveOut: y
    )
```

## Liquidity
