// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Token} from "./Token.sol";

contract Factory {
    function createTokenWithTokenPool(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        uint256 initialSupplyChainId_
    ) external returns (address) {
        Token token = Token(_deployToken(name_, symbol_, decimals_, initialSupply_, initialSupplyChainId_));

        // Initialize a token pool ... ie. pseudocode
        //
        // weth.deposit{value: msg.value}();
        // weth.approve(positionManagerAddress, msg.value);
        //
        // address v3Pool = uniswapV3Factory.createPool(...)
        // IUniswapV3Factory(v3Pool).initialize(...)
        //
        // token.approve(positionManagerAddress, initialSupply_);
        //
        // positionManager.mint(...)

        return address(token);
    }

    function createToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        uint256 initialSupplyChainId_
    ) external returns (address) {
        address token = _deployToken(name_, symbol_, decimals_, initialSupply_, initialSupplyChainId_);
        return token;
    }

    function _deployToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        uint256 initialSupplyChainId_
    ) internal returns (address) {
        return address(
            new Token{salt: keccak256("some_salt")}(name_, symbol_, decimals_, initialSupply_, initialSupplyChainId_)
        );
    }
}
