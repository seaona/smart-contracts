// load envars
source .env

// fork mainnet
ganache \
--fork https://mainnet.infura.io/v3/$WEB3_INFURA_PROJECT_ID \
--unlock $DAI_WHALE \
--unlock $USDC_WHALE \
--unlock $USDT_WHALE \
--unlock $WBTC_WHALE \
--unlock $WETH_WHALE \
--networkId 999


ganache --fork https://mainnet.infura.io/v3/$WEB3_INFURA_PROJECT_ID --unlock 0x748de14197922c4ae258c7939c7739f3ff1db573

// test
npx truffle test test/uniswap-optimal.js --network mainnet_fork