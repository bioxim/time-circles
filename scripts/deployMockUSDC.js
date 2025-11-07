const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Deploying MockUSDC...");

  const MockUSDC = await ethers.getContractFactory("MockUSDC");
  const mockUSDC = await MockUSDC.deploy();

  await mockUSDC.waitForDeployment();

  console.log(`✅ MockUSDC deployed at: ${await mockUSDC.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
