// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
interface IAccessControlHook {

  function onlyAdminRoleTxOrigin(uint256 smartObjectId) external;

  function onlyOwnerInitialMsgSender(uint256 smartObjectId) external;

  function onlyApprovedRoleForwardedMsgSender(uint256 smartObjectId) external;

  function storeSystemAddress(uint256 smartObjectid) external;

  function getStoredAddress(uint256 smartObjectId) external returns (address);

  function setAccessListByRole(bytes32 accessRoleId, address[] memory accessList) external;
}