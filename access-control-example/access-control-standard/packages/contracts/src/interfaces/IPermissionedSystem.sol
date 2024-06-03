// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
interface IPermissionedSystem {

  function onlyAdminPermissioned(uint256 smartObjectIdDummy) external returns (uint256);

  function onlyOwnerPermissioned(uint256 smartObjectIdDummy) external returns (uint256);

  function onlyApprovedForwarderPermissioned(uint256 smartObjectIdDummy) external returns (uint256);

  function setAccessListByRole(bytes32 accessRoleId, address[] memory accessList) external;
}