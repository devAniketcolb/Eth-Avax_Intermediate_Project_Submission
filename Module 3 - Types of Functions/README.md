# ERC20Token Smart Contract - Module 3 Types of Functions

## Overview
The `ERC20Token` contract is a customizable implementation of the ERC-20 token standard using the OpenZeppelin library. It includes basic functionalities like token transfer, minting, and burning, with added security features and ownership controls.

## Features
- **ERC-20 Standard Compliance**: Implements the ERC-20 standard for fungible tokens.
- **Customizable Initialization**: Allows the owner to define the token's name, symbol, and initial supply.
- **Ownership Restriction**: Only the contract owner can mint new tokens.
- **Burning Tokens**: Token holders can burn their own tokens to reduce the total supply.
- **Validation**: Includes additional checks for transfer operations to prevent invalid transactions.

## Dependencies
- [OpenZeppelin Contracts](https://openzeppelin.com/contracts/): A library of secure and modular smart contracts.
  - `ERC20.sol`
  - `Ownable.sol`

# ERC20 Smart Contract 
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ERC20Token is ERC20, Ownable(msg.sender) {

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool success)
    {
        require(recipient != address(0), "Transfer to the zero address is not allowed");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        return super.transfer(recipient, amount);
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
    
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
```

## Constructor
The constructor initializes the token contract with the following parameters:
- `name`: The name of the token (e.g., "MyToken").
- `symbol`: The symbol of the token (e.g., "MTK").
- `initialSupply`: The initial supply of tokens to be minted and assigned to the owner.

```solidity
constructor(
    string memory name,
    string memory symbol,
    uint256 initialSupply
) ERC20(name, symbol) {
    _mint(msg.sender, initialSupply);
}
```

## Functions

### `transfer`
Transfers tokens from the sender to a recipient.
- **Parameters**:
  - `recipient`: The address of the recipient.
  - `amount`: The number of tokens to transfer.
- **Validations**:
  - The recipient cannot be the zero address.
  - The sender must have a sufficient balance.

### `mint`
Mints new tokens and assigns them to a specified account.
- **Access Control**: Only callable by the owner.
- **Parameters**:
  - `account`: The address of the recipient.
  - `amount`: The number of tokens to mint.

### `burn`
Burns a specified number of tokens from the sender's balance.
- **Parameters**:
  - `amount`: The number of tokens to burn.

## Usage
1. **Deployment**: Deploy the contract by providing the token's name, symbol, and initial supply as arguments to the constructor.
2. **Transferring Tokens**: Use the `transfer` function to send tokens between accounts.
3. **Minting Tokens**: Call the `mint` function as the owner to increase the total supply.
4. **Burning Tokens**: Token holders can reduce the total supply by calling the `burn` function.

## Mint & Burn Example
```solidity
// Deploy the contract with the name "MyToken", symbol "MTK", and initial supply of 1,000,000
ERC20Token token = new ERC20Token("MyToken", "MTK", 1000000);

// Transfer 100 tokens to another address
token.transfer(0xRecipientAddress, 100);

// Mint 500 tokens to a specific address (only owner can do this)
token.mint(0xRecipientAddress, 500);

// Burn 200 tokens from the sender's balance
token.burn(200);
```

## Security Considerations
- Ensure the owner’s private key is securely stored.
- Avoid using the zero address for any operations.
- Use a secure development and deployment environment.

## License
This project is licensed under the MIT License. See the `SPDX-License-Identifier` in the source code for details.

---

For more information on ERC-20 standards, visit the [Ethereum Documentation](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/).
