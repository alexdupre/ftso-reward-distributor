// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IPriceSubmitter {
    function getFtsoManager() external view returns (address);
}

interface IFtsoManager {
    function rewardManager() external view returns (address);
}

interface IFtsoRewardManager {
    function wNat() external view returns (address);
}

interface IWNat {
    function depositTo(address recipient) external payable;
}

library FlareLibrary {
    IPriceSubmitter private constant priceSubmitter = IPriceSubmitter(0x1000000000000000000000000000000000000003);

    function getWNat() internal view returns (IWNat) {
        return IWNat(IFtsoRewardManager(IFtsoManager(priceSubmitter.getFtsoManager()).rewardManager()).wNat());
    }
}
