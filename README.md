
````markdown
# FundMe Smart Contract

A decentralized crowdfunding smart contract built with Solidity and tested using Foundry.

## 🚀 Overview

The `FundMe` contract allows users to send ETH to the contract, and only the owner can withdraw the funds. It includes price conversion using Chainlink Price Feeds to ensure users contribute a minimum USD amount.

This project uses [Foundry](https://book.getfoundry.sh/) — a blazing fast, portable, and modular toolkit for Ethereum application development.

## 📦 Features

- Accepts ETH funding from users
- Converts ETH to USD using Chainlink Price Feeds
- Requires a minimum USD contribution
- Only the contract owner can withdraw
- Includes mocks for local testing

## 🧰 Tech Stack

- [Solidity](https://soliditylang.org/)
- [Foundry](https://book.getfoundry.sh/)
- [Chainlink](https://chain.link/)
- [Anvil](https://book.getfoundry.sh/reference/anvil/)

## 🛠️ Installation & Setup

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed (`foundryup`)
- Node.js & npm (for frontend integration, if needed)

```bash
# Clone the repository
git clone https://github.com/MaryEjairu/fundme-foundry.git
cd fundme-foundry

# Install Foundry dependencies
forge install
````

## 🔧 How to Use

### 1. Compile Contracts

```bash
forge build
```

### 2. Run Tests

```bash
forge test
```

### 3. Deploy to a Local Network (Anvil)

```bash
anvil
# in a new terminal
forge script script/DeployFundMe.s.sol:DeployFundMe --fork-url http://localhost:8545 --broadcast
```

### 4. Deploy to a Testnet

Set your `.env` file:

```
PRIVATE_KEY=your_private_key
RPC_URL=https://sepolia.infura.io/v3/your_project_id
ETHERSCAN_API_KEY=your_etherscan_key
```

Then run:

```bash
forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## 📁 Project Structure

```
.
├── contracts/
│   └── FundMe.sol
├── script/
│   └── DeployFundMe.s.sol
├── test/
│   └── FundMe.t.sol
├── lib/
│   └── (Foundry dependencies)
└── foundry.toml
```

## 📊 Environment Configuration

Use `.env` to store your secrets (optional):

```
PRIVATE_KEY=
RPC_URL=
ETHERSCAN_API_KEY=
```

## 🧪 Testing

This contract includes unit and integration tests. Run them with:

```bash
forge test --fork-url $RPC_URL
```

To see gas reports:

```bash
forge test --gas-report
```

## 📜 License

This project is licensed under the MIT License.

---

Built with ❤️ using Foundry by \[MaryEjairu].


`

