const hre = require("hardhat");

async function main() {
  const LotteryGameContractFactory = await hre.ethers.getContractFactory("LotteryGame");
  const LotteryGameContract = await LotteryGameContractFactory.deploy(490)
  
  await LotteryGameContract.deployed();
  console.log("LotteryGame Contract address:", LotteryGameContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
