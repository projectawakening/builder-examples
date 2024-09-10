//SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";

import { VENDING_MACHINE_DEPLOYMENT_NAMESPACE, VENDING_MACHINE_SYSTEM_NAME } from "./constants.sol";

library Utils {
  function vendingMachineSystemId() internal pure returns (ResourceId) {
    return
      WorldResourceIdLib.encode({
        typeId: RESOURCE_SYSTEM,
        namespace: VENDING_MACHINE_DEPLOYMENT_NAMESPACE,
        name: VENDING_MACHINE_SYSTEM_NAME
      });
  }
}
