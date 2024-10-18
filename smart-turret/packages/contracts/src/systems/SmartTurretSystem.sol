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
import { CharactersTable } from "@eveworld/world/src/codegen/tables/CharactersTable.sol";

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
    address[] memory whitelist = TurretWhitelist.get(smartTurretId);

    address targetAddress = CharactersTable.getCharacterAddress(turretTarget.characterId);

    bool found = inWhitelist(whitelist, targetAddress);

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
    
      //Return the new queue
      return updatedPriorityQueue;
    } 
    //Check if the character is in the queue
    else{
      found = false;      
      //Check priority queue for character ID
      for (uint256 i = 0; i < priorityQueue.length; i++) {
        if(turretTarget.characterId == priorityQueue[i].target.characterId) found = true;
      }

      if(found){
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
   * @param character is the character to add 
   */
  function addToWhitelist(uint256 smartTurretId, address character) public returns(address[] memory whitelist) {            
    //address character = CharactersTable.getCharacterAddress(characterId);
    //Get current whitelist
    whitelist = TurretWhitelist.get(smartTurretId);

    if(inWhitelist(whitelist, character)){
      revert("Character is already in the whitelist");
    }

    //Create new whitelist
    address[] memory newWhitelist = new address[](whitelist.length+1);
    
    //Clone current whitelist
    for(uint256 i = 0; i < whitelist.length; i++){
      newWhitelist[i] = whitelist[i];
    }

    //Add to whitelist
    newWhitelist[newWhitelist.length-1] = character;

    //Set the MUD table data
    TurretWhitelist.set(smartTurretId, newWhitelist);
    
    return newWhitelist;
  }

  /**
   * @dev a function to add a character to the whitelist by ID
   * @param smartTurretId The smart turret id
   * @param characterID is the character to add 
   */
  function addToWhitelistByID(uint256 smartTurretId, uint256 characterID) public returns(address[] memory whitelist) {            
    address characterAddress = CharactersTable.getCharacterAddress(characterID);

    addToWhitelist(smartTurretId, characterAddress);
  }

  /**
   * @dev a function to remove a character from the whitelist
   * @param smartTurretId The smart turret id
   * @param characterID is the character to add 
   */
  function removeFromWhitelist(uint256 smartTurretId, address character) public returns(address[] memory whitelist) { 
    //Get current whitelist
    whitelist = TurretWhitelist.get(smartTurretId);

    if(!inWhitelist(whitelist, character)){
      revert("Character not in whitelist");
    }

    address[] memory updatedWhitelist = new address[](whitelist.length-1);

    bool removed = false;

    //Clone current whitelist
    uint256 storedIndex = 0;
    for(uint256 i = 0; i < whitelist.length; i++){
      if(whitelist[i] != character || removed){
        updatedWhitelist[storedIndex] = whitelist[i];
        storedIndex++;
      } else{
        removed = true;
      }
    }

    TurretWhitelist.set(smartTurretId, updatedWhitelist);

    return updatedWhitelist;
  }

  /**
   * @dev a function to check if a character is in the whitelist
   * @param whitelist the whitelist array
   * @param character the character for the check
   */
  function inWhitelist(address[] memory whitelist, address character) public returns(bool){    
    //Check whitelist
    for(uint256 i = 0; i < whitelist.length; i++){
      if(whitelist[i] == character) return true;
    }

    return false;
  }

  /**
   * @dev a function to get the whitelist for a turret
   * @param smartTurretId the smart turret ID
   */
  function getWhitelist(uint256 smartTurretId) public returns(address[] memory whitelist) {
    whitelist = TurretWhitelist.get(smartTurretId);

    return whitelist;
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
    return priorityQueue;
  }

  function _namespace() internal pure returns (bytes14 namespace) {
    return DEPLOYMENT_NAMESPACE;
  }
}