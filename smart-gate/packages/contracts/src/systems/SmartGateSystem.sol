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
import { AccessLists, AccessListsData } from "../codegen/tables/AccessLists.sol";

//import { IERC721 } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721.sol";

//import { DeployableTokenTable } from "@eveworld/world/src/codegen/tables/DeployableTokenTable.sol";

/**
 * @dev This contract is an example for implementing logic to a smart gate
 */
contract SmartGateSystem is System {  
  function canJump(uint256 characterId, uint256 sourceGateId, uint256 /*_destinationGateId*/) public view returns (bool) {
    return hasCharAccessToSmartObject(characterId, sourceGateId);
  }

  function hasCharAccessToSmartObject(uint256 characterId, uint256 smartObjectId) private view returns (bool) {
    uint256 characterCorpId = CharactersTable.getCorpId(characterId);
    bytes32[] memory accessListIds = GateAccess.get(smartObjectId);

    for (uint256 i = 0; i < accessListIds.length; i++) {
      AccessListsData memory accessListData = AccessLists.get(accessListIds[i]);
      if (bytes(accessListData.accessListName).length == 0 || accessListData.isWhiteList) continue;
      for (uint256 j = 0; j < accessListData.CorpIds.length; j++) {
        if (accessListData.CorpIds[j] == characterCorpId) return false;
      }
      for (uint256 j = 0; j < accessListData.CharIds.length; j++) {
        if (accessListData.CharIds[j] == characterId) return false;
      }
    }

    for (uint256 i = 0; i < accessListIds.length; i++) {
      AccessListsData memory accessListData = AccessLists.get(accessListIds[i]);
      if (bytes(accessListData.accessListName).length == 0 || !accessListData.isWhiteList) continue;
      
      for (uint256 j = 0; j < accessListData.CorpIds.length; j++) {
        if (accessListData.CorpIds[j] == characterCorpId) return true;
      }
      for (uint256 j = 0; j < accessListData.CharIds.length; j++) {
        if (accessListData.CharIds[j] == characterId) return true;
      }
    }

    return false;
  }
}
