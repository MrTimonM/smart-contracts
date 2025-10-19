const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TokenSale", function () {
  let tokenSale;
  let admin;
  let buyer1;
  let buyer2;

  beforeEach(async function () {
    [admin, buyer1, buyer2] = await ethers.getSigners();

    const TokenSale = await ethers.getContractFactory("TokenSale");
    tokenSale = await TokenSale.deploy();
    await tokenSale.deployed();
  });

  describe("Deployment", function () {
    it("Should set the correct token details", async function () {
      expect(await tokenSale.name()).to.equal("SaleToken");
      expect(await tokenSale.symbol()).to.equal("SALE");
      expect(await tokenSale.decimals()).to.equal(18);
    });

    it("Should set the right admin", async function () {
      expect(await tokenSale.admin()).to.equal(admin.address);
    });

    it("Should initialize sale as active", async function () {
      expect(await tokenSale.saleActive()).to.equal(true);
    });

    it("Should allocate total supply to contract", async function () {
      const totalSupply = await tokenSale.totalSupply();
      const contractBalance = await tokenSale.balanceOf(tokenSale.address);
      expect(contractBalance).to.equal(totalSupply);
    });
  });

  describe("Token Purchase", function () {
    it("Should allow users to buy tokens", async function () {
      const ethAmount = ethers.utils.parseEther("1.0");
      const tokenPrice = await tokenSale.tokenPrice();
      const expectedTokens = ethAmount.mul(ethers.utils.parseEther("1")).div(tokenPrice);

      await expect(
        tokenSale.connect(buyer1).buyTokens({ value: ethAmount })
      )
        .to.emit(tokenSale, "TokensPurchased")
        .withArgs(buyer1.address, expectedTokens, ethAmount);

      expect(await tokenSale.balanceOf(buyer1.address)).to.equal(expectedTokens);
    });

    it("Should reject purchase with zero ETH", async function () {
      await expect(
        tokenSale.connect(buyer1).buyTokens({ value: 0 })
      ).to.be.revertedWith("Must send ETH to buy tokens");
    });

    it("Should update contract balance after purchase", async function () {
      const ethAmount = ethers.utils.parseEther("0.5");
      
      await tokenSale.connect(buyer1).buyTokens({ value: ethAmount });
      
      expect(await tokenSale.getContractBalance()).to.equal(ethAmount);
    });

    it("Should allow multiple purchases", async function () {
      const firstPurchase = ethers.utils.parseEther("0.5");
      const secondPurchase = ethers.utils.parseEther("0.3");
      
      await tokenSale.connect(buyer1).buyTokens({ value: firstPurchase });
      await tokenSale.connect(buyer1).buyTokens({ value: secondPurchase });
      
      const tokenPrice = await tokenSale.tokenPrice();
      const totalEth = firstPurchase.add(secondPurchase);
      const expectedTokens = totalEth.mul(ethers.utils.parseEther("1")).div(tokenPrice);
      
      expect(await tokenSale.balanceOf(buyer1.address)).to.equal(expectedTokens);
    });
  });

  describe("Token Transfers", function () {
    beforeEach(async function () {
      const ethAmount = ethers.utils.parseEther("1.0");
      await tokenSale.connect(buyer1).buyTokens({ value: ethAmount });
    });

    it("Should transfer tokens between accounts", async function () {
      const transferAmount = ethers.utils.parseEther("100");
      
      await expect(
        tokenSale.connect(buyer1).transfer(buyer2.address, transferAmount)
      )
        .to.emit(tokenSale, "Transfer")
        .withArgs(buyer1.address, buyer2.address, transferAmount);

      expect(await tokenSale.balanceOf(buyer2.address)).to.equal(transferAmount);
    });

    it("Should reject transfer with insufficient balance", async function () {
      const transferAmount = ethers.utils.parseEther("10000");
      
      await expect(
        tokenSale.connect(buyer1).transfer(buyer2.address, transferAmount)
      ).to.be.revertedWith("Insufficient balance");
    });

    it("Should reject transfer to zero address", async function () {
      const transferAmount = ethers.utils.parseEther("100");
      
      await expect(
        tokenSale.connect(buyer1).transfer(ethers.constants.AddressZero, transferAmount)
      ).to.be.revertedWith("Cannot transfer to zero address");
    });
  });

  describe("Allowance and TransferFrom", function () {
    beforeEach(async function () {
      const ethAmount = ethers.utils.parseEther("1.0");
      await tokenSale.connect(buyer1).buyTokens({ value: ethAmount });
    });

    it("Should approve spender", async function () {
      const approvalAmount = ethers.utils.parseEther("200");
      
      await expect(
        tokenSale.connect(buyer1).approve(buyer2.address, approvalAmount)
      )
        .to.emit(tokenSale, "Approval")
        .withArgs(buyer1.address, buyer2.address, approvalAmount);

      expect(await tokenSale.allowance(buyer1.address, buyer2.address)).to.equal(approvalAmount);
    });

    it("Should allow transferFrom with valid allowance", async function () {
      const approvalAmount = ethers.utils.parseEther("200");
      const transferAmount = ethers.utils.parseEther("100");
      
      await tokenSale.connect(buyer1).approve(buyer2.address, approvalAmount);
      
      await tokenSale.connect(buyer2).transferFrom(
        buyer1.address,
        buyer2.address,
        transferAmount
      );

      expect(await tokenSale.balanceOf(buyer2.address)).to.equal(transferAmount);
    });

    it("Should reject transferFrom with insufficient allowance", async function () {
      const transferAmount = ethers.utils.parseEther("100");
      
      await expect(
        tokenSale.connect(buyer2).transferFrom(
          buyer1.address,
          buyer2.address,
          transferAmount
        )
      ).to.be.revertedWith("Insufficient allowance");
    });
  });

  describe("Sale Status", function () {
    it("Should toggle sale status", async function () {
      await expect(tokenSale.toggleSale())
        .to.emit(tokenSale, "SaleStatusChanged")
        .withArgs(false);

      expect(await tokenSale.saleActive()).to.equal(false);
    });

    it("Should reject purchases when sale is inactive", async function () {
      await tokenSale.toggleSale();
      
      const ethAmount = ethers.utils.parseEther("1.0");
      await expect(
        tokenSale.connect(buyer1).buyTokens({ value: ethAmount })
      ).to.be.revertedWith("Sale is not active");
    });
  });

  describe("Admin Functions", function () {
    it("Should allow admin to withdraw funds", async function () {
      const ethAmount = ethers.utils.parseEther("2.0");
      await tokenSale.connect(buyer1).buyTokens({ value: ethAmount });

      await tokenSale.connect(admin).withdrawFunds(ethAmount);
      
      expect(await tokenSale.getContractBalance()).to.equal(0);
    });

    it("Should reject withdrawal from non-admin", async function () {
      const ethAmount = ethers.utils.parseEther("1.0");
      await tokenSale.connect(buyer1).buyTokens({ value: ethAmount });

      await expect(
        tokenSale.connect(buyer1).withdrawFunds(ethAmount)
      ).to.be.revertedWith("Only admin can withdraw");
    });

    it("Should allow price update", async function () {
      const newPrice = ethers.utils.parseEther("0.002");
      
      await tokenSale.updatePrice(newPrice);
      
      expect(await tokenSale.tokenPrice()).to.equal(newPrice);
    });

    it("Should reject zero price", async function () {
      await expect(
        tokenSale.updatePrice(0)
      ).to.be.revertedWith("Price must be greater than 0");
    });
  });
});
