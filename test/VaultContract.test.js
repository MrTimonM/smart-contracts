const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VaultContract", function () {
  let vaultContract;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    const VaultContract = await ethers.getContractFactory("VaultContract");
    vaultContract = await VaultContract.deploy();
    await vaultContract.deployed();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await vaultContract.owner()).to.equal(owner.address);
    });

    it("Should have zero initial balance", async function () {
      expect(await vaultContract.getContractBalance()).to.equal(0);
    });
  });

  describe("Deposits", function () {
    it("Should allow users to deposit funds", async function () {
      const depositAmount = ethers.utils.parseEther("1.0");
      
      await expect(
        vaultContract.connect(addr1).deposit({ value: depositAmount })
      )
        .to.emit(vaultContract, "Deposit")
        .withArgs(addr1.address, depositAmount);

      expect(await vaultContract.getBalance(addr1.address)).to.equal(depositAmount);
    });

    it("Should update total deposits correctly", async function () {
      const depositAmount = ethers.utils.parseEther("2.0");
      
      await vaultContract.connect(addr1).deposit({ value: depositAmount });
      
      expect(await vaultContract.totalDeposits()).to.equal(depositAmount);
    });

    it("Should reject zero deposits", async function () {
      await expect(
        vaultContract.connect(addr1).deposit({ value: 0 })
      ).to.be.revertedWith("Deposit amount must be greater than 0");
    });

    it("Should allow multiple deposits from the same user", async function () {
      const firstDeposit = ethers.utils.parseEther("1.0");
      const secondDeposit = ethers.utils.parseEther("0.5");
      
      await vaultContract.connect(addr1).deposit({ value: firstDeposit });
      await vaultContract.connect(addr1).deposit({ value: secondDeposit });
      
      const expectedBalance = firstDeposit.add(secondDeposit);
      expect(await vaultContract.getBalance(addr1.address)).to.equal(expectedBalance);
    });
  });

  describe("Withdrawals", function () {
    beforeEach(async function () {
      const depositAmount = ethers.utils.parseEther("5.0");
      await vaultContract.connect(addr1).deposit({ value: depositAmount });
    });

    it("Should allow users to withdraw their funds", async function () {
      const withdrawAmount = ethers.utils.parseEther("2.0");
      
      await expect(
        vaultContract.connect(addr1).withdraw(withdrawAmount)
      )
        .to.emit(vaultContract, "Withdrawal")
        .withArgs(addr1.address, withdrawAmount);
    });

    it("Should update balance after withdrawal", async function () {
      const depositAmount = ethers.utils.parseEther("5.0");
      const withdrawAmount = ethers.utils.parseEther("2.0");
      
      await vaultContract.connect(addr1).withdraw(withdrawAmount);
      
      const expectedBalance = depositAmount.sub(withdrawAmount);
      expect(await vaultContract.getBalance(addr1.address)).to.equal(expectedBalance);
    });

    it("Should reject withdrawal with insufficient balance", async function () {
      const withdrawAmount = ethers.utils.parseEther("10.0");
      
      await expect(
        vaultContract.connect(addr1).withdraw(withdrawAmount)
      ).to.be.revertedWith("Insufficient balance");
    });
  });

  describe("Ownership", function () {
    it("Should allow ownership transfer", async function () {
      await expect(
        vaultContract.connect(owner).transferOwnership(addr1.address)
      )
        .to.emit(vaultContract, "OwnershipTransferred")
        .withArgs(owner.address, addr1.address);

      expect(await vaultContract.owner()).to.equal(addr1.address);
    });

    it("Should reject zero address as new owner", async function () {
      await expect(
        vaultContract.transferOwnership(ethers.constants.AddressZero)
      ).to.be.revertedWith("New owner cannot be zero address");
    });
  });

  describe("Emergency Withdrawal", function () {
    it("Should allow owner to perform emergency withdrawal", async function () {
      const depositAmount = ethers.utils.parseEther("3.0");
      await vaultContract.connect(addr1).deposit({ value: depositAmount });

      const ownerBalanceBefore = await ethers.provider.getBalance(owner.address);
      
      await vaultContract.connect(owner).emergencyWithdraw();
      
      expect(await vaultContract.getContractBalance()).to.equal(0);
    });

    it("Should reject emergency withdrawal from non-owner", async function () {
      await expect(
        vaultContract.connect(addr1).emergencyWithdraw()
      ).to.be.revertedWith("Only owner can call this function");
    });
  });
});
