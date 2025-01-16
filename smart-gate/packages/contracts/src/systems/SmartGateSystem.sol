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

/*
function createAccessList(string memory accessListName, bool isWhiteList) public onlyAccessListManager {
    AccessListsData memory existingList = AccessLists.get(accessListName);
    require(bytes(existingList.accessListName).length == 0, "Access list already exists");

    AccessListsData memory newList;
    newList.accessListName = accessListName;
    newList.isWhiteList = isWhiteList;
    newList.CorpIds = new uint256;
    nt.CharIds = new uint256;

    Accets.set(accessListName, newList);
  }

  function deleteAccessList(string memory accessListName) public onlyOwner(sourceGateId) {
    AccessListsData memory existingList = AccessLists.get(accessListName);
    require(bytes(existingList.accessListName).length > 0, "Access list does not exist");
    AccessLists.deleteRecord(accessListName);
  }

  function addAccessListToGate(string memory accessListName, uint256 gateId) public onlyOwner(sourceGateId) {
    AccessListsData memory existingList = AccessLists.get(accessListName);
    require(bytes(existingList.accessListName).length > 0, "Access list does not exist");

    string[] memory accessListIds = GateAccess.get(gateId).accessListIds;
    GateAccess.set(gateId, addElementToArray(accessListIds, accessListName));
  }

  function removeAccessListFromGate(string memory accessListName, uint256 gateId) public onlyOwner(sourceGateId) {
    require(bytes(AccessLists.get(accessListName).accessListName).length > 0, "Access list does not exist");

    string[] memory accessListIds = GateAccess.get(gateId).accessListIds;
    GateAccess.set(gateId, removeElementWithValueFromArray(accessListIds, accessListName));
  }

    function addCharIdToAccessList(uint256 characterId, string memory accessListName) public onlyOwner(sourceGateId) {
      AccessListsData memory accessListsData = AccessLists.get(accessListName);
      require(bytes(accessListsData.accessListName).length > 0, "Access list does not exist");
      accessListsData.CharIds = addElementToArray(accessListsData.CharIds, characterId);
      AccessLists.set(accessListName, accessListsData);
  }

  function removeCharIdFromAccessList(uint256 characterId, string memory accessListName) public onlyOwner(sourceGateId) {
      AccessListsData memory accessListsData = AccessLists.get(accessListName);
      require(bytes(accessListsData.accessListName).length > 0, "Access list does not exist");
      accessListsData.CharIds = removeElementWithValueFromArray(accessListsData.CharIds, characterId);
      AccessLists.set(accessListName, accessListsData);
  }

  function addCorpIdToAccessList(uint256 corpId, string memory accessListName) public onlyOwner(sourceGateId) {
      AccessListsData memory accessListsData = AccessLists.get(accessListName);
      require(bytes(accessListsData.accessListName).length > 0, "Access list does not exist");
      accessListsData.CorpIds = addElementToArray(accessListsData.CorpIds, corpId);
      AccessLists.set(accessListName, accessListsData);
  }

  function removeCorpIdFromAccessList(uint256 corpId, string memory accessListName) public onlyOwner(sourceGateId) {
      AccessListsData memory accessListsData = AccessLists.get(accessListName);
      require(bytes(accessListsData.accessListName).length > 0, "Access list does not exist");
      accessListsData.CorpIds = removeElementWithValueFromArray(accessListsData.CorpIds, corpId);
      AccessLists.set(accessListName, accessListsData);
  }

  function addElementToArray(string[] memory array, string memory newElement) internal pure returns (string[] memory) {
    string[] memory updatedArray = new string[](array.length + 1);
    for (uint256 i = 0; i < array.length; i++) {
      updatedArray[i] = array[i];
    }
    updatedArray[array.length] = newElement;
    return updatedArray;
  }

  function removeElementWithValueFromArray(string[] memory array, string memory value) internal pure returns (string[] memory) {
    uint256 count = 0;
    for (uint256 i = 0; i < array.length; i++) {
      if (keccak256(bytes(array[i])) != keccak256(bytes(value))) count++;
    }
    string[] memory updatedArray = new string[](count);
    uint256 index = 0;
    for (uint256 i = 0; i < array.length; i++) {
      if (keccak256(bytes(array[i])) != keccak256(bytes(value))) {
        updatedArray[index] = array[i];
        index++;
      }
    }
    return updatedArray;
  }
*/
}

