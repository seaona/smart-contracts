// load envars
source .env

// fork mainnet
ganache \
--fork https://mainnet.infura.io/v3/$WEB3_INFURA_PROJECT_ID \
--unlock $DAI_WHALE \
--networkId 999