// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Erc20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenBank {
    mapping(address => uint256) balances;

    function deposit(
        address token, 
        uint256 amount
    ) public returns (bool) {
        bool rv1 = IERC20(token).approve(address(this), amount);
        if(!rv1)
            revert("approve in token failed");

        bool rv2 = IERC20(token).transfer(address(this), amount);
        if(rv2){
            balances[msg.sender] += amount;
            return true;
        } else {
            revert("transfer in token failed");
        }
    }

    function withdraw(
        address token,
        uint256 amount
    ) external returns (bool) {
        require(amount < balances[msg.sender], "no enough money in bank!");
        bool rv = IERC20(token).transfer(msg.sender, amount);

        if(rv){
            return true;
        } else {
            revert("transfer in token failed");
        }
    }

    function tokensReceived(
        address account,
        uint256 amount
    ) external returns (bool) {
        balances[account] += amount;

        return true;
    }
}