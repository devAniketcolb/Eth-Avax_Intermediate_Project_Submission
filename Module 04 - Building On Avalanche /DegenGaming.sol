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
