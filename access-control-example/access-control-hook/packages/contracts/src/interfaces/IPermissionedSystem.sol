// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
interface IPermissionedSystem {

  function onlyAdminPermissioned(uint256 smartObjectId) external returns (uint256);

  function onlyOwnerPermissioned(uint256 smartObjectId) external returns (uint256);

  function onlyApprovedForwarderPermissioned(uint256 smartObjectId) external returns (uint256);

}