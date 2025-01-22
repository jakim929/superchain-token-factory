// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {Factory} from "../src/Factory.sol";
import {Token} from "../src/Token.sol";

contract FactoryTest is Test {
    Factory public factory;
    uint256 public initialSupply = 1_000_000_000_000_000_000;

    function setUp() public {
        factory = new Factory();
    }

    function test_createTokenWithTokenPool_givesFactoryInitialSupply() public {
        address token = factory.createTokenWithTokenPool("Test", "TEST", 18, initialSupply, block.chainid);

        Token tokenContract = Token(token);
        assertEq(tokenContract.name(), "Test");
        assertEq(tokenContract.symbol(), "TEST");
        assertEq(tokenContract.decimals(), 18);
        assertEq(tokenContract.totalSupply(), initialSupply);
        assertEq(tokenContract.balanceOf(address(factory)), initialSupply);
    }

    function test_createToken_doesntMintNewSupplyOnNonInitialChain() public {
        address token = factory.createTokenWithTokenPool("Test", "TEST", 18, initialSupply, 90000);

        Token tokenContract = Token(token);
        assertEq(tokenContract.name(), "Test");
        assertEq(tokenContract.symbol(), "TEST");
        assertEq(tokenContract.decimals(), 18);
        assertEq(tokenContract.totalSupply(), 0);
        assertEq(tokenContract.balanceOf(address(factory)), 0);
    }

    function test_fork_doesntMintNewSupplyOnNonInitialChain() public {
        // Chain 1
        vm.createSelectFork("mainnet/op");
        uint256 initialSupplyChainId = block.chainid;

        Factory factoryOnChain1 = new Factory{salt: bytes32(0)}();
        address tokenOnChain1 =
            factoryOnChain1.createTokenWithTokenPool("Test", "TEST", 18, initialSupply, initialSupplyChainId);

        // First chain should mint new supply
        Token tokenContractOnChain1 = Token(tokenOnChain1);
        assertEq(tokenContractOnChain1.name(), "Test");
        assertEq(tokenContractOnChain1.symbol(), "TEST");
        assertEq(tokenContractOnChain1.decimals(), 18);
        assertEq(tokenContractOnChain1.totalSupply(), initialSupply);
        assertEq(tokenContractOnChain1.balanceOf(address(factoryOnChain1)), initialSupply);

        // Chain 2
        // Second chain should not mint new supply, but still result in same address
        vm.createSelectFork("mainnet/base");

        Factory factoryOnChain2 = new Factory{salt: bytes32(0)}();
        address tokenOnChain2 = factoryOnChain2.createToken("Test", "TEST", 18, initialSupply, initialSupplyChainId);
        Token tokenContractOnChain2 = Token(tokenOnChain2);
        assertEq(tokenContractOnChain2.name(), "Test");
        assertEq(tokenContractOnChain2.symbol(), "TEST");
        assertEq(tokenContractOnChain2.decimals(), 18);
        assertEq(tokenContractOnChain2.totalSupply(), 0);
        assertEq(tokenContractOnChain2.balanceOf(address(factoryOnChain2)), 0);

        // Same address on different chains
        assertEq(tokenOnChain1, tokenOnChain2);
    }
}
