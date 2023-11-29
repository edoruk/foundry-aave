// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        string name;
        address wethToken;
        address poolAddressesProvider;
        uint256 privateKey;
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
                wethToken: 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9,
                poolAddressesProvider: 0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A,
                privateKey: vm.envUint("PRIVATE_KEY_SEP")
            });
    }

    function run() external {}
}
