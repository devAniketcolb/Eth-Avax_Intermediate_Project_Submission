# Degen Gaming Token (DGN)

The `GameClone` smart contract is a custom ERC20 token deployed on the Avalanche network for Degen Gaming. It powers the in-game economy by allowing players to earn, transfer, redeem, and burn tokens. This README provides an overview of the functionality and usage of the smart contract.

---

## Key Features

### 1. Minting Tokens
- The contract owner can mint new tokens to distribute as rewards for players' achievements and activities.
- Function: `mint(uint256 amount)`

### 2. Transferring Tokens
- Players can transfer tokens to other players seamlessly.
- Function: `transfer(address recipient, uint256 amount)`

### 3. Redeeming Tokens
- Players can redeem their tokens for exclusive in-game items through the `GameStore`.
- Items include:
  - Sword Cookie: 500 DGN
  - VIP Skins: 10,000 DGN
  - Army Tank Pro: 20,000 DGN
  - Royal Pass: 25,000 DGN
- Function: `redeemItem(uint256 itemId)`

### 4. Burning Tokens
- Players can burn tokens they no longer need, reducing the circulating supply.
- Function: `burn(uint256 amount)`

### 5. Checking Token Balance
- Players can view their token balances at any time using the inherited ERC20 functionality.
- Function: `balanceOf(address account)`

### 6. Item Redemption History
- Players can track the number of items they have redeemed and check if specific items have been redeemed.
- Functions:
  - `getRedeemedItemCount(address user)`
  - `redeemedItems(address user, uint256 itemId)`

---

## Smart Contract Overview

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameClone is ERC20, Ownable(msg.sender) {


    mapping(uint256 => string) public itemName;
    mapping(uint256 => uint256) public itemPrice;
    mapping(address => mapping(uint256 => bool)) public redeemedItems;
    mapping(address => uint256) public redeemedItemCount;
    
    constructor() ERC20("Degen", "DGN") {
        GameStore(0, "Sword Cookie", 500);
        GameStore(1, "VIP Skins", 10000);
        GameStore(2, "Army Tank Pro", 20000);
        GameStore(3, "Royal Pass", 25000);
    }


    event Redeem(address indexed user, string itemName);

    function GameStore(uint256 itemId, string memory _itemName, uint256 _itemPrice) internal {
        itemName[itemId] = _itemName;
        itemPrice[itemId] = _itemPrice;
    }

    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function redeemItem(uint256 itemId) public returns (string memory) {
        uint256 redemptionAmount = itemPrice[itemId];
        require(balanceOf(msg.sender) >= redemptionAmount, "Not Enough Tokens To Redeem This Item");

        _burn(msg.sender, redemptionAmount);
        redeemedItems[msg.sender][itemId] = true;
        redeemedItemCount[msg.sender]++;
        emit Redeem(msg.sender, itemName[itemId]);

        return itemName[itemId];
    }

    function getRedeemedItemCount(address user) public view returns (uint256) {
        return redeemedItemCount[user];
    }
}
```

### Contract: `GameClone`
The `GameClone` contract is an ERC20 token with added functionality for an in-game store.

#### Token Details
- **Name**: Degen
- **Symbol**: DGN
- **Decimals**: 18 (default for ERC20)

#### Game Store
The in-game store is initialized with predefined items and their corresponding prices in DGN tokens:
- Item IDs and Names:
  - `0`: Sword Cookie (500 DGN)
  - `1`: VIP Skins (10,000 DGN)
  - `2`: Army Tank Pro (20,000 DGN)
  - `3`: Royal Pass (25,000 DGN)

#### Events
- `Redeem(address indexed user, string itemName)`: Emitted when a player redeems an item.

---

## Deployment Instructions

### Prerequisites
1. **Node.js** and **npm** installed.
2. Install **Hardhat**:
   ```bash
   npm install --save-dev hardhat
   ```
3. Install OpenZeppelin Contracts:
   ```bash
   npm install @openzeppelin/contracts
   ```

### Steps

1. Clone this repository and navigate to the project directory.
2. Configure your Hardhat environment for the Avalanche network.
3. Compile the contract:
   ```bash
   npx hardhat compile
   ```
4. Deploy the contract to Avalanche:
   ```bash
   npx hardhat run scripts/deploy.js --network avalanche
   ```
5. Verify the contract using block explorers.

---

## Contract Functions

### Public Functions
| Function                  | Description                                                 |
|---------------------------|-------------------------------------------------------------|
| `mint(uint256 amount)`    | Mints new tokens (owner-only).                              |
| `burn(uint256 amount)`    | Burns the caller's tokens.                                  |
| `transfer(address recipient, uint256 amount)` | Transfers tokens to another address.                     |
| `redeemItem(uint256 itemId)` | Redeems tokens for an in-game item. Emits a `Redeem` event. |
| `getRedeemedItemCount(address user)` | Returns the count of items redeemed by the specified user.  |

### View Functions
| Function                     | Description                                                   |
|------------------------------|---------------------------------------------------------------|
| `balanceOf(address account)` | Returns the balance of the specified address.                 |
| `redeemedItems(address user, uint256 itemId)` | Checks if a user has redeemed a specific item.           |

---

---

## Security Considerations
1. **Owner Privileges**: Only the contract owner can mint tokens. Keep the owner's private key secure.
2. **Token Burn**: Players can voluntarily reduce their token holdings by burning them.
3. **Gas Optimization**: Efficient mappings are used for redemption tracking.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
---
