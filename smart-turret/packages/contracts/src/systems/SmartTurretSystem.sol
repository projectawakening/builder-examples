// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { IERC20 } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20.sol";
import { IERC721 } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721.sol";

import { DeployableTokenTable } from "@eveworld/world/src/codegen/tables/DeployableTokenTable.sol";
import { EntityRecordTable, EntityRecordTableData } from "@eveworld/world/src/codegen/tables/EntityRecordTable.sol";
import { Utils as EntityRecordUtils } from "@eveworld/world/src/modules/entity-record/Utils.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE as DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

import { Utils as SmartCharacterUtils } from "@eveworld/world/src/modules/smart-character/Utils.sol";
import { CharactersTableData, CharactersTable } from "@eveworld/world/src/codegen/tables/CharactersTable.sol";
import { TargetPriority, Turret, SmartTurretTarget } from "@eveworld/world/src/modules/smart-turret/types.sol";
import { TurretWhitelist } from "../codegen/tables/TurretWhitelist.sol";
import { TestList } from "../codegen/tables/TestList.sol";

/**
 * @dev This contract is an example for implementing logic to a smart turret
 */
contract SmartTurretSystem is System {
  using EntityRecordUtils for bytes14;
  using SmartDeployableUtils for bytes14;
  using SmartCharacterUtils for bytes14;

  /**
   * @dev a function to implement logic for smart turret based on proximity
   * @param smartTurretId The smart turret id
   * @param characterId is the owner of the smart turret
   * @param priorityQueue is the queue of existing targets ordered by priority, index 0 being the lowest priority
   * @param turret is the turret data
   * @param turretTarget is the target data
   */
  function inProximity(
    uint256 smartTurretId,
    uint256 characterId,
    TargetPriority[] memory priorityQueue,
    Turret memory turret,
    SmartTurretTarget memory turretTarget
  ) public returns (TargetPriority[] memory updatedPriorityQueue) {
    //Get MUD whitelist table
    uint256[] memory whitelist = TurretWhitelist.get(smartTurretId);

    //Log the character ID
    console.log("CHARACTER ID:", turretTarget.characterId);

    bool found = false;

    //Check through whitelist
    for(uint256 i = 0; i < whitelist.length; i++){      
      console.log("WHITELIST:", whitelist[i]);
      if(turretTarget.characterId == whitelist[i]) found = true;
    }

    //If the character isn't in the whitelist
    if(!found){
      //Create new array to add to
      updatedPriorityQueue = new TargetPriority[](priorityQueue.length + 1);

      //Clone current priorityQueue
      for (uint256 i = 0; i < priorityQueue.length; i++) {
        updatedPriorityQueue[i] = priorityQueue[i];
      }

      //Add to the target queue
      updatedPriorityQueue[priorityQueue.length] = TargetPriority({ target: turretTarget, weight: 1 }); 
    
      console.log("ADD TO QUEUE:", turretTarget.characterId);

      //Return the new queue
      return updatedPriorityQueue;
    } 
    //Check if the character is in the queue
    else{
      found = false;      
      //Clone current priorityQueue
      for (uint256 i = 0; i < priorityQueue.length; i++) {
        if(turretTarget.characterId == priorityQueue[i].target.characterId) found = true;
      }

      if(found){
        console.log("REMOVING FROM QUEUE");

        updatedPriorityQueue = new TargetPriority[](priorityQueue.length - 1);

        uint256 index = 0;
        //Clone current priorityQueue
        for (uint256 i = 0; i < priorityQueue.length; i++) {
          if(turretTarget.characterId != priorityQueue[i].target.characterId){
            updatedPriorityQueue[index] = priorityQueue[i];
            index++;
          }
        }

        return updatedPriorityQueue;
      }

      //Return the original queue
      return priorityQueue;
    }    
  }

  /**
   * @dev a function to add a character to the whitelist
   * @param smartTurretId The smart turret id
   * @param characterId is the owner to add 
   */
  function addToWhitelist(uint256 smartTurretId, uint256 characterId) public {    
    //Get current whitelist
    uint256[] memory whitelist = TurretWhitelist.get(smartTurretId);

    //Create new whitelist
    uint256[] memory newWhitelist = new uint256[](whitelist.length+1);
    
    //Clone current whitelist
    for(uint256 i = 0; i < whitelist.length; i++){
      newWhitelist[i] = whitelist[i];
    }

    //Log character ID
    console.log("ADDING TO WHITELIST", characterId);

    //Add to whitelist
    newWhitelist[newWhitelist.length-1] = characterId;

    //Set the MUD table data
    TurretWhitelist.set(smartTurretId, newWhitelist);
  }

  function removeFromWhitelist(uint256 smartTurretId, uint256 characterId) public { 
    //Get current whitelist
    uint256[] memory whitelist = TurretWhitelist.get(smartTurretId);
    
    bool found = false;

    //Check whitelist
    for(uint256 i = 0; i < whitelist.length; i++){
      if(whitelist[i] == characterId) found = true;
    }

    if(found){
      uint256[] memory updatedWhitelist = new uint256[](whitelist.length-1);

      bool removed = false;

      //Clone current whitelist
      uint256 storedIndex = 0;
      for(uint256 i = 0; i < whitelist.length; i++){
        if(whitelist[i] != characterId || removed){
          updatedWhitelist[storedIndex] = whitelist[i];
          storedIndex++;
        } else{
          removed = true;
        }
      }

      TurretWhitelist.set(smartTurretId, updatedWhitelist);
    }
  }

  function getWhitelist(uint256 smartTurretId) public returns(uint256[] memory whitelist) {
    whitelist = TurretWhitelist.get(smartTurretId);

    return whitelist;
  }

  function setWhitelist(uint256 smartTurretId, uint256 characterId) public {    
    TestList.set(smartTurretId, characterId);
  }

  /**
   * @dev a function to implement logic for smart turret based on aggression
   * @param smartTurretId The smart turret id
   * @param characterId is the owner of the smart turret
   * @param priorityQueue is the queue of existing targets ordered by priority, index 0 being the lowest priority
   * @param turret is the turret data
   * @param aggressor is the aggressor
   * @param victim is the victim
   */
  function aggression(
    uint256 smartTurretId,
    uint256 characterId,
    TargetPriority[] memory priorityQueue,
    Turret memory turret,
    SmartTurretTarget memory aggressor,
    SmartTurretTarget memory victim
  ) public returns (TargetPriority[] memory updatedPriorityQueue) {
    //TODO: Implement the logic
    return priorityQueue;
  }

  function _namespace() internal pure returns (bytes14 namespace) {
    return DEPLOYMENT_NAMESPACE;
  }
}
