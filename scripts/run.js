const hre = require("hardhat");

async function main() {
  const NFTBlindBoxContractFactory = await hre.ethers.getContractFactory("NFTBlindBox");
  const NFTBlindBoxContract = await NFTBlindBoxContractFactory.deploy()

  await NFTBlindBoxContract.deployed();
  console.log("NFTBlindBox Contract address:", NFTBlindBoxContract.address);

  const LotteryGameContractFactory = await hre.ethers.getContractFactory("LotteryGame");
  const LotteryGameContract = await LotteryGameContractFactory.deploy(2)

  await LotteryGameContract.deployed();
  console.log("LotteryGame Contract address:", LotteryGameContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
