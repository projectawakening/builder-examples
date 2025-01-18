// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { CharactersTable } from "@eveworld/world/src/codegen/tables/CharactersTable.sol";
import { IERC721 } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721.sol";
import { DeployableTokenTable } from "@eveworld/world/src/codegen/tables/DeployableTokenTable.sol";

import { GateAccess } from "../codegen/tables/GateAccess.sol";
import { AccessListDefinitions, AccessListDefinitionsData } from "../codegen/tables/AccessListDefinitions.sol";
import { AccessListEntries, AccessListEntriesData  } from "../codegen/tables/AccessListEntries.sol";

contract SmartGateSystem is System {  
  modifier onlyOwner(uint256 smartObjectId) {
    address ssuOwner = IERC721(DeployableTokenTable.getErc721Address()).ownerOf(smartObjectId);
    require(_msgSender() == ssuOwner, "Only owner can call this function");
    _;
  }  

  function canJump(uint256 characterId, uint256 sourceGateId, uint256 _destinationGateId) public view returns (bool) {
    return hasCharAccessToSmartObject(characterId, sourceGateId);
  }

  /**
   * @notice Checks whether a char  has access to a smart object (for example a smart gate).
   * @param charId Character ID
   * @param smartObjectId Smart object ID
   *
   * LOGIC:
   *  1) Gather all AccessListIDs linked to smartObjectId.
   *  2) Check if char or corp is in any BLACKLIST:
   *       - if found => return false
   *  3) Check if char or corp is in any WHITELIST:
   *       - if found => return true
   *  4) If not on any list => return false
   */
  function hasCharAccessToSmartObject(uint256 charId, uint256 smartObjectId) public view returns (bool) {
    // Get chars corp ID
    uint256 corpId = CharactersTable.getCorpId(charId);

    // 1) Get all access list IDs associated with this gate
    bytes32[] memory listIds = GateAccess.get(smartObjectId);

    // 2) Check for blacklists first
    for (uint256 i = 0; i < listIds.length; i++) {
      AccessListDefinitionsData memory accessListDefinitionsData = AccessListDefinitions.get(listIds[i]);

      // skip if isWhitelist
      if (accessListDefinitionsData.isWhitelist) {
        continue;
      }

      // check char
      AccessListEntriesData memory charEntry = AccessListEntries.get(listIds[i], charId, 0);

      if (charEntry.addedBy != address(0)) {
        // char found on a blacklist => deny access
        return false;
      }
      // check corp
      AccessListEntriesData memory corpEntry = AccessListEntries.get(listIds[i], corpId, 1);

      if (corpEntry.addedBy != address(0)) {
        // corp found on a blacklist => deny access
        return false;
      }
    }

    // 3) Check for whitelists
    for (uint256 i = 0; i < listIds.length; i++) {
      AccessListDefinitionsData memory accessListDefinitionsData = AccessListDefinitions.get(listIds[i]);

      // skip if not isWhitelist, it's a blacklist
      if (!accessListDefinitionsData.isWhitelist) {
        continue;
      }
  
      // check char
      AccessListEntriesData memory charEntry = AccessListEntries.get(listIds[i], charId, 0);
      if (charEntry.addedBy != address(0)) {
        // char found on a whitelist => allow
        return true;
      }
      // check corp
      AccessListEntriesData memory corpEntry = AccessListEntries.get(listIds[i], corpId, 1);

      if (corpEntry.addedBy != address(0)) {
        // corp found on a whitelist => allow
        return true;
      }  
    }
    // 4) Default: if not on any blacklist or whitelist => no access
    return false;
  }

  /**
   * @notice Adds a new access list ID to the access lists list of a specified gate.
   * @dev This function retrieves the current array of access list IDs associated with a gate,
   *      appends the new `accessListId` to this array, and then updates the MUD table entry.
   *      It employs the `onlyOwner(gateId)` modifier to ensure that only authorized entities
   *      can modify the gate's access list.
   *
   * @param gateId The unique ID of the gate (smartObjectId) to which the access list entry will be added.
   * @param accessListId The specific access list ID (bytes32) to add to the gate's access list.
   *
   * Requirements:
   * - The caller must satisfy the conditions specified by the `onlyOwner(gateId)` modifier,
   *   meaning only the owner of the gate can invoke this function.
   *
   * Example usage:
   *   addAccessListToGate(gateId, accessListId);
   */
  function addAccessListToGate(uint256 gateId, bytes32 accessListId) public  onlyOwner(gateId) {
    bytes32[] memory currentIds = GateAccess.get(gateId);
    bytes32[] memory newIds = new bytes32[](currentIds.length + 1);

    for (uint256 i = 0; i < currentIds.length; i++) {
      newIds[i] = currentIds[i];
    }
    newIds[currentIds.length] = accessListId;

    GateAccess.set(gateId, newIds);
  }

  /**
   * @notice Removes a specific access list ID from the access lists list of a given gate.
   * @dev This function retrieves the current array of access list IDs associated with a gate,
   *      finds the specified `accessListId`, removes it, and then updates the MUD table entry.
   *      It uses the `onlyOwner(gateId)` modifier to ensure that only authorized entities
   *      can modify the gate's access list.
   *
   * @param gateId The unique identifier of the gate (smartObjectId) from which the access list entry is to be removed.
   * @param accessListId The specific access list identifier (bytes32) to remove from the gate's access list.
   *
   * Requirements:
   * - The specified `accessListId` must exist in the current access list for the given `gateId`.
   * - The caller must satisfy the `onlyOwner(gateId)` modifier's requirements.
   *
   * Example usage:
   *   removeAccessListFromGate(gateId, accessListId);
   */
  function removeAccessListFromGate(uint256 gateId, bytes32 accessListId) public onlyOwner(gateId) {
    bytes32[] memory currentIds = GateAccess.get(gateId);

    // Variable to hold the index of the accessListId to remove, stays -1 if list not found
    int256 indexToRemove = -1;

    for (uint256 i = 0; i < currentIds.length; i++) {
      if (currentIds[i] == accessListId) {
        indexToRemove = int256(i);
        break;
      }
    }

    // indexToRemove is -1 if list not found
    require(indexToRemove >= 0, "AccessListId not found for this gate");

    bytes32[] memory newIds = new bytes32[](currentIds.length - 1);

    uint256 newIndex = 0;
    for (uint256 i = 0; i < currentIds.length; i++) {
      // Skip the element at indexToRemove
      if (i == uint256(indexToRemove)) {
        continue;
      }
      newIds[newIndex] = currentIds[i];
      newIndex++;
    }
    GateAccess.set(gateId, newIds);
  }
}
