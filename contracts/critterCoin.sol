// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract critterCoin is ERC20 {

    address payable gameManager;

    uint256 public initialSupply = 1000000 * 1e18; //Initial 1 mil tokens
    uint256 public valueOfOneToken = 1e13; //0.00001 ethers
    
    constructor() ERC20("Critter Coin", "CRC") {
        _mint(msg.sender, initialSupply);
        gameManager=payable(msg.sender);
    }

    function buyTokens(uint256 amount) public payable returns (bool) {
    uint256 payment = valueOfOneToken * amount; //1e13 * no. of tokens
    require(msg.value == payment, "Incorrect ETH amount sent");
    gameManager.transfer(msg.value);
    _transfer(gameManager, msg.sender, amount*1e18);
    return true;
    }

    function approveContract(address owner ,address spender, uint256 amount) external returns (bool) {
        _approve(owner, spender, amount);
        //Owner allows spender to spend amount critterCoins on behalf of him
        return true;
    }


}
