// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IPoolAddressesProvider} from "../src/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "../src/interfaces/IPool.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {WETHGetAway} from "../src/interfaces/IWETHGetAway.sol";

contract GetSupply is Script {
    address payable owner;
    string name;
    address wethToken;
    address linkAddress;
    address poolAddressesProvider;
    uint256 privateKey;
    address accountAddress;
    IPool public immutable pool;
    IERC20 link;
    IWETH weth;
    uint256 constant AMOUNT = 0.01 ether;

    constructor() {
        HelperConfig helperConfig = new HelperConfig();
        (
            string memory _name,
            address _wethToken,
            address _linkAddress,
            address _poolAddressesProvider,
            uint256 _privateKey,
            address _accountAddress
        ) = helperConfig.activeNetworkConfig();

        name = _name;
        wethToken = _wethToken;
        linkAddress = _linkAddress;
        poolAddressesProvider = _poolAddressesProvider;
        privateKey = _privateKey;
        accountAddress = _accountAddress;

        IPoolAddressesProvider provider = IPoolAddressesProvider(
            poolAddressesProvider
        );
        pool = IPool(provider.getPool());
        owner = payable(msg.sender);
        link = IERC20(linkAddress);
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
        return link.approve(_poolContractAddress, _amount);
    }

    function allowanceLINK(
        address _poolContractAddress
    ) public view returns (uint256) {
        return link.allowance(address(accountAddress), _poolContractAddress);
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    // function getUSDC() public {
    //     weth = IWETH(link);
    //     weth.deposit{value: AMOUNT}();
    // }

    // function getPool() public view returns (IPool) {
    //     address pool = provider.getPool();

    //     return pool;
    // }

    function run() external {
        vm.startBroadcast(privateKey);
        bool success = approveLINK(AMOUNT, address(pool));
        console.log("Approving is: ", success);
        uint256 allowance = allowanceLINK(address(pool));
        console.log("Allowance is: ", allowance);
        (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        ) = getUserAccountData(accountAddress);
        console.log("HF: ", healthFactor, "availableb: ", availableBorrowsBase);
        supplyLiquidity(linkAddress, AMOUNT);
        console.log("Link supplied.");
        // getUSDC();
        // IPool pool = getPool();
        // console.log("getPool successful with address: ", address(pool));

        // bool success = ERC20.approve(address(pool), AMOUNT);
        // console.log("approved: ", success);
        // console.log("Depositting...");
        // pool.supply(address(ERC20), AMOUNT, accountAddress, 0);
        // console.log("Supplied!");
        vm.stopBroadcast();
    }
}

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

        //approveERC20(address(pool), AMOUNT);

        console.log("Depositting...");
        wethGateaway.depositETH{value: AMOUNT}(
            address(pool),
            accountAddress,
            0
        );
        console.log("Depositted!");
        //pool.supply(address(ERC20), 0.001 ether, accountAddress, 0);

        vm.stopBroadcast();
    }
}
