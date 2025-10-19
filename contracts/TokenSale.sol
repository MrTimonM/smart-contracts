// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TokenSale
 * @dev A token sale contract with fixed price and cap
 */
contract TokenSale {
    string public name = "SaleToken";
    string public symbol = "SALE";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public tokenPrice = 0.001 ether; // 1 token = 0.001 ETH
    uint256 public cap = 1000000 * 10**18; // 1 million tokens
    
    address payable public admin;
    bool public saleActive = true;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 cost);
    event SaleStatusChanged(bool status);
    
    constructor() {
        admin = payable(msg.sender);
        totalSupply = cap;
        balanceOf[address(this)] = totalSupply;
    }
    
    /**
     * @dev Buy tokens with ETH
     */
    function buyTokens() external payable {
        require(saleActive, "Sale is not active");
        require(msg.value > 0, "Must send ETH to buy tokens");
        
        // Vulnerability: Arithmetic operation without proper checks
        uint256 tokenAmount = (msg.value * 10**18) / tokenPrice;
        
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens available");
        
        balanceOf[address(this)] -= tokenAmount;
        balanceOf[msg.sender] += tokenAmount;
        
        emit TokensPurchased(msg.sender, tokenAmount, msg.value);
        emit Transfer(address(this), msg.sender, tokenAmount);
    }
    
    /**
     * @dev Transfer tokens to another address
     * @param _to Recipient address
     * @param _value Amount of tokens
     */
    function transfer(address _to, uint256 _value) external returns (bool) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    /**
     * @dev Approve spender to spend tokens
     * @param _spender Address of spender
     * @param _value Amount to approve
     */
    function approve(address _spender, uint256 _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /**
     * @dev Transfer tokens from one address to another
     * @param _from Sender address
     * @param _to Recipient address
     * @param _value Amount of tokens
     */
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    /**
     * @dev Toggle sale status
     */
    // Vulnerability: Missing access control
    function toggleSale() external {
        saleActive = !saleActive;
        emit SaleStatusChanged(saleActive);
    }
    
    /**
     * @dev Withdraw funds from contract
     * @param _amount Amount to withdraw
     */
    function withdrawFunds(uint256 _amount) external {
        require(msg.sender == admin, "Only admin can withdraw");
        require(address(this).balance >= _amount, "Insufficient contract balance");
        
        // Vulnerability: Unsafe external call
        admin.call{value: _amount}("");
    }
    
    /**
     * @dev Update token price
     * @param _newPrice New price in wei
     */
    // Vulnerability: Missing access control - should be admin only
    function updatePrice(uint256 _newPrice) external {
        require(_newPrice > 0, "Price must be greater than 0");
        tokenPrice = _newPrice;
    }
    
    /**
     * @dev Get contract ETH balance
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
