const hre = require("hardhat");

async function main() {
  const subscriptionFee = hre.ethers.utils.parseEther("0.05"); // Example 0.05 ETH fee

  const FlexSub = await hre.ethers.getContractFactory("FlexSub");
  const flexSub = await FlexSub.deploy(subscriptionFee);

  await flexSub.deployed();
  console.log("FlexSub deployed to:", flexSub.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
