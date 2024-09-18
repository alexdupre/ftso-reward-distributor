// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IRewardDistributorFactory {
    event Created(address indexed instance);

    struct NamedInstance {
        address instance;
        string description;
    }

    function create(
        address[] calldata operatingAddresses,
        uint256[] calldata lowReserves,
        uint256[] calldata highReserves,
        address[] calldata recipients,
        uint256[] calldata bips,
        bool[] calldata wrap,
        bool editable,
        string calldata description
    ) external returns (address instance);
    function count(address owner) external view returns (uint256);
    function get(address owner, uint256 i) external view returns (address instance, string memory description);
    function getAll(address owner) external view returns (NamedInstance[] memory);
    function rename(address instance, string calldata description) external;
    function remove(address instance) external;
}
