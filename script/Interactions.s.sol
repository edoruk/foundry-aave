// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IPoolAddressesProvider} from "../src/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "../src/interfaces/IPool.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IWETHGateway} from "../src/interfaces/IWETHGateway.sol";
import {IPriceOracleGetter} from "../src/interfaces/IPriceOracleGetter.sol";

contract AaveSupplyLink is Script {
    string tokenName;

    string name;
    //address wethAddress;
    address linkAddress;
    address poolAddressesProvider;
    uint256 privateKey;
    address accountAddress;
    IPool public immutable pool;
    IERC20 linkToken;
    //IWETH wethToken;
    uint256 AMOUNT;

    constructor() {
        HelperConfig helperConfig = new HelperConfig();
        (
            string memory _name,
            ,
            //address _wethAddress,
            address _linkAddress,
            address _poolAddressesProvider,
            uint256 _privateKey,
            address _accountAddress
        ) = helperConfig.activeNetworkConfig();

        name = _name;
        //wethAddress = _wethAddress;
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
        console.log("Allowance is: %e", allowance);
        console.log("Depositting...");
        supplyLiquidity(linkAddress, AMOUNT);
        console.log("%e ETH Link supplied.", AMOUNT);
        vm.stopBroadcast();
    }
}

contract AaveGetUserData is Script {
    address poolAddressesProvider;
    uint256 privateKey;
    address accountAddress;

    IPool public immutable pool;

    uint256 totalCollateralBase;
    uint256 totalDebtBase;
    uint256 availableBorrowsBase;
    uint256 currentLiquidationThreshold;
    uint256 ltv;
    uint256 healthFactor;

    constructor() {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            ,
            address _poolAddressesProvider,
            uint256 _privateKey,
            address _accountAddress
        ) = helperConfig.activeNetworkConfig();

        poolAddressesProvider = _poolAddressesProvider;
        privateKey = _privateKey;
        accountAddress = _accountAddress;

        IPoolAddressesProvider provider = IPoolAddressesProvider(
            poolAddressesProvider
        );
        pool = IPool(provider.getPool());
    }

    function getUserAccountData(address _userAddress) public {
        (
            uint256 _totalCollateralBase,
            uint256 _totalDebtBase,
            uint256 _availableBorrowsBase,
            uint256 _currentLiquidationThreshold,
            uint256 _ltv,
            uint256 _healthFactor
        ) = pool.getUserAccountData(_userAddress);
        totalCollateralBase = _totalCollateralBase;
        totalDebtBase = _totalDebtBase;
        availableBorrowsBase = _availableBorrowsBase;
        currentLiquidationThreshold = _currentLiquidationThreshold;
        ltv = _ltv;
        healthFactor = _healthFactor;
    }

    function run() external {
        vm.startBroadcast(privateKey);
        getUserAccountData(accountAddress);
        console.log("----ACCOUNT DETAILS----");
        console.log("TCB: %d", (totalCollateralBase));
        console.log("ABB: %e", availableBorrowsBase);
        console.log("TDB: %d", totalDebtBase);
        console.log("CLT: %d", currentLiquidationThreshold);
        console.log("ltv: %d", ltv);
        console.log("HF: %d", healthFactor);
        console.log("------------------------");
        vm.stopBroadcast();
    }
}

contract AaveBorrowLink is Script {
    HelperConfig helperConfig;

    address linkAddress;
    address poolAddressesProvider;
    uint256 privateKey;
    address accountAddress;

    address priceOracleAddress;
    IPriceOracleGetter priceOracle;

    IPool pool;
    uint256 totalCollateralBase;
    uint256 totalDebtBase;
    uint256 availableBorrowsBase;
    uint256 currentLiquidationThreshold;
    uint256 ltv;
    uint256 healthFactor;

    constructor() {
        helperConfig = new HelperConfig();
        (
            ,
            ,
            address _linkAddress,
            address _poolAddressesProvider,
            uint256 _privateKey,
            address _accountAddress
        ) = helperConfig.activeNetworkConfig();

        linkAddress = _linkAddress;
        poolAddressesProvider = _poolAddressesProvider;
        privateKey = _privateKey;
        accountAddress = _accountAddress;

        IPoolAddressesProvider provider = IPoolAddressesProvider(
            poolAddressesProvider
        );
        pool = IPool(provider.getPool());
        priceOracleAddress = provider.getPriceOracle();
        priceOracle = IPriceOracleGetter(priceOracleAddress);
    }

    function getBorrowable(uint256 borrowable) public view returns (uint256) {
        uint256 price = priceOracle.getAssetPrice(linkAddress);
        console.log("Price of link token is: %d$", price / 100000000);
        uint256 amountLinkToBorrow = price * ((borrowable * 95) / 100);
        console.log("Link Amount to borrow: %d ", amountLinkToBorrow);
        return amountLinkToBorrow;
    }

    function getUserAccountData(address _userAddress) public {
        (
            uint256 _totalCollateralBase,
            uint256 _totalDebtBase,
            uint256 _availableBorrowsBase,
            uint256 _currentLiquidationThreshold,
            uint256 _ltv,
            uint256 _healthFactor
        ) = pool.getUserAccountData(_userAddress);
        totalCollateralBase = _totalCollateralBase;
        totalDebtBase = _totalDebtBase;
        availableBorrowsBase = _availableBorrowsBase;
        currentLiquidationThreshold = _currentLiquidationThreshold;
        ltv = _ltv;
        healthFactor = _healthFactor;
    }

    function aaveBorrow(
        address _asset,
        uint256 _amount,
        uint256 _iRateMode,
        address _onBehalfOf
    ) public {
        console.log("Ready to borrow...");
        pool.borrow(_asset, _amount, _iRateMode, 0, _onBehalfOf);
    }

    function run() external {
        vm.startBroadcast(privateKey);
        getUserAccountData(accountAddress);
        uint256 borrowAmount = (availableBorrowsBase * 95) / 100;
        aaveBorrow(linkAddress, borrowAmount, 2, accountAddress);
        console.log("Borrowed: ", borrowAmount);
        vm.stopBroadcast();
    }
}

contract AaveRepayLink is Script {
    HelperConfig helperConfig;

    address linkAddress;
    address poolAddressesProvider;
    uint256 privateKey;
    address accountAddress;
    IPool pool;
    IERC20 linkToken;

    uint256 totalDebtBase;

    constructor() {
        helperConfig = new HelperConfig();
        (
            ,
            ,
            address _linkAddress,
            address _poolAddressesProvider,
            uint256 _privateKey,
            address _accountAddress
        ) = helperConfig.activeNetworkConfig();

        linkAddress = _linkAddress;
        poolAddressesProvider = _poolAddressesProvider;
        privateKey = _privateKey;
        accountAddress = _accountAddress;

        IPoolAddressesProvider provider = IPoolAddressesProvider(
            poolAddressesProvider
        );
        pool = IPool(provider.getPool());
        linkToken = IERC20(linkAddress);

        (, uint256 _totalDebtBase, , , , ) = pool.getUserAccountData(
            accountAddress
        );

        totalDebtBase = _totalDebtBase;
    }

    function approveAndRepay(
        address _poolContractAddress,
        address _asset,
        uint256 _rateMode,
        address _onBehalfOf
    ) internal {
        linkToken.approve(_poolContractAddress, type(uint256).max);
        pool.repay(_asset, type(uint256).max, _rateMode, _onBehalfOf);
    }

    function run() external {
        vm.startBroadcast(privateKey);
        approveAndRepay(address(pool), linkAddress, 2, accountAddress);
        console.log("Repaid!");
        vm.stopBroadcast();
    }
}

contract AaveWithdrawLink is Script {
    HelperConfig helperConfig;
    IPool pool;

    address linkAddress;
    address poolAddressesProvider;
    uint256 privateKey;
    address accountAddress;

    constructor() {
        helperConfig = new HelperConfig();
        (
            ,
            ,
            address _linkAddress,
            address _poolAddressesProvider,
            uint256 _privateKey,
            address _accountAddress
        ) = helperConfig.activeNetworkConfig();

        linkAddress = _linkAddress;
        poolAddressesProvider = _poolAddressesProvider;
        privateKey = _privateKey;
        accountAddress = _accountAddress;

        IPoolAddressesProvider provider = IPoolAddressesProvider(
            poolAddressesProvider
        );
        pool = IPool(provider.getPool());
    }

    function withdrawlLiquidity(
        address _tokenAddress,
        uint256 _amount,
        address _to
    ) internal returns (uint256) {
        address asset = _tokenAddress;
        uint256 amount = _amount;
        address to = _to;

        return pool.withdraw(asset, amount, to);
    }

    function run() external {
        vm.startBroadcast();
        withdrawlLiquidity(linkAddress, type(uint).max, accountAddress);
        vm.stopBroadcast();
    }
}

contract AaveWETHGateway is Script {
    address wethGatewayAddress;
    address poolAddressesProvider;
    uint256 privateKey;
    address accountAddress;
    IPool pool;
    IERC20 aWethToken;
    IWETHGateway wethGateway;
    uint256 constant AMOUNT = 0.1 ether;

    constructor() {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            address _wethGatewayAddress,
            ,
            address _poolAddressesProviderAddress,
            uint256 _privateKey,
            address _accountAddress
        ) = helperConfig.activeNetworkConfig();

        wethGatewayAddress = _wethGatewayAddress;
        poolAddressesProvider = _poolAddressesProviderAddress;
        privateKey = _privateKey;
        accountAddress = _accountAddress;

        IPoolAddressesProvider provider = IPoolAddressesProvider(
            poolAddressesProvider
        );
        pool = IPool(provider.getPool());

        aWethToken = IERC20(0x5b071b590a59395fE4025A0Ccc1FcC931AAc1830); //aWETH address from metamask
        wethGateway = IWETHGateway(wethGatewayAddress);
    }

    function depositETH(
        address _pool,
        address _onBehalfOf,
        uint256 _amount
    ) internal {
        wethGateway.depositETH{value: _amount}(_pool, _onBehalfOf, 0);
    }

    function approveAndWithdrawETH(
        address _wethGateway,
        address _pool,
        address _onBehalfOf
    ) public {
        aWethToken.approve(_wethGateway, type(uint).max);
        console.log("Approved!");

        wethGateway.withdrawETH(_pool, type(uint).max, _onBehalfOf);
        console.log("Withdrawn.");
    }

    function run() external {
        vm.startBroadcast(privateKey);
        //depositETH(address(pool), accountAddress, AMOUNT);
        approveAndWithdrawETH(
            address(wethGateway),
            address(pool),
            accountAddress
        );
        vm.stopBroadcast();
    }
}

// aritmetic overflow or underflow occured because of wrong addresses of aWeth and wethgateway
