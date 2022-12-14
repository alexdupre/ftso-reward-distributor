// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IRewardDistributorFactory {
    event Created(address indexed instance, address indexed provider);

    function create(
        address provider,
        uint256 reserveBalance,
        address[] calldata recipients,
        uint256[] calldata bips,
        bool[] calldata wrap
    ) external returns (address instance);
}
