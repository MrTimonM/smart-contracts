# Ethereum Smart Contracts

A collection of Ethereum smart contracts built with Solidity and Hardhat, featuring vault management and token sale functionality.

## Overview

This repository contains two main smart contracts:

1. **VaultContract** - A secure vault system for managing user deposits and withdrawals
2. **TokenSale** - A token sale contract with fixed pricing and ERC20-like token functionality

## Features

### VaultContract
- User deposit and withdrawal functionality
- Individual balance tracking
- Ownership management with transfer capability
- Emergency withdrawal for contract owner
- Event emission for all major actions

### TokenSale
- Fixed-price token sales
- ERC20-compatible token transfers
- Approval and allowance mechanism
- Configurable token price
- Admin fund withdrawal
- Sale status toggle

## Project Structure

```
.
├── contracts/           # Solidity smart contracts
│   ├── VaultContract.sol
│   └── TokenSale.sol
├── scripts/            # Deployment scripts
│   ├── deploy.js
│   ├── deploy-vault.js
│   └── deploy-tokensale.js
├── test/               # Test suites
│   ├── VaultContract.test.js
│   └── TokenSale.test.js
├── hardhat.config.js   # Hardhat configuration
└── package.json        # Project dependencies
```

## Prerequisites

- Node.js (v16 or later)
- npm or yarn
- Git

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ethereum-smart-contracts
```

2. Install dependencies:
```bash
npm install
```

## Compilation

Compile the smart contracts:

```bash
npm run compile
```

This will compile all contracts in the `contracts/` directory and generate artifacts in the `artifacts/` folder.

## Testing

Run the full test suite:

```bash
npm test
```

The test suite includes comprehensive tests for:
- Contract deployment
- Deposit and withdrawal functionality
- Token purchases and transfers
- Access control mechanisms
- Edge cases and error conditions

### Test Coverage

To generate a coverage report:

```bash
npx hardhat coverage
```

## Deployment

### Local Deployment

1. Start a local Hardhat network:
```bash
npm run node
```

2. In a separate terminal, deploy the contracts:
```bash
npm run deploy:localhost
```

### Deploy Individual Contracts

Deploy only the VaultContract:
```bash
npm run deploy:vault
```

Deploy only the TokenSale contract:
```bash
npm run deploy:tokensale
```

### Deploy All Contracts

Deploy both contracts at once:
```bash
npm run deploy
```

### Testnet/Mainnet Deployment

1. Create a `.env` file in the root directory:
```
INFURA_API_KEY=your_infura_api_key
PRIVATE_KEY=your_wallet_private_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

2. Uncomment and configure the network settings in `hardhat.config.js`

3. Deploy to testnet (e.g., Sepolia):
```bash
npx hardhat run scripts/deploy.js --network sepolia
```

## Contract Interaction

After deployment, you can interact with the contracts using Hardhat console:

```bash
npx hardhat console --network localhost
```

Example interactions:

```javascript
// Get contract instance
const VaultContract = await ethers.getContractFactory("VaultContract");
const vault = await VaultContract.attach("DEPLOYED_ADDRESS");

// Deposit funds
await vault.deposit({ value: ethers.utils.parseEther("1.0") });

// Check balance
const balance = await vault.getBalance("YOUR_ADDRESS");
console.log(ethers.utils.formatEther(balance));
```

## Scripts

- `npm test` - Run all tests
- `npm run compile` - Compile contracts
- `npm run deploy` - Deploy all contracts
- `npm run deploy:vault` - Deploy VaultContract only
- `npm run deploy:tokensale` - Deploy TokenSale only
- `npm run deploy:localhost` - Deploy to local network
- `npm run node` - Start local Hardhat network
- `npm run clean` - Clean artifacts and cache

## Smart Contract Details

### VaultContract

**Main Functions:**
- `deposit()` - Deposit ETH into the vault
- `withdraw(uint256 _amount)` - Withdraw specified amount
- `getBalance(address _user)` - View user balance
- `transferOwnership(address _newOwner)` - Transfer contract ownership
- `emergencyWithdraw()` - Owner emergency withdrawal

**Events:**
- `Deposit(address indexed user, uint256 amount)`
- `Withdrawal(address indexed user, uint256 amount)`
- `OwnershipTransferred(address indexed previousOwner, address indexed newOwner)`

### TokenSale

**Main Functions:**
- `buyTokens()` - Purchase tokens with ETH
- `transfer(address _to, uint256 _value)` - Transfer tokens
- `approve(address _spender, uint256 _value)` - Approve spending
- `transferFrom(address _from, address _to, uint256 _value)` - Transfer on behalf
- `toggleSale()` - Enable/disable token sales
- `withdrawFunds(uint256 _amount)` - Withdraw ETH (admin only)
- `updatePrice(uint256 _newPrice)` - Update token price

**Token Details:**
- Name: SaleToken
- Symbol: SALE
- Decimals: 18
- Initial Price: 0.001 ETH per token
- Total Supply: 1,000,000 tokens

**Events:**
- `Transfer(address indexed from, address indexed to, uint256 value)`
- `Approval(address indexed owner, address indexed spender, uint256 value)`
- `TokensPurchased(address indexed buyer, uint256 amount, uint256 cost)`
- `SaleStatusChanged(bool status)`

## Development

### Adding New Contracts

1. Create your Solidity contract in the `contracts/` directory
2. Write tests in the `test/` directory
3. Create a deployment script in the `scripts/` directory
4. Update the README with contract details

### Gas Optimization

The contracts are compiled with the Solidity optimizer enabled (200 runs). You can adjust this in `hardhat.config.js`:

```javascript
solidity: {
  settings: {
    optimizer: {
      enabled: true,
      runs: 200, // Adjust this value
    },
  },
}
```

## Security Considerations

These smart contracts are provided for educational and development purposes. Before deploying to mainnet:

1. Conduct thorough security audits
2. Implement comprehensive testing
3. Consider formal verification
4. Review all external calls and state changes
5. Test on testnets extensively
6. Follow best practices for access control

## Troubleshooting

### Common Issues

**Issue: "Cannot find module" error**
```bash
rm -rf node_modules package-lock.json
npm install
```

**Issue: Compilation errors**
```bash
npm run clean
npm run compile
```

**Issue: Test failures**
- Ensure local network is running for localhost tests
- Check that contract addresses are correct
- Verify network configuration in `hardhat.config.js`

## Resources

- [Hardhat Documentation](https://hardhat.org/docs)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Ethers.js Documentation](https://docs.ethers.io/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Support

For questions or issues, please open an issue on the GitHub repository.

---

**Note:** Always exercise caution when deploying smart contracts to mainnet. Ensure proper testing and auditing before deployment.
