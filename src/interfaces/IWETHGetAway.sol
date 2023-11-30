// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

interface WETHGetAway {
    function authorizePool(address pool) external;

    function borrowETH(
        address pool,
        uint256 amount,
        uint256 interesRateMode,
        uint16 referralCode
    ) external payable;

    function depositETH(
        address pool,
        address onBehalfOf,
        uint16 referralCode
    ) external payable;

    function emergencyEtherTransfer(address to, uint256 amount) external;

    function emergencyTokenTransfer(
        address token,
        address to,
        uint256 amount
    ) external;

    function getWETHAddress() external view returns (address);

    function owner() external view returns (address);

    function renounceOwnership() external;

    function repayETH(
        address pool,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external;

    function transferOwnership(address newOwner) external;

    function withdrawETH(address pool, uint256 amount, address to) external;

    function withdrawETHWithPermit(
        address pool,
        uint256 amount,
        address to,
        uint256 deadline,
        uint8 permitV,
        bytes32 permitR,
        bytes32 permitS
    ) external;
}
