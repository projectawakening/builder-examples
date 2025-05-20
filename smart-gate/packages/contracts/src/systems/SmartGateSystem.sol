// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { Characters } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Characters.sol";
import { GateAccess } from "../codegen/tables/GateAccess.sol";

import { AccessSystem, accessSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/AccessSystemLib.sol";

/**
 * @dev This contract is an example for implementing logic to a smart gate
 */
contract SmartGateSystem is System {  
  function canJump(uint256 characterId, uint256 sourceGateId, uint256 destinationGateId) public view returns (bool) {
    //Get the allowed tribe
    uint256 allowedTribe = GateAccess.get(sourceGateId);

    //Get the character corp
    uint256 characterTribe = Characters.getTribeId(characterId);

    //If the tribe is the same, allow jumps
    if(allowedTribe == characterTribe){
      return true;
    } else{
      return false;
    }    
  }

  function setAllowedTribe(uint256 sourceGateId, uint256 tribeID) public {
    accessSystem.onlyOwner(sourceGateId, "");

    //Set the allowed tribe
    GateAccess.set(sourceGateId, tribeID);
  }
}