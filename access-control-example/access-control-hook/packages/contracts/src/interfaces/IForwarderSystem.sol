// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
interface IForwarderSystem {
  function callOnlyApprovedForwarderPermissioned(uint256 smartObjectId) external returns (bytes memory);
}