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
import {TurretBlacklist, TurretBlacklistData} from "../codegen/tables/TurretBlacklist.sol";

/**
 * @dev This contract is an example for implementing logic to a smart turret
 */
contract SmartTurretSystem is System {
  using EntityRecordUtils for bytes14;
  using SmartDeployableUtils for bytes14;
  using SmartCharacterUtils for bytes14;

  /**
   * @dev a function to add a character to the blacklist
   * @param smartObjectId The smart turret id
   * @param keyword is the owner to add 
   */
  function setBlacklistKeyword(uint256 smartObjectId, string memory keyword) public {
    // bytes hashedKeyword = keccak256(abi.encodePacked(stringToBytes32(keyword)));
    // string memory hashedKeyword = string(hashedKeyword);
    TurretBlacklist.set(smartObjectId, true, keyword);
  }

  /**
   * @dev a function to add a character to the blacklist
   * @param smartObjectId The smart turret id
   * @param isTrue Whether the blacklist is active or not
   */
  function setBlacklistStatus(uint256 smartObjectId, bool isTrue) public {

    TurretBlacklistData memory blacklistData = TurretBlacklist.get(smartObjectId);
    TurretBlacklist.set(smartObjectId, isTrue, blacklistData.blacklistKeyword);
  }

  /**
   * @dev a function to add a character to the blacklist
   * @param smartObjectId The smart turret id
   */
  function getBlacklistKeyword(uint256 smartObjectId) public returns (TurretBlacklistData memory) {
    return TurretBlacklist.get(smartObjectId);
  }

    /**
   * @dev a function to add a character to the blacklist
   * @param keyword is the owner to add 
   */
  function scrambleBlacklistKeyword(bytes32 keyword) public returns (bytes32 scrambledKeyword) {
    // for (uint i = 0; i < keyword.length; i++) {
    //     bytes1 letter = keyword.pop();
    //     scrambledKeyword[i] = letter;
    // }  
    return scrambledKeyword;
  }

function stringToBytes32(string memory source) public pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
}

  /**
   * @dev a function to implement logic for smart turret based on aggression
   * @param smartTurretId The smart turret id
   * @param priorityQueue is the queue of existing targets ordered by priority, index 0 being the lowest priority
   * @param turret is the turret data
   * @param aggressor is the aggressor
   * @param victim is the victim
   */
  function aggression(
    uint256 smartTurretId,
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
