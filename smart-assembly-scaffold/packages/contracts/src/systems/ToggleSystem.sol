// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { console } from "forge-std/console.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE as DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

import { ToggleTable } from "../codegen/tables/ToggleTable.sol";

/**
 * @dev This contract is a basic example of how to set MUD table data and for being called by the DApp Client
 */
contract ToggleSystem is System {
  /**
   * @dev Set the SSU to True in the MUD Table
   * @param smartObjectId The SSU ID
   */
  function setTrue(
    uint256 smartObjectId
  ) public {
    ToggleTable.set(smartObjectId, true);
  }

  /**
   * @dev Set the SSU to False in the MUD Table
   * @param smartObjectId The SSU ID
   */
  function setFalse(
    uint256 smartObjectId
  ) public {
    ToggleTable.set(smartObjectId, false);
  }

  function _namespace() internal pure returns (bytes14 namespace) {
    return DEPLOYMENT_NAMESPACE;
  }
}
