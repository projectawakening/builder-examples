// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { OwnershipByObject } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/OwnershipByObject.sol";

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
    //Ensure the caller is the owner of the SSU
    address ssuOwner = OwnershipByObject.get(smartObjectId);
    require(ssuOwner == _msgSender(), "Access Denied. You are not the owner of this SSU.");
    
    ToggleTable.set(smartObjectId, true);
  }

  /**
   * @dev Set the SSU to False in the MUD Table
   * @param smartObjectId The SSU ID
   */
  function setFalse(
    uint256 smartObjectId
  ) public {
    //Ensure the caller is the owner of the SSU
    address ssuOwner = OwnershipByObject.get(smartObjectId);
    require(ssuOwner == _msgSender(), "Access Denied. You are not the owner of this SSU.");
    
    ToggleTable.set(smartObjectId, false);
  }

  function getToggle(
    uint256 smartObjectId
  ) public view returns (bool) {
    return ToggleTable.get(smartObjectId);
  }
}
