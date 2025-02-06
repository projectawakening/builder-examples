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

import { Utils } from "./Utils.sol";
import { AccessControl } from "@latticexyz/world/src/AccessControl.sol";

import { TurretAllowlist } from "../codegen/tables/TurretAllowlist.sol";

/**
 * @dev This contract is an example for implementing logic to a smart turret
 */
contract SmartTurretSystem is System {
  using EntityRecordUtils for bytes14;
  using SmartDeployableUtils for bytes14;
  using SmartCharacterUtils for bytes14;

  /**
   * @dev a function to implement logic for Smart Turret based on proximity
   * @param smartTurretId The Smart Turret id
   * @param characterId is the owner of the Smart Turret
   * @param priorityQueue is the queue of existing targets ordered by priority, index 0 being the lowest priority
   * @param turret is the turret data
   * @param turretTarget is the player in the zone
   * This runs on a tick based cycle when the player is in proximity of the Smart Turret
   * The game receives the new priority queue, and select targets based on the reverse order of the new queue. Meaning the targets with the highest index will be picked first.
   */
  function inProximity(
    uint256 smartTurretId,
    uint256 characterId,
    TargetPriority[] memory priorityQueue,
    Turret memory turret,
    SmartTurretTarget memory turretTarget
  ) public returns (TargetPriority[] memory updatedPriorityQueue) {
    //Get the allowed corp ID singleton
    uint256 allowedCorp = TurretAllowlist.get();
    //Get the corp ID of the player that is in proximity of the Smart Turret
    uint256 characterCorp = CharactersTable.getCorpId(turretTarget.characterId);
    
    //Find if the player is already in the queue. 
    //This might happen if the player joins the corp while in proximity.
    bool foundInPriorityQueue = false;
    for(uint i = 0; i < priorityQueue.length; i++){
      if(priorityQueue[i].target.characterId == turretTarget.characterId){
        foundInPriorityQueue = true;
        break;
      }
    }
    
    //Check if the player shouldn't be targeted
    if(characterCorp == allowedCorp){
      //If found, create a new array without the character
      if(foundInPriorityQueue){        
        //Create the smaller temporary array
        TargetPriority[] memory tempArray = new TargetPriority[](priorityQueue.length - 1);

        //Loop over the queue and only set if not the character
        for(uint i = 0; i < priorityQueue.length; i++){
          if(priorityQueue[i].target.characterId != turretTarget.characterId){
            tempArray[i] = priorityQueue[i];
          }
        }

        //Sort the array
        tempArray = bubbleSortTargetPriorityArray(tempArray);

        //Return the new array
        return tempArray;
      }
        
      //Return the unchanged array
      return priorityQueue;      
    }

    //Prioritize ships with the lowest total health percentage. hPRatio, shieldRatio and armorRatio are between [0-100]
    uint256 calculatedWeight = calculateWeight(turretTarget);

    //Weight is not currently used in-game as the game uses the position of elements in the array, however we set it for the bubble sort algorithm to use
    TargetPriority memory newPriority = TargetPriority({ target: turretTarget, weight: calculatedWeight }); 

    //If already in the queue, update the weight
    if(foundInPriorityQueue){
      //Loop through to find the index of the target for the character
      for(uint i = 0; i < priorityQueue.length; i++){
        if(priorityQueue[i].target.characterId == turretTarget.characterId){
          priorityQueue[i] = newPriority;
        }
      }      

      //Sort the array
      priorityQueue = bubbleSortTargetPriorityArray(priorityQueue);

      //Return the changed in-place queue
      return priorityQueue;
    //If not already in the queue, add to the queue
    } else{
      //Create the larger temporary array
      TargetPriority[] memory tempArray = new TargetPriority[](priorityQueue.length + 1);

      //Clone the priority queue to the temp array
      for(uint i = 0; i < priorityQueue.length; i++){
        tempArray[i] = priorityQueue[i];
      }

      //Set the new target to the end of the temp array
      tempArray[priorityQueue.length] = newPriority;      

      //Sort the array
      TargetPriority[] memory sortedArray = bubbleSortTargetPriorityArray(tempArray);

      //Return array to the Smart Turret
      return sortedArray;
    }    
  }

  /**
   * @dev a function to sort the priority queue by weight, using the bubble sort algorithm
   * @param priorityQueue is the queue to sort
   */
  function bubbleSortTargetPriorityArray(TargetPriority[] memory priorityQueue) public returns (TargetPriority[] memory sortedPriorityQueue) {
    uint256 length = priorityQueue.length;

    //Doesn't need sorting if the queue only has 1 or 0 entries
    if(length < 2) return priorityQueue;

    bool swapped;
    //Loop until the bubble sort algorithm stops sorting
    do{
      //Reset the swapped value
      swapped = false;
      //Loop to the second last element, as it will sort for the next element
      for (uint256 i = 0; i < length - 1; i++){
        //Check if a swap needs to happen
        if(priorityQueue[i].weight > priorityQueue[i + 1].weight){
          //Swap the values in the array
          (priorityQueue[i], priorityQueue[i+1]) = (priorityQueue[i + 1], priorityQueue[i]);
          //Do another loop
          swapped = true;
        }
      }
    }
    while (swapped);

    return priorityQueue;
  }

  /**
   * @dev a function to calculate the weight of the target
   * @param target is the target
   * This calculates weight so that the higher the weight, the higher the priority. As the targets are prioritized and the game selects the targets in reverse order they are returned
   */
  function calculateWeight(SmartTurretTarget memory target) public returns (uint256 weight){
    weight = 300 - (target.hpRatio + 
      target.shieldRatio + 
      target.armorRatio
    );

    return weight;
  }

  /**
   * @dev a function to set the allowed corp which does not get targeted by the Smart Turret
   * @param corpID is the allowed corporation
   */
  function setAllowedCorp(uint256 corpID) public {
    ResourceId id = Utils.smartTurretSystemId();

    //If the sender has access to the namespace / is the owner.
    bool hasAccess = AccessControl.hasAccess(id, _msgSender());

    //Ensure the sender has access
    require(hasAccess, "You do not have access to this function");

    //Set the allowed corp ID in MUD
    TurretAllowlist.set(corpID);
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
