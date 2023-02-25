require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

const DEFAULT_COMPILER_SETTINGS =
  {
    version: "0.7.6",
    settings: {
      evmVersion: "istanbul",
      optimizer: {
        enabled: true,
        runs: 1_000_000,
      },
      metadata: {
        bytecodeHash: "none",
      }
    },
  }
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [DEFAULT_COMPILER_SETTINGS],
  },
  networks: {
    hardhat: {
      forking: {
        url: `https://mainnet.infura.io/v3/${process.env.WEB3_INFURA_PROJECT_ID}`
      }
    }
  }
};
