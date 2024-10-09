// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dex is ERC20{ 

    address tokenAddress;

    constructor(address _token) ERC20("Dex-Lp", "DEXLP"){
        require(_token != address(0), "Zero address!");
        tokenAddress = _token;
    }

    // Public and External functions 
    function addLiquidity(uint256 _amount) public payable returns(uint256) {
        
        uint256 amountToMint;
        uint256 tokenReserve = getReserves();
        uint256 ethReserve   = address(this).balance;

        if(tokenReserve == 0) {
            IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
            
            amountToMint = ethReserve;
            _mint(msg.sender, amountToMint);
            return amountToMint;
        } 

        uint256 ethAmountBeforeFunctionCall = address(this).balance - msg.value;
        uint256 correctAmountOfTokenToAdd = (msg.value * tokenReserve) / ethAmountBeforeFunctionCall;

        require(_amount >= correctAmountOfTokenToAdd, "Not enough tokens");

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);

        amountToMint = (totalSupply() * msg.value) / ethAmountBeforeFunctionCall; 
        _mint(msg.sender, amountToMint);
        return amountToMint;

    }

    // View functions 
    function getReserves() public view returns(uint256 balance) {
        balance = IERC20(tokenAddress).balanceOf(address(this));
    }

    function getEthBalance() public view returns(uint256 balance) {
        balance = address(this).balance;
    }


}
