## setup environment
- rename `.env.example` to `.env`
- fill your key in `.env`
- npm i

## deploy NFT game and verify
- `npx hardhat run scripts/deployNFT.js --network goerli`
- `npx hardhat verify --network goerli ${YOUR CONTRACT ADDRESS}`

## deploy lottery game and verify
- `npx hardhat run scripts/deployGame.js --network goerli`
- `npx hardhat verify --network goerli ${YOUR CONTRACT ADDRESS} "${YOUR CHAINLINK SUBSCRIBE ID}"`