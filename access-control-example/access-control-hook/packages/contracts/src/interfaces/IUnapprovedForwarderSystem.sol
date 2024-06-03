// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
interface IUnapprovedForwarderSystem {
  function rejectedCallOnlyApprovedForwarderPermissioned(uint256 smartObjectId) external returns (bytes memory);
}