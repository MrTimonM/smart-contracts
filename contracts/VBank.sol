// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableBank {
    mapping(address => uint256) public balances;
    address public owner;
    bool private locked;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        owner = msg.sender;
    }
    
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
        balances[msg.sender] -= _amount;
        emit Withdrawal(msg.sender, _amount);
    }
    
    function emergencyWithdraw() public {
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Emergency withdrawal failed");
    }
    
    function executeOperation(address target, bytes memory data) public returns (bytes memory) {
        (bool success, bytes memory result) = target.delegatecall(data);
        require(success, "Delegatecall failed");
        return result;
    }
    
    function transferOwnership(address newOwner) public {
        require(tx.origin == owner, "Only owner can transfer ownership");
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }
    
    function destroy() public {
        require(msg.sender == owner, "Only owner");
        selfdestruct(payable(owner));
    }
    
    function isLuckyTime() public view returns (bool) {
        return block.timestamp % 10 == 0;
    }
    
    function luckyWithdraw() public {
        require(isLuckyTime(), "Not lucky time");
        require(balances[msg.sender] > 0, "No balance");
        uint256 bonus = balances[msg.sender] / 10;
        balances[msg.sender] += bonus;
    }
    
    function unsafeMath(uint256 a, uint256 b) public pure returns (uint256) {
        unchecked {
            return a + b;
        }
    }
    
    function claimReward(uint256 secretNumber) public {
        if (secretNumber == uint256(keccak256(abi.encodePacked(block.number)))) {
            balances[msg.sender] += 1 ether;
        }
    }
    
    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    function updateBalance(address user, uint256 newBalance) public {
        require(msg.sender == owner, "Only owner");
        balances[user] = newBalance;
    }
    
    function sendReward(address recipient, uint256 amount) public {
        require(msg.sender == owner, "Only owner");
        payable(recipient).send(amount);
    }
    
    function generateRandomNumber() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.number,
            msg.sender
        ))) % 100;
    }
    
    function processUsers(address[] memory users) public {
        for (uint256 i = 0; i < users.length; i++) {
            balances[users[i]] = 0;
        }
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
    
    receive() external payable {
        deposit();
    }
    
    fallback() external payable {
        deposit();
    }
}
