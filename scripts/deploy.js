const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  const network = await hre.ethers.provider.getNetwork();

  console.log("======================================");
  console.log("🚀 Deployment started");
  console.log("Deployer:", deployer.address);
  console.log("Network:", network.name);
  console.log("Chain ID:", network.chainId.toString());
  console.log("======================================");

  // Authority signer (off-chain authorization signer)
  const authority = deployer.address;

  // Deploy AuthorizationManager
  const AuthorizationManager = await hre.ethers.getContractFactory("AuthorizationManager");
  const authManager = await AuthorizationManager.deploy(authority);
  await authManager.waitForDeployment();

  const authManagerAddress = await authManager.getAddress();
  console.log("✅ AuthorizationManager deployed at:", authManagerAddress);

  // Deploy SecureVault
  const SecureVault = await hre.ethers.getContractFactory("SecureVault");
  const vault = await SecureVault.deploy(authManagerAddress);
  await vault.waitForDeployment();

  const vaultAddress = await vault.getAddress();
  console.log("✅ SecureVault deployed at:", vaultAddress);

  console.log("======================================");
  console.log("🎉 Deployment completed successfully");
  console.log("======================================");
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exit(1);
});
