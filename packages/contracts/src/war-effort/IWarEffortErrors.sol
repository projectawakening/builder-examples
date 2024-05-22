//SPDX-LicenseIdentifier: MIT
pragma solidity >=0.8.21;

interface IWarEffortErrors {
  error WarEffort_WrongItemArrayLength();
  error WarEffort_WrongDepositType(uint256 expectedItemId, uint256 itemId);
  error WarEffort_DepositOverTargetLimit();
  error WarEffort_NotSSUOwner(uint256 smartObjectId);
}
