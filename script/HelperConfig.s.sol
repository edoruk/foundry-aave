// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        string name;
        address wethGateway;
        address linkAddress;
        address poolAddressesProvider;
        uint256 privateKey;
        address accountAddress;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        }
    }

    function getSepoliaConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                name: "sepolia",
                wethGateway: 0x387d311e47e80b498169e6fb51d3193167d89F7D,
                linkAddress: 0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5,
                poolAddressesProvider: 0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A,
                privateKey: vm.envUint("PRIVATE_KEY_SEP"),
                accountAddress: vm.envAddress("ACCOUNT_ADDRESS_SEP")
            });
    }

    function run() external {}
}
//wrapped token gateway v3 - 0x387d311e47e80b498169e6fb51d3193167d89F7D
//WETHGateway -> aavedocs | aWETH -> metamask or aave application page

// Mintable Reserves and Rewards
// ┌────────────────────────────────┬──────────────────────────────────────────────┐
// │            (index)             │                   address                    │
// ├────────────────────────────────┼──────────────────────────────────────────────┤
// │ DAI-TestnetMintableERC20-Aave  │ '0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357' │
// │ LINK-TestnetMintableERC20-Aave │ '0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5' │
// │ USDC-TestnetMintableERC20-Aave │ '0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8' │
// │ WBTC-TestnetMintableERC20-Aave │ '0x29f2D40B0605204364af54EC677bD022dA425d03' │
// │ WETH-TestnetMintableERC20-Aave │ '0xC558DBdd856501FCd9aaF1E62eae57A9F0629a3c' │
// │ USDT-TestnetMintableERC20-Aave │ '0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0' │
// │ AAVE-TestnetMintableERC20-Aave │ '0x88541670E55cC00bEEFD87eB59EDd1b7C511AC9a' │
// │ EURS-TestnetMintableERC20-Aave │ '0x6d906e526a4e2Ca02097BA9d0caA3c382F52278E' │
// └────────────────────────────────┴──────────────────────────────────────────────┘
