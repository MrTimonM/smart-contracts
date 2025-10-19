const hre = require("hardhat");

async function main() {
  console.log("Deploying TokenSale contract...");

  const TokenSale = await hre.ethers.getContractFactory("TokenSale");
  const tokenSale = await TokenSale.deploy();

  await tokenSale.deployed();

  console.log("TokenSale deployed to:", tokenSale.address);
  console.log("Admin:", await tokenSale.admin());
  console.log("Token Name:", await tokenSale.name());
  console.log("Token Symbol:", await tokenSale.symbol());
  console.log("Token Price:", hre.ethers.utils.formatEther(await tokenSale.tokenPrice()), "ETH");
  console.log("Total Supply:", hre.ethers.utils.formatEther(await tokenSale.totalSupply()), "tokens");
  console.log("Sale Active:", await tokenSale.saleActive());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
