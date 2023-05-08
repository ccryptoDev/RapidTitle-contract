const { ethers, upgrades } = require("hardhat");

async function main() {
  const RTInstance = await ethers.getContractFactory("RT_ERC721");
  const RTContract = await RTInstance.deploy("RT721");
  console.log("RT Contract is deployed to:", RTContract.address);
}

main();
