// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
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
    require(smartObjectId != 0, "Smart Object ID cannot be 0");

    ToggleTable.set(smartObjectId, true);
  }

  /**
   * @dev Set the SSU to False in the MUD Table
   * @param smartObjectId The SSU ID
   */
  function setFalse(
    uint256 smartObjectId
  ) public {
    require(smartObjectId != 0, "Smart Object ID cannot be 0");
    
    ToggleTable.set(smartObjectId, false);
  }
}
