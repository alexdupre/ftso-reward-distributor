// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./interfaces/IRewardDistributor.sol";
import "./FlareLibrary.sol";

contract RewardDistributor is IRewardDistributor {

    address payable public provider;
    uint256 public reserveBalance;
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
        address _provider,
        uint256 _reserveBalance,
        address[] memory _recipients,
        uint256[] memory _bips,
        bool[] memory _wrap,
        address _owner
    ) {
        require(_provider != address(0), "Invalid provider address");
        uint256 len = _recipients.length;
        require(_bips.length == len, "Bips length mismatch");
        require(_wrap.length == len, "Wrap length mismatch");
        owner = _owner;
        provider = payable(_provider);
        reserveBalance = _reserveBalance;
        addRecipients(_recipients, _bips, _wrap);
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


    function recipientsCount() external view returns (uint256) {
        return recipients.length;
    }

    function recipientsAll() external view returns (Recipient[] memory) {
        return recipients;
    }

    receive() external payable lock {
        uint256 remainingAmount = msg.value;
        uint256 currentBalance = provider.balance;
        emit TotalRewards(block.timestamp, remainingAmount);
        if (currentBalance < reserveBalance) {
            uint256 refillAmount = reserveBalance - currentBalance;
            if (refillAmount > remainingAmount) refillAmount = remainingAmount;
            (bool success, ) = provider.call{value: refillAmount}("");
            require(success, "Unable to refill provider's account");
            emit Refill(refillAmount);
            remainingAmount -= refillAmount;
        }
        if (remainingAmount > 0) {
            uint256 remainingBips = 100_00;
            for (uint256 i; i < recipients.length; i++) {
                Recipient storage r = recipients[i];
                uint256 shareAmount = (remainingBips == r.bips) ? remainingAmount : (remainingAmount * r.bips) / remainingBips;
                if (r.wrap) {
                    FlareLibrary.getWNat().depositTo{value: shareAmount}(r.recipient);
                } else {
                    (bool success, ) = r.recipient.call{value: shareAmount}("");
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

    function replaceReserveBalance(uint256 _reserveBalance) external onlyOwner {
        reserveBalance = _reserveBalance;
    }

    function replaceRecipients(address[] calldata _recipients, uint256[] calldata _bips, bool[] calldata _wrap) external onlyOwner {
        for (uint256 i = recipients.length; i > 0; i--) recipients.pop();
        addRecipients(_recipients, _bips, _wrap);
    }
}
