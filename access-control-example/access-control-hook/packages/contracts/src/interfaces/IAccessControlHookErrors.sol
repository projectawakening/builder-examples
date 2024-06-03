// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

interface IAccessControlHookErrors {
  error AccessControl_NoPermission(address sender, bytes32 roleId);

  error AccessControl_InvalidRoleId();

  error AccessControl_AccessRoleTableAccessDenied();
}