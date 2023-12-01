// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IPoolAddressesProvider} from "../src/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "../src/interfaces/IPool.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {WETHGetAway} from "../src/interfaces/IWETHGetAway.sol";

contract AaveSupply is Script {
    string tokenName;

    string name;
    address wethAddress;
    address linkAddress;
    address poolAddressesProvider;
    uint256 privateKey;
    address accountAddress;
    IPool public immutable pool;
    IERC20 linkToken;
    IWETH wethToken;
    uint256 AMOUNT;

    constructor() {
        HelperConfig helperConfig = new HelperConfig();
        (
            string memory _name,
            address _wethAddress,
            address _linkAddress,
            address _poolAddressesProvider,
            uint256 _privateKey,
            address _accountAddress
        ) = helperConfig.activeNetworkConfig();

        name = _name;
        wethAddress = _wethAddress;
        linkAddress = _linkAddress;
        poolAddressesProvider = _poolAddressesProvider;
        privateKey = _privateKey;
        accountAddress = _accountAddress;

        IPoolAddressesProvider provider = IPoolAddressesProvider(
            poolAddressesProvider
        );
        pool = IPool(provider.getPool());
        linkToken = IERC20(linkAddress);
    }

    function supplyLiquidity(address _tokenAddress, uint256 _amount) public {
        address asset = _tokenAddress;
        uint256 amount = _amount;
        address onBehalfOf = address(accountAddress);
        uint16 referralCode = 0;

        pool.supply(asset, amount, onBehalfOf, referralCode);
    }

    function withdrawlLiquidity(
        address _tokenAddress,
        uint256 _amount
    ) external returns (uint256) {
        address asset = _tokenAddress;
        uint256 amount = _amount;
        address to = address(this);

        return pool.withdraw(asset, amount, to);
    }

    function getUserAccountData(
        address _userAddress
    )
        public
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        )
    {
        return pool.getUserAccountData(_userAddress);
    }

    function approveLINK(
        uint256 _amount,
        address _poolContractAddress
    ) public returns (bool) {
        return linkToken.approve(_poolContractAddress, _amount);
    }

    function allowanceLINK(
        address _poolContractAddress
    ) public view returns (uint256) {
        return
            linkToken.allowance(address(accountAddress), _poolContractAddress);
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function run(uint256 _amount) external {
        AMOUNT = _amount;
        vm.startBroadcast(privateKey);
        bool success = approveLINK(AMOUNT, address(pool));
        console.log("Approving is: ", success);
        uint256 allowance = allowanceLINK(address(pool));
        console.log("Allowance is: ", allowance);

        console.log("Depositting...");
        supplyLiquidity(linkAddress, AMOUNT);
        console.log(AMOUNT, " Link is supplied.");
        (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        ) = getUserAccountData(accountAddress);
        console.log("----ACCOUNT DETAILS----");
        console.log("TCB: %d", totalCollateralBase);
        console.log("ABB: %d", availableBorrowsBase);
        console.log("TDB: %d", totalDebtBase);
        console.log("CLT: %d", currentLiquidationThreshold);
        console.log("ltv: %d", ltv);
        console.log("HF: %d", healthFactor);
        console.log("------------------------");

        vm.stopBroadcast();
    }
}

contract AaveWETHGateway is Script {
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
            ,
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
        ERC20 = IERC20(wethToken);
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

    function approveERC20(address _spender, uint256 _amount) public {
        console.log("Approving ERC20...");
        //vm.startBroadcast(privateKey);
        bool success = ERC20.approve(_spender, _amount);
        //vm.stopBroadcast();
        console.log("Approving is ", success);
    }

    function run() external {
        vm.startBroadcast(privateKey);
        IPool pool = getPool();
        console.log("getPool successful with address: ", address(pool));
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
