const hre = require("hardhat");

async function main() {
  const NFTBlindBoxContractFactory = await hre.ethers.getContractFactory("NFTBlindBox");
  const NFTBlindBoxContract = await NFTBlindBoxContractFactory.deploy()

  await NFTBlindBoxContract.deployed();
  console.log("NFTBlindBox Contract address:", NFTBlindBoxContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
