const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Starting deployment to Base Sepolia...");

  // 📍 Dirección del devWallet (la tuya)
  const devWallet = "0x1D46474f68Bdc578eAb9ab6203f2222451A80bdF";

  // 1️⃣ Deploy TicleToken
  const TicleToken = await ethers.getContractFactory("TicleToken");
  const ticleToken = await TicleToken.deploy();
  await ticleToken.waitForDeployment();
  const ticleAddress = await ticleToken.getAddress();
  console.log(`✅ TicleToken deployed at: ${ticleAddress}`);

  // 2️⃣ Deploy CircleContract
  const stableTokenAddress = "0x49ED01406Ebd0F73bb77817066cDF6909aF3dF88"; // mock USDC
  const secondsPerDay = 60; // 1 "día" = 60 segundos para test

  const CircleContract = await ethers.getContractFactory("CircleContract");
  const circleContract = await CircleContract.deploy(
    stableTokenAddress,
    ticleAddress,
    devWallet, // 🆕 nueva línea: dirección de fees
    secondsPerDay
  );
  await circleContract.waitForDeployment();
  const circleAddress = await circleContract.getAddress();
  console.log(`✅ CircleContract deployed at: ${circleAddress}`);

  // 3️⃣ Vincular el contrato Circle con el token Ticle
  const tx1 = await ticleToken.setCircleContract(circleAddress);
  await tx1.wait();
  console.log("🔗 CircleContract linked to TicleToken");

  // 4️⃣ Mint inicial (liquidez inicial)
  const mintAmount = ethers.parseUnits("1000", 18);
  const tx2 = await ticleToken.mintInitial(devWallet, mintAmount);
  await tx2.wait();
  console.log(`💰 Minted 1000 TICLE to ${devWallet}`);

  // 5️⃣ Deploy ArenaRegistry
  const ArenaRegistry = await ethers.getContractFactory("ArenaRegistry");
  const arenaRegistry = await ArenaRegistry.deploy(ticleAddress, devWallet); // 🆕 agregado devWallet
  await arenaRegistry.waitForDeployment();
  const arenaAddress = await arenaRegistry.getAddress();
  console.log(`✅ ArenaRegistry deployed at: ${arenaAddress}`);

  console.log("\n🎉 Deployment complete!");
  console.log("📜 TicleToken:", ticleAddress);
  console.log("📜 CircleContract:", circleAddress);
  console.log("📜 ArenaRegistry:", arenaAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
