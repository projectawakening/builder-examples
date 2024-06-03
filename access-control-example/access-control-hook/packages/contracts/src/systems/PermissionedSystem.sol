// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { NAMESPACE } from "../constants.sol";

import { EveSystem } from "@eveworld/smart-object-framework/src/systems/internal/EveSystem.sol";

contract PermissionedSystem is EveSystem {
  function onlyAdminPermissioned(uint256 smartObjectId) public hookable(smartObjectId, _systemId()) returns (uint256) {
    return smartObjectId;
  }

  function onlyOwnerPermissioned(uint256 smartObjectId) public hookable(smartObjectId, _systemId()) returns (uint256) {
    return smartObjectId;
  }

  function onlyApprovedForwarderPermissioned(uint256 smartObjectId) public hookable(smartObjectId, _systemId()) returns (uint256) {
    return smartObjectId;
  }

  function _systemId() internal returns (ResourceId) {
    return WorldResourceIdLib.encode({
      typeId: RESOURCE_SYSTEM,
      namespace: NAMESPACE,
      name: bytes16("PermissionedSyst")
    });
  }
}