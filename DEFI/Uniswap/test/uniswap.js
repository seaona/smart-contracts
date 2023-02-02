const BN = require("bn.js");
const IERC20 = artifacts.require("IERC20");
const TestUniswap = artifacts.require("TestUniswap");

contract("TestUniswap", (accounts) => {
    const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
    const DAI_WHALE = "0x748de14197922c4ae258c7939c7739f3ff1db573"
    const WBTC = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"

    const WHALE = DAI_WHALE;
    const AMOUNT_IN = new BN(10).pow(new BN(18)).mul(new BN(1000000)); //1,000,000 DAI
    const AMOUNT_OUT_MIN = 1;
    const TOKEN_IN = DAI;
    const TOKEN_OUT = WBTC;
    const TO = accounts[0];

    it("shoul swap", async () => {
        const tokenIn = await IERC20.at(TOKEN_IN);
        const tokenOut = await IERC20.at(TOKEN_OUT);
        const testUniswap = await TestUniswap.new();

        await tokenIn.approve(testUniswap.address, AMOUNT_IN, { from: WHALE});
        await testUniswap.swap(
            tokenIn.address,
            tokenOut.address,
            AMOUNT_IN,
            AMOUNT_OUT_MIN,
            TO,
            {
                from: WHALE,
            }
        );

        console.log(`out ${await tokenOut.balanceOf(TO)}`);
    })
})