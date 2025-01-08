// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { CharactersTable } from "@eveworld/world/src/codegen/tables/CharactersTable.sol";
import { GateAccess } from "../codegen/tables/GateAccess.sol";

/**
 * @dev This contract is an example for implementing logic to a smart gate
 */
contract SmartGateSystem is System {  
  /**
   * @dev a function to set the allowed corp which does not get targeted by the Smart Turret
   * @param characterId The character requesting to use the Smart Gate
   * @param sourceGateId is the Smart Gate the player is jumping from
   * @param destinationGateId is the Smart Gate the player is wanting to jump to
   */
  function canJump(uint256 characterId, uint256 sourceGateId, uint256 destinationGateId) public view returns (bool) {
    //Get the allowed corp
    uint256 allowedCorp = GateAccess.get(sourceGateId);

    //Get the character corp
    uint256 characterCorp = CharactersTable.getCorpId(characterId);

    //If the corp is the same, allow jumps
    if(allowedCorp == characterCorp){
      return true;
    } else{
      return false;
    }    
  }

  /**
   * @dev a function to set the allowed corp which does not get targeted by the Smart Turret
   * @param sourceGateId The Smart Gate ID
   * @param corpID is the allowed corporation
   */
  function setAllowedCorp(uint256 sourceGateId, uint256 corpID) public {
    GateAccess.set(sourceGateId, corpID);
  }
}