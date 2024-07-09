// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Tokenbank.sol";

contract BaseERC20 is IERC20{
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    constructor() {
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000000000000000000000;

        balances[msg.sender] = totalSupply;  
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if(balances[msg.sender] < _value)
            revert("ERC20: transfer amount exceeds balance");

        balances[_to] += _value;
        balances[msg.sender] -= _value;

        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }

    // Return whether the addr is a contract by checking its execution code length.
    function isContract(address addr) internal view returns(bool) {
        return addr.code.length > 0;
    }

    function transferWithCallback(
        address recipient,
        uint256 amount
    ) external returns (bool) {
        bool rv1 = transfer(recipient, amount);
        if(!rv1)
            revert("transfer failed");

        if(isContract(recipient)){
            bool rv2 = TokenBank(recipient).tokensReceived(msg.sender, amount);
            require(rv2, "No tokens received");
        }

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if(balances[_from] < _value)
            revert("ERC20: transfer amount exceeds balance");
        if(allowances[_from][msg.sender] < _value)
            revert("ERC20: transfer amount exceeds allowance");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value); 
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] += _value;

        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {     
        return allowances[_owner][_spender];
    }
}