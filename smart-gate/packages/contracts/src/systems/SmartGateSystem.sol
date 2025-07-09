// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { Characters } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Characters.sol";
import { OwnershipByObject } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/OwnershipByObject.sol";
import { accessSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/AccessSystemLib.sol";

import { GateAccess } from "../codegen/tables/GateAccess.sol";

/**
 * @dev This contract is an example for implementing logic to a smart gate
 */
contract SmartGateSystem is System {  
  /**
   * @dev Check if a character can jump to a gate
   * @param characterId The ID of the character to check
   * @param sourceGateId The ID of the gate to check
   * @param destinationGateId The ID of the gate to jump to
   * @return bool True if the character can jump, false otherwise
   */
  function canJump(uint256 characterId, uint256 sourceGateId, uint256 destinationGateId) public view returns (bool) {
    //Get the allowed tribe
    uint256 allowedTribe = GateAccess.get(sourceGateId);

    //Get the character corp
    uint256 characterTribe = Characters.getTribeId(characterId);

    //If the tribe is the same, allow jumps
    if (allowedTribe == characterTribe) {
      return true;
    } else {
      return false;
    }    
  }

  /**
   * @dev Set the allowed tribe for a gate
   * @param sourceGateId The ID of the gate to set the allowed tribe for
   * @param tribeID The ID of the tribe to allow
   */
  function setAllowedTribe(uint256 sourceGateId, uint256 tribeID) public {
    require(tribeID > 0, "Tribe ID cannot be 0 or negative");

    //Ensure the caller is the owner of the gate
    address gateOwner = OwnershipByObject.get(sourceGateId);
    require(gateOwner == _msgSender(), "Access Denied. You are not the owner of this gate.");

    //Set the allowed tribe
    GateAccess.set(sourceGateId, tribeID);
  }
}