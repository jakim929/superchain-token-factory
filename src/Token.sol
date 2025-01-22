// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC7802} from "./interfaces/IERC7802.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IERC165} from "./interfaces/IERC165.sol";
import {ERC20} from "solady/tokens/ERC20.sol";

error Unauthorized();

contract Token is IERC7802, ERC20 {
    address internal constant SUPERCHAIN_TOKEN_BRIDGE = 0x4200000000000000000000000000000000000028;

    string private _name;
    string private _symbol;
    uint8 private immutable _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        uint256 initialSupplyChainId_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;

        // Only mint initial supply on a single chain
        if (block.chainid == initialSupplyChainId_) {
            _mint(msg.sender, initialSupply_);
        }
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    // IERC7802 interface
    function crosschainMint(address _to, uint256 _amount) external {
        if (msg.sender != SUPERCHAIN_TOKEN_BRIDGE) revert Unauthorized();

        _mint(_to, _amount);

        emit CrosschainMint(_to, _amount, msg.sender);
    }

    function crosschainBurn(address _from, uint256 _amount) external {
        if (msg.sender != SUPERCHAIN_TOKEN_BRIDGE) revert Unauthorized();

        _burn(_from, _amount);

        emit CrosschainBurn(_from, _amount, msg.sender);
    }

    /// IERC165 interface
    function supportsInterface(bytes4 _interfaceId) public view virtual returns (bool) {
        return _interfaceId == type(IERC7802).interfaceId || _interfaceId == type(IERC20).interfaceId
            || _interfaceId == type(IERC165).interfaceId;
    }
}
