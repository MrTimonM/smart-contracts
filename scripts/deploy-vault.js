const hre = require("hardhat");

async function main() {
  console.log("Deploying VaultContract...");

  const VaultContract = await hre.ethers.getContractFactory("VaultContract");
  const vaultContract = await VaultContract.deploy();

  await vaultContract.deployed();

  console.log("VaultContract deployed to:", vaultContract.address);
  console.log("Owner:", await vaultContract.owner());
  console.log("Initial contract balance:", await vaultContract.getContractBalance());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
