// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IPoolAddressesProvider} from "../src/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "../src/interfaces/IPool.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {WETHGetAway} from "../src/interfaces/IWETHGetAway.sol";

// contract GetWETH is Script {
//     string name;
//     address wethToken;
//     uint256 privateKey;
//     uint256 constant AMOUNT = 0.01 ether;

//     constructor() {
//         HelperConfig helperConfig = new HelperConfig();
//         (
//             string memory _name,
//             address _wethToken,
//             ,
//             uint256 _privateKey,

//         ) = helperConfig.activeNetworkConfig();

//         name = _name;
//         wethToken = _wethToken;
//         privateKey = _privateKey;
//     }

//     function getWETH() public {
//         IWETH weth = IWETH(wethToken);
//         weth.deposit{value: AMOUNT}();
//     }

//     function run() external {
//         vm.startBroadcast(privateKey);
//         getWETH();
//         vm.stopBroadcast();
//     }
//}

contract Aave is Script {
    string name;
    address wethToken;
    address poolAddressesProvider;
    uint256 privateKey;
    address accountAddress;

    //IWETH weth;
    IERC20 ERC20;
    WETHGetAway wethGateaway;
    uint256 constant AMOUNT = 0.001 ether;

    constructor() {
        HelperConfig helperConfig = new HelperConfig();

        (
            string memory _name,
            address _wethToken,
            address _poolAddressesProviderAddress,
            uint256 _privateKey,
            address _accountAddress
        ) = helperConfig.activeNetworkConfig();

        name = _name;
        wethToken = _wethToken;
        poolAddressesProvider = _poolAddressesProviderAddress;
        privateKey = _privateKey;
        accountAddress = _accountAddress;

        //weth = IWETH(wethToken);
        //ERC20 = IERC20(wethToken);
        wethGateaway = WETHGetAway(wethToken);
    }

    function getPool() public view returns (IPool) {
        IPoolAddressesProvider provider = IPoolAddressesProvider(
            poolAddressesProvider
        );
        address poolAddress = provider.getPool();
        IPool pool = IPool(poolAddress);
        return pool;
    }

    // function approveERC20(address _spender, uint256 _amount) public {
    //     console.log("Approving ERC20...");
    //     //vm.startBroadcast(privateKey);
    //     bool success = ERC20.approve(_spender, _amount);
    //     //vm.stopBroadcast();
    //     console.log("Approving is ", success);
    // }

    function run() external {
        vm.startBroadcast(privateKey);
        IPool pool = getPool();
        console.log("getPool successful with address: ", address(pool));
        //approveERC20(address(pool), AMOUNT);
        console.log("Depositting...");
        wethGateaway.depositETH{value: AMOUNT}(
            address(pool),
            accountAddress,
            0
        );
        console.log("Depositted!");
        vm.stopBroadcast();
    }
}
