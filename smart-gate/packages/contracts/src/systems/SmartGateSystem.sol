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
import { AccessListDefinitions, AccessListDefinitionsData } from "../codegen/tables/AccessListDefinitions.sol";
import { AccessListEntries, AccessListEntriesData  } from "../codegen/tables/AccessListEntries.sol";

import { IERC721 } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721.sol";

import { DeployableTokenTable } from "@eveworld/world/src/codegen/tables/DeployableTokenTable.sol";

/**
 * @dev This contract is an example for implementing logic to a smart gate
 */
contract SmartGateSystem is System {  
  /**
   * @dev Only owner modifer
   */
  modifier onlyOwner(uint256 smartObjectId) {
    address ssuOwner = IERC721(DeployableTokenTable.getErc721Address()).ownerOf(smartObjectId);
    require(_msgSender() == ssuOwner, "Only owner can call this function");
    _;
  }  

  function canJump(uint256 characterId, uint256 sourceGateId, uint256 /*_destinationGateId*/) public view returns (bool) {
    return hasCharAccessToSmartObject(characterId, sourceGateId);
  }

    /**
   * @dev Checks whether a char (given by charId, corpId) has access to a specified smartObjectId (for example a smart gate).
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
      AccessListEntriesData memory charEntry =
        AccessListEntries.get(listIds[i], charId, 0);

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
}

