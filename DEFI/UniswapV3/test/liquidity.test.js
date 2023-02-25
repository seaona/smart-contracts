const { expect } = require("chai")
const { ethers } = require("hardhat")

const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
const DAI_WHALE = "0x9D0163e76BbCf776001E639d65F573949a53AB03"
const USDC_WHALE = "0x21a31Ee1afC51d94C2eFcCAa2092aD1028285549"

describe("LiquidityExamples", () => {
  let liquidityExamples
  let accounts
  let dai
  let usdc

  before(async () => {
    accounts = await ethers.getSigners(1)

    const LiquidityExamples = await ethers.getContractFactory("LiquidityExamples")
    liquidityExamples = await LiquidityExamples.deploy()

    dai = await ethers.getContractAt("IERC20", DAI)
    usdc = await ethers.getContractAt("IERC20", USDC)

    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [DAI_WHALE],
    })

    const daiWhale = await ethers.getSigner(DAI_WHALE)

    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [USDC_WHALE],
    })

    const usdcWhale = await ethers.getSigner(USDC_WHALE)

    const daiAmount = 100n * 10n ** 18n;
    const usdcAmount = 100n * 10n ** 6n;

    expect(await dai.balanceOf(daiWhale.address)).to.gte(daiAmount);
    expect(await usdc.balanceOf(usdcWhale.address)).to.gte(usdcAmount);

    await dai.connect(daiWhale).transfer(accounts[0].address, daiAmount);
    await usdc.connect(usdcWhale).transfer(accounts[0].address, usdcAmount);

  })
  

  it("mintNewPosition", async () => {
    const daiAmount = 100n * 10n ** 18n;
    const usdcAmount = 100n * 10n ** 6n;

    await dai
      .connect(accounts[0])
      .transfer(liquidityExamples.address, daiAmount);
    await usdc
      .connect(accounts[0])
      .transfer(liquidityExamples.address, usdcAmount);

    await liquidityExamples.mintNewPosition();
    console.log(
      "DAI balance after add liquidity", 
      await dai.balanceOf(accounts[0].address)
    )
    console.log(
      "USDC balance after add liquidity", 
      await usdc.balanceOf(accounts[0].address)
    )
  })

})