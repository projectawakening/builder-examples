// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { NAMESPACE } from "../constants.sol";

import { IPermissionedSystem } from "../interfaces/IPermissionedSystem.sol";

import { EveSystem } from "@eveworld/smart-object-framework/src/systems/internal/EveSystem.sol";

contract UnapprovedForwarderSystem is EveSystem {

  ResourceId PERMISSIONED_SYSTEM_ID = WorldResourceIdLib.encode({
    typeId: RESOURCE_SYSTEM,
    namespace: NAMESPACE,
    name: bytes16("PermissionedSyst")
  });

  function rejectedCallOnlyApprovedForwarderPermissioned(uint256 smartObjectId) public hookable(smartObjectId, _systemId()) returns (bytes memory) {
    bytes memory returnData = world().call(
      PERMISSIONED_SYSTEM_ID,
      abi.encodeCall(IPermissionedSystem.onlyApprovedForwarderPermissioned, (smartObjectId))
    );
    return returnData;
  }

  function _systemId() internal returns (ResourceId) {
    return WorldResourceIdLib.encode({
      typeId: RESOURCE_SYSTEM,
      namespace: NAMESPACE,
      name: bytes16("UnapprovedForwar")
    });
  }
}