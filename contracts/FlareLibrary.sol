// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IWNat {
    function depositTo(address recipient) external payable;
}

interface IFlareContractRegistry {
    function getContractAddressByHash(bytes32 _nameHash) external view returns (address);
}

library FlareLibrary {
    IFlareContractRegistry private constant registry =
        IFlareContractRegistry(0xaD67FE66660Fb8dFE9d6b1b4240d8650e30F6019);

    bytes32 private constant WNatHash = keccak256(abi.encode("WNat"));

    function getWNat() internal view returns (IWNat) {
        address a = registry.getContractAddressByHash(WNatHash);
        require(a != address(0), "Empty WNat address");
        return IWNat(a);
    }
}
