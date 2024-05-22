// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { EntityRecordData, SmartObjectData, WorldPosition } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { ResourceId, WorldResourceIdLib, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";

interface IWarEffort {
  function createAndAnchorWarEffort(
    uint256 smartObjectId,
    EntityRecordData memory entityRecordData,
    SmartObjectData memory smartObjectData,
    WorldPosition memory worldPosition,
    uint256 fuelUnitVolume,
    uint256 fuelConsumptionPerMinute,
    uint256 fuelMaxCapacity,
    uint256 storageCapacity,
    uint256 ephemeralStorageCapacity
  ) external;

  function associateSSUToWarEffort(uint256 smartObjectId) external;

  function setAcceptedItemTypeId(uint256 smartObjectId, uint256 entityTypeId) external;

  function setTargetQuantity(uint256 smartObjectId, uint256 targetItemQuantity) external;

  function warEffortEphemeralToInventoryTransferHook(uint256 smartObjectId, InventoryItem[] memory items) external;

  function warEffortInventoryToEphemeralTransferHook(uint256 smartObjectId, InventoryItem[] memory items) external;

  function warEffortDepositToInventoryHook(uint256 smartObjectId, InventoryItem[] memory items) external;

  function warEffortWithdrawFromInventoryHook(uint256 smartObjectId, InventoryItem[] memory items) external;
}
