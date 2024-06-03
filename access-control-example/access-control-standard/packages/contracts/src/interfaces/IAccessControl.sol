// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
interface IAccessControl {
  function setAccessListByRole(bytes32 accessRoleId, address[] memory accessList) external;
}