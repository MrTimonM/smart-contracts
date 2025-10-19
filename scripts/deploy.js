const hre = require("hardhat");

async function main() {
  console.log("=".repeat(50));
  console.log("Deploying All Contracts");
  console.log("=".repeat(50));

  // Deploy VaultContract
  console.log("\n1. Deploying VaultContract...");
  const VaultContract = await hre.ethers.getContractFactory("VaultContract");
  const vaultContract = await VaultContract.deploy();
  await vaultContract.deployed();
  console.log("   ✓ VaultContract deployed to:", vaultContract.address);

  // Deploy TokenSale
  console.log("\n2. Deploying TokenSale...");
  const TokenSale = await hre.ethers.getContractFactory("TokenSale");
  const tokenSale = await TokenSale.deploy();
  await tokenSale.deployed();
  console.log("   ✓ TokenSale deployed to:", tokenSale.address);

  // Print deployment summary
  console.log("\n" + "=".repeat(50));
  console.log("Deployment Summary");
  console.log("=".repeat(50));
  console.log("\nVaultContract:");
  console.log("  Address:", vaultContract.address);
  console.log("  Owner:", await vaultContract.owner());

  console.log("\nTokenSale:");
  console.log("  Address:", tokenSale.address);
  console.log("  Admin:", await tokenSale.admin());
  console.log("  Token:", await tokenSale.name(), `(${await tokenSale.symbol()})`);
  console.log("  Price:", hre.ethers.utils.formatEther(await tokenSale.tokenPrice()), "ETH per token");
  console.log("  Supply:", hre.ethers.utils.formatEther(await tokenSale.totalSupply()), "tokens");

  console.log("\n" + "=".repeat(50));
  console.log("Deployment completed successfully!");
  console.log("=".repeat(50));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
