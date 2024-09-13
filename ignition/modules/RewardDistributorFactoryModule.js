const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("RewardDistributorFactory", (m) => {
  const factory = m.contract("RewardDistributorFactory");

  return { factory };
});