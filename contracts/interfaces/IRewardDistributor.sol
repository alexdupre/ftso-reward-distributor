// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IRewardDistributor {
    event TotalRewards(uint256 timestamp, uint256 amount);
    event Reward(address indexed recipient, uint256 amount);
    event Refill(uint256 amount);

    struct Recipient {
        address recipient;
        uint256 bips;
        bool wrap;
    }

    function provider() external view returns (address payable);
    function reserveBalance() external view returns (uint256);
    function recipients(uint256 i) external view returns (address recipient, uint256 bips, bool wrap);
    function recipientsCount() external view returns (uint256);
    function recipientsAll() external view returns (Recipient[] memory);
    function owner() external view returns (address);

    function replaceOwner(address _owner) external;
    function destroy() external;
    function replaceReserveBalance(uint256 _reserveBalance) external;
    function replaceRecipients(address[] calldata _recipients, uint256[] calldata _bips, bool[] calldata _wrap) external;
}
