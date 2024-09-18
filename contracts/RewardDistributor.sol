// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./interfaces/IRewardDistributor.sol";
import "./FlareLibrary.sol";

contract RewardDistributor is IRewardDistributor {
    OperatingAddress[] public operatingAddresses;
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
        address[] memory _operatingAddresses,
        uint256[] memory _lowReserves,
        uint256[] memory _highReserves,
        address[] memory _recipients,
        uint256[] memory _bips,
        bool[] memory _wrap,
        address _owner
    ) {
        uint256 len = _operatingAddresses.length;
        require(_lowReserves.length == len, "Low reserves length mismatch");
        require(_highReserves.length == len, "High reserves length mismatch");
        len = _recipients.length;
        require(len > 0, "No recipients");
        require(_bips.length == len, "Bips length mismatch");
        require(_wrap.length == len, "Wrap length mismatch");
        owner = _owner;
        addOperatingAddresses(_operatingAddresses, _lowReserves, _highReserves);
        addRecipients(_recipients, _bips, _wrap);
    }

    function addOperatingAddresses(address[] memory _recipients, uint256[] memory _lowReserves, uint256[] memory _highReserves) private {
        for (uint256 i; i < _recipients.length; i++) {
            addOperatingAddress(_recipients[i], _lowReserves[i], _highReserves[i]);
        }
    }

    function addOperatingAddress(address _recipient, uint256 _lowReserve, uint256 _highReserve) internal {
        require(_highReserve >= _lowReserve, "High/Low reserves inconsistency");
        OperatingAddress storage operatingAddress = operatingAddresses.push();
        operatingAddress.recipient = payable(_recipient);
        operatingAddress.lowReserve = _lowReserve;
        operatingAddress.highReserve = _highReserve;
    }

    function addOrReplaceOperatingAddress(address _recipient, uint256 _lowReserve, uint256 _highReserve) external onlyOwner {
        require(_highReserve >= _lowReserve, "High/Low reserves inconsistency");
        for (uint256 i; i < operatingAddresses.length; i++) {
            OperatingAddress storage operatingAddress = operatingAddresses[i];
            if (operatingAddress.recipient == _recipient) {
                operatingAddress.lowReserve = _lowReserve;
                operatingAddress.highReserve = _highReserve;
                return;
            }
        }
        addOperatingAddress(_recipient, _lowReserve, _highReserve);
    }

    function removeOperatingAddress(address _recipient) external onlyOwner {
        for (uint256 i; i < operatingAddresses.length; i++) {
            OperatingAddress storage operatingAddress = operatingAddresses[i];
            if (operatingAddress.recipient == _recipient) {
                if (i < operatingAddresses.length - 1) operatingAddress = operatingAddresses[operatingAddresses.length - 1];
                operatingAddresses.pop();
                return;
            }
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

    function operatingAddressesCount() external view returns (uint256) {
        return operatingAddresses.length;
    }

    function operatingAddressesAll() external view returns (OperatingAddress[] memory) {
        return operatingAddresses;
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
        for (uint256 i; i < operatingAddresses.length && remainingAmount > 0; i++) {
            OperatingAddress storage o = operatingAddresses[i];
            uint256 currentBalance = o.recipient.balance;
            if (currentBalance < o.lowReserve) {
                uint256 refillAmount = o.highReserve - currentBalance;
                if (refillAmount > remainingAmount) refillAmount = remainingAmount;
                (bool success,) = o.recipient.call{value: refillAmount}("");
                require(success, "Unable to refill operating's account");
                emit Refill(o.recipient, refillAmount);
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

    function replaceOperatingAddresses(address[] calldata _recipients, uint256[] calldata _lowReserves, uint256[] calldata _highReserves) external onlyOwner {
        for (uint256 i = operatingAddresses.length; i > 0; i--) {
            operatingAddresses.pop();
        }
        addOperatingAddresses(_recipients, _lowReserves, _highReserves);
    }

    function replaceRecipients(address[] calldata _recipients, uint256[] calldata _bips, bool[] calldata _wrap) external onlyOwner {
        uint256 len = recipients.length;
        require(len > 0, "No recipients");
        for (uint256 i = len; i > 0; i--) {
            recipients.pop();
        }
        addRecipients(_recipients, _bips, _wrap);
    }
}
