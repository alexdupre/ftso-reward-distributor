// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./interfaces/IRewardDistributor.sol";
import "./FlareLibrary.sol";

contract RewardDistributor is IRewardDistributor {
    ProviderAddress[] public providerAddresses;
    Recipient[] public recipients;

    address public owner;

    bool private locked;

    modifier lock() {
        require(!locked, "Re-entrancy detected");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner() {
        require(owner != address(0) && owner == msg.sender, "Forbidden");
        _;
    }

    constructor(
        address[] memory _providerAddresses,
        uint256[] memory _reserveBalances,
        address[] memory _recipients,
        uint256[] memory _bips,
        bool[] memory _wrap,
        address _owner
    ) {
        uint256 len = _providerAddresses.length;
        require(len > 0, "No provider address");
        require(_reserveBalances.length == len, "Reserve balances length mismatch");
        len = _recipients.length;
        require(_bips.length == len, "Bips length mismatch");
        require(_wrap.length == len, "Wrap length mismatch");
        owner = _owner;
        addProviderAddresses(_providerAddresses, _reserveBalances);
        addRecipients(_recipients, _bips, _wrap);
    }

    function addProviderAddresses(address[] memory _recipients, uint256[] memory _reserves) private {
        for (uint256 i; i < _recipients.length; i++) {
            ProviderAddress storage providerAddress = providerAddresses.push();
            providerAddress.recipient = payable(_recipients[i]);
            providerAddress.reserve = _reserves[i];
        }
    }

    function addRecipients(address[] memory _recipients, uint256[] memory _bips, bool[] memory _wrap) private {
        uint256 total;
        for (uint256 i; i < _recipients.length; i++) {
            Recipient storage recipient = recipients.push();
            recipient.recipient = _recipients[i];
            recipient.bips = _bips[i];
            recipient.wrap = _wrap[i];
            total += _bips[i];
        }
        require(total == 100_00, "Sum is not 100%");
    }

    function providerAddressesCount() external view returns (uint256) {
        return providerAddresses.length;
    }

    function providerAddressesAll() external view returns (ProviderAddress[] memory) {
        return providerAddresses;
    }

    function recipientsCount() external view returns (uint256) {
        return recipients.length;
    }

    function recipientsAll() external view returns (Recipient[] memory) {
        return recipients;
    }

    receive() external payable lock {
        uint256 remainingAmount = msg.value;
        emit TotalRewards(block.timestamp, remainingAmount);
        for (uint256 i; i < providerAddresses.length && remainingAmount > 0; i++) {
            ProviderAddress storage p = providerAddresses[i];
            uint256 currentBalance = p.recipient.balance;
            if (currentBalance < p.reserve) {
                uint256 refillAmount = p.reserve - currentBalance;
                if (refillAmount > remainingAmount) refillAmount = remainingAmount;
                (bool success,) = p.recipient.call{value: refillAmount}("");
                require(success, "Unable to refill provider's account");
                emit Refill(p.recipient, refillAmount);
                remainingAmount -= refillAmount;
            }
        }
        if (remainingAmount > 0) {
            uint256 remainingBips = 100_00;
            for (uint256 i; i < recipients.length; i++) {
                Recipient storage r = recipients[i];
                uint256 shareAmount =
                    (remainingBips == r.bips) ? remainingAmount : (remainingAmount * r.bips) / remainingBips;
                if (r.wrap) {
                    FlareLibrary.getWNat().depositTo{value: shareAmount}(r.recipient);
                } else {
                    (bool success,) = r.recipient.call{value: shareAmount}("");
                    require(success, "Unable to send reward");
                }
                emit Reward(r.recipient, shareAmount);
                remainingAmount -= shareAmount;
                remainingBips -= r.bips;
            }
        }
    }

    function replaceOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    function destroy() external onlyOwner {
        selfdestruct(payable(owner));
    }

    function replaceProviderAddresses(address[] calldata _recipients, uint256[] calldata _reserves)
        external
        onlyOwner
    {
        require(providerAddresses.length > 0, "No provider address");
        for (uint256 i = providerAddresses.length; i > 0; i--) {
            providerAddresses.pop();
        }
        addProviderAddresses(_recipients, _reserves);
    }

    function replaceRecipients(address[] calldata _recipients, uint256[] calldata _bips, bool[] calldata _wrap)
        external
        onlyOwner
    {
        for (uint256 i = recipients.length; i > 0; i--) {
            recipients.pop();
        }
        addRecipients(_recipients, _bips, _wrap);
    }
}
