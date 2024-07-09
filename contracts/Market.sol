// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Erc20.sol";
import "./Erc721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Market {
    address public currency;    // contract address of ERC20 token
    address public goods;       // contract address of ERC721 token
    mapping (uint256 => uint256) priceOf; // price of ERC721 tokens

    constructor(
        address erc20TokenContract,
        address erc721TokenContract
    ) {
        currency = erc20TokenContract;
        goods = erc721TokenContract;
    }

    function setPrice(
        uint256 tokenId, 
        uint256 price
    ) public returns(bool) {
        require(
            IERC721(goods).ownerOf(tokenId) == msg.sender ||
            IERC721(goods).getApproved(tokenId) == msg.sender,
            "only owner can set the price"
        );

        priceOf[tokenId] = price;
        return true;
    }

    function buyToken(
        uint256 tokenId // the token that msg.sender wants to buy
    ) public returns (bool) {
        require(
            priceOf[tokenId] != 0,
            "token is not on market now"
        );
        address tokenOwner = IERC721(goods).ownerOf(tokenId);

        bool rv = IERC20(currency).transfer(tokenOwner, priceOf[tokenId]);
        if(!rv){
            revert("payment failed");
        }

        IERC721(goods).transferFrom(tokenOwner, msg.sender, tokenId);
        return true;
    }
}