// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IRewardDistributor {
    event TotalRewards(uint256 timestamp, uint256 amount);
    event Reward(address indexed recipient, uint256 amount);
    event Refill(address indexed recipient, uint256 amount);

    struct OperatingAddress {
        address payable recipient;
        uint256 lowReserve;
        uint256 highReserve;
    }

    struct Recipient {
        address recipient;
        uint256 bips;
        bool wrap;
    }

    function operatingAddresses(uint256 i) external view returns (address payable recipient, uint256 lowReserve, uint256 highReserve);
    function operatingAddressesCount() external view returns (uint256);
    function operatingAddressesAll() external view returns (OperatingAddress[] memory);

    function recipients(uint256 i) external view returns (address recipient, uint256 bips, bool wrap);
    function recipientsCount() external view returns (uint256);
    function recipientsAll() external view returns (Recipient[] memory);

    function owner() external view returns (address);

    function replaceOwner(address _owner) external;
    function destroy() external;

    function addOrReplaceOperatingAddress(address _recipient, uint256 _lowReserve, uint256 _highReserve) external;
    function removeOperatingAddress(address _recipient) external;
    function replaceOperatingAddresses(address[] calldata _recipients, uint256[] calldata _lowReserves, uint256[] calldata _highReserves) external;
    function replaceRecipients(address[] calldata _recipients, uint256[] calldata _bips, bool[] calldata _wrap) external;
}
