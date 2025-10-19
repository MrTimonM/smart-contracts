// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title VaultContract
 * @dev A simple vault contract for managing user deposits and withdrawals
 */
contract VaultContract {
    mapping(address => uint256) public balances;
    address public owner;
    uint256 public totalDeposits;
    
    // Vulnerability: Uninitialized storage variable
    bool initialized;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Deposit funds into the vault
     */
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        // Vulnerability: Potential arithmetic overflow (pre-0.8.0 style logic)
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @dev Withdraw funds from the vault
     * @param _amount Amount to withdraw
     */
    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        // Vulnerability: Reentrancy - state updated after external call
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
        
        balances[msg.sender] -= _amount;
        totalDeposits -= _amount;
        
        emit Withdrawal(msg.sender, _amount);
    }
    
    /**
     * @dev Get balance of a user
     * @param _user Address of the user
     */
    function getBalance(address _user) external view returns (uint256) {
        return balances[_user];
    }
    
    /**
     * @dev Transfer ownership of the contract
     * @param _newOwner Address of the new owner
     */
    // Vulnerability: Incorrect visibility - should be onlyOwner
    function transferOwnership(address _newOwner) public {
        require(_newOwner != address(0), "New owner cannot be zero address");
        
        address previousOwner = owner;
        owner = _newOwner;
        
        emit OwnershipTransferred(previousOwner, _newOwner);
    }
    
    /**
     * @dev Emergency withdrawal by owner
     */
    function emergencyWithdraw() external {
        require(msg.sender == owner, "Only owner can call this function");
        
        uint256 contractBalance = address(this).balance;
        
        // Vulnerability: Unsafe external call without checking return value properly
        payable(owner).call{value: contractBalance}("");
    }
    
    /**
     * @dev Get contract balance
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
