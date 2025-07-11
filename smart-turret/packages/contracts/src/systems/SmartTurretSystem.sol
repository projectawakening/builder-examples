// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { 
  Turret, 
  SmartTurretTarget, 
  TargetPriority, 
  AggressionParams 
} from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/types.sol";

import { Characters } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Characters.sol";
import { accessSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/AccessSystemLib.sol";

import { TurretAllowlist } from "../codegen/tables/TurretAllowlist.sol";

/**
 * @dev This contract is an example for implementing logic to a smart turret
 */
contract SmartTurretSystem is System {
  /**
   * @dev a function to implement logic for Smart Turret based on proximity
   * @param smartTurretId The Smart Turret id
   * @param characterId is the owner of the Smart Turret
   * @param priorityQueue is the queue of existing targets ordered by priority, index 0 being the lowest priority
   * @param turret is the turret data
   * @param turretTarget is the player in the zone
   * This runs on a tick based cycle when the player is in proximity of the Smart Turret
   * The game receives the new priority queue, and select targets based on the reverse order of the new queue. 
   * Meaning the targets with the highest index will be picked first.
   */
  function inProximity(
    uint256 smartTurretId,
    uint256 characterId,
    TargetPriority[] memory priorityQueue,
    Turret memory turret,
    SmartTurretTarget memory turretTarget
  ) public view returns (TargetPriority[] memory updatedPriorityQueue) {
    // Get the allowed corp ID singleton
    uint256 allowedCorp = TurretAllowlist.get();
    // Get the corp ID of the player that is in proximity of the Smart Turret
    uint256 characterCorp = Characters.getTribeId(turretTarget.characterId);

    // Find if the player is already in the queue. 
    // This might happen if the player joins the corp while in proximity.
    bool foundInPriorityQueue = getIsTargetInQueue(priorityQueue, turretTarget.characterId);
    
    // Check if the player shouldn't be targeted
    if (characterCorp == allowedCorp) {
      if (!foundInPriorityQueue) {
        // Return the unchanged array
        return priorityQueue;     
      }

      // If found, create a new array without the character
      return removeTargetFromQueue(priorityQueue, turretTarget.characterId);
    }

    // Prioritize ships with the lowest total health percentage. hPRatio, shieldRatio and armorRatio are between [0-100]
    uint256 calculatedWeight = calculateWeight(turretTarget);

    // Weight is not currently used in-game as the game uses the position of elements in the array, however we set it for the bubble sort algorithm to use
    // If already in the queue, update the weight and sort the array
    if (foundInPriorityQueue) {
      return updateWeight(priorityQueue);
    }

    // Create the new priority
    TargetPriority memory newTarget = TargetPriority({ target: turretTarget, weight: calculatedWeight }); 

    // If not already in the queue, add to the queue
    return addTargetToQueue(priorityQueue, newTarget);
  }

  /**
   * @dev a function to check if a target is in the queue
   * @param priorityQueue is the queue to check
   * @param characterId is the character ID to check
   * @return isInQueue is true if the target is in the queue
   */
  function getIsTargetInQueue(
    TargetPriority[] memory priorityQueue, 
    uint256 characterId
  ) public pure returns (bool isInQueue) {
    for (uint i = 0; i < priorityQueue.length; i++) {
      if (priorityQueue[i].target.characterId == characterId) {
        return true;
      }
    }

    return false;
  }

  /**
   * @dev a function to remove a target from the queue
   * @param priorityQueue is the queue to remove the target from
   * @param characterId is the character ID to remove
   * @return updatedPriorityQueue is the updated queue
   */
  function removeTargetFromQueue(
    TargetPriority[] memory priorityQueue, 
    uint256 characterId
  ) public pure returns (TargetPriority[] memory updatedPriorityQueue) {
      // Create the smaller temporary array
      updatedPriorityQueue = new TargetPriority[](priorityQueue.length - 1);

      // Loop over the queue and only set if not the character
      for (uint i = 0; i < priorityQueue.length; i++) {
        if (priorityQueue[i].target.characterId != characterId) {
          updatedPriorityQueue[i] = priorityQueue[i];
        }
      }

      // Sort the array
      updatedPriorityQueue = bubbleSortTargetPriorityArray(updatedPriorityQueue);

      return updatedPriorityQueue;
  }

  /**
   * @dev a function to update all of the weights in the queue
   * @param priorityQueue is the queue to update the weights of the targets in
   * @return updatedPriorityQueue is the updated queue
   */
  function updateWeight(
    TargetPriority[] memory priorityQueue
  ) public pure returns (TargetPriority[] memory updatedPriorityQueue) {
    for (uint i = 0; i < priorityQueue.length; i++) {
      priorityQueue[i].weight = calculateWeight(priorityQueue[i].target);
    }

    // Sort the array
    priorityQueue = bubbleSortTargetPriorityArray(priorityQueue);

    return priorityQueue;
  }

  /**
   * @dev a function to add a target to the queue
   * @param priorityQueue is the queue to add the target to
   * @param newTarget is the target to add
   * @return updatedPriorityQueue is the updated queue
   */
  function addTargetToQueue(
    TargetPriority[] memory priorityQueue, 
    TargetPriority memory newTarget
  ) public pure returns (TargetPriority[] memory updatedPriorityQueue) {
    // Create the larger temporary array
    updatedPriorityQueue = new TargetPriority[](priorityQueue.length + 1);

    // Clone the priority queue to the temp array
    for (uint i = 0; i < priorityQueue.length; i++) {
      updatedPriorityQueue[i] = priorityQueue[i];
    }

    // Set the new target to the end of the temp array
    updatedPriorityQueue[priorityQueue.length] = newTarget;      

    // Sort the array
    updatedPriorityQueue = bubbleSortTargetPriorityArray(updatedPriorityQueue);

    return updatedPriorityQueue;
  }

  /**
   * @dev a function to sort the priority queue by weight, using the bubble sort algorithm
   * @param priorityQueue is the queue to sort
   */
  function bubbleSortTargetPriorityArray(
    TargetPriority[] memory priorityQueue
  ) public pure returns (TargetPriority[] memory sortedPriorityQueue) {
    uint256 length = priorityQueue.length;

    // Doesn't need sorting if the queue only has 1 or 0 entries
    if (length < 2) return priorityQueue;

    bool swapped;
    // Loop until the bubble sort algorithm stops sorting
    do {
      swapped = false;

      // Loop to the second last element, as it will sort for the next element
      for (uint256 i = 0; i < length - 1; i++) {
        // Check if a swap needs to happen
        if (priorityQueue[i].weight > priorityQueue[i + 1].weight) {
          // Swap the values in the array
          (priorityQueue[i], priorityQueue[i+1]) = (priorityQueue[i + 1], priorityQueue[i]);
          // Do another loop
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
   * This calculates weight so that the higher the weight, the higher the priority. 
   * As the targets are prioritized and the game selects the targets in reverse order they are returned.
   */
  function calculateWeight(SmartTurretTarget memory target) internal pure returns (uint256 weight) {
    uint256 MAX_COMBINED_HP_RATIO = 300;

    weight = MAX_COMBINED_HP_RATIO - (
      target.hpRatio + 
      target.shieldRatio + 
      target.armorRatio
    );

    return weight;
  }

  /**
   * @dev a function to set the allowed tribe which does not get targeted by the Smart Turret
   * @param tribeID is the allowed tribe
   * @notice this function is only callable by the admin
   */
  function setAllowedTribe(uint256 tribeID) public {
    // Ensure it's the admin calling this function
    require(accessSystem.isAdmin(_msgSender()), "You are not authorized to set the allowed tribe");

    // Validation check on the tribe ID
    require(tribeID > 1000, "Invalid Tribe ID");

    // Set the allowed corp ID in MUD
    TurretAllowlist.set(tribeID);
  }

  /**
   * @dev a function to implement logic for smart turret based on aggression
   * @param aggressionParams is the aggression parameters
   */
  function aggression(
    AggressionParams memory aggressionParams
  ) public view returns (TargetPriority[] memory updatedPriorityQueue) {
    return aggressionParams.priorityQueue;
  }
}
