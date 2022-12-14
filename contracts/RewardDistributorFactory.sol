// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import './interfaces/IRewardDistributorFactory.sol';
import "./RewardDistributor.sol";

contract RewardDistributorFactory is IRewardDistributorFactory {
    function create(
        address provider,
        uint256 reserveBalance,
        address[] calldata recipients,
        uint256[] calldata bips,
        bool[] calldata wrap
    ) external returns (address instance) {
        instance = address(new RewardDistributor(provider, reserveBalance, recipients, bips, wrap));
        emit Created(instance, provider);
    }
}
