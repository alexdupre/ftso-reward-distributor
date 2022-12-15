// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IRewardDistributorFactory {
    event Created(address indexed instance, address indexed provider);

    struct NamedInstance {
        address instance;
        string description;
    }

    function create(
        address provider,
        uint256 reserveBalance,
        address[] calldata recipients,
        uint256[] calldata bips,
        bool[] calldata wrap,
        bool editable,
        string calldata description
    ) external returns (address instance);
    function count(address owner) external view returns (uint256);
    function get(address owner, uint256 i) external view returns (address instance, string memory description);
    function getAll(address owner) external view returns (NamedInstance[] memory);
    function rename(address instance, string calldata description) external returns (bool);
    function remove(address instance) external returns (bool);
}
