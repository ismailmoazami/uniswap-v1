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

    function removeLiquidity(uint256 _amountOfLp) public returns(uint256, uint256) {
        
        require(_amountOfLp > 0);
        
        uint256 tokenReserve  = getReserves();
        uint256 ethReserve    = address(this).balance; 
        uint256 lpTotalSupply = totalSupply();

        uint256 ethToWithdraw   = (ethReserve * _amountOfLp) / lpTotalSupply;
        uint256 tokenToWithdraw = (tokenReserve * _amountOfLp) / lpTotalSupply;

        _burn(address(this), _amountOfLp);
        IERC20(tokenAddress).transfer(msg.sender, tokenToWithdraw);
        (bool success, ) = payable(msg.sender).call{value: ethToWithdraw}("");
        require(success, "Transfer failed!");
        return(ethToWithdraw, tokenToWithdraw);

    }

    function swapEthToToken(uint256 _minTokenToReceive) public payable {
        require(msg.value > 0, "Zero value!");
        uint256 tokenToReceive = getOutputAmountFromSwap(msg.value, address(this).balance, getReserves());

        require(tokenToReceive >= _minTokenToReceive, "Token amount is less than the minimum"); 
        IERC20(tokenAddress).transfer(msg.sender, tokenToReceive);

    }

    function swapTokenToEth(uint256 _amountOfToken, uint256 _minEthToReceive) public {
        require(_amountOfToken > 0, "Zero value!");
        uint256 ethToReceive = getOutputAmountFromSwap(_amountOfToken, getReserves(), address(this).balance);

        require(ethToReceive >= _minEthToReceive, "Ether amount is less than the minimum"); 
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amountOfToken);
        (bool success, ) = payable(msg.sender).call{value: ethToReceive}("");
        require(success, "Transfer failed!");
        
    }

    // View and Pure functions 
    function getReserves() public view returns(uint256 balance) {
        balance = IERC20(tokenAddress).balanceOf(address(this));
    }

    function getEthBalance() public view returns(uint256 balance) {
        balance = address(this).balance;
    }

    function getOutputAmountFromSwap(uint256 _inputAmount, uint256 _inputReserve, uint256 _outputReserve) public pure returns(uint256) {
        
        uint256 inputAmountWithFees = _inputAmount * 995; // 0.5 % fee 
        uint256 numerator = inputAmountWithFees * _outputReserve;
        uint256 denominator = (_inputReserve * 1000) + inputAmountWithFees;
        return numerator / denominator;
    }


}
