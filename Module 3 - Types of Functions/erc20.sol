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
