// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        string name;
        address wethToken;
        address link;
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
                wethToken: 0x387d311e47e80b498169e6fb51d3193167d89F7D,
                link: 0xf8Fb3713D459D7C1018BD0A49D19b4C44290EBE5,
                poolAddressesProvider: 0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A,
                privateKey: vm.envUint("PRIVATE_KEY_SEP"),
                accountAddress: vm.envAddress("ACCOUNT_ADDRESS_SEP")
            });
    }

    function run() external {}
}
//wrapped token gateway v3 - 0x387d311e47e80b498169e6fb51d3193167d89F7D
// link - 0x779877A7B0D9E8603169DdbD7836e478b4624789
