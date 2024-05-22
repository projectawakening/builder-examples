// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { ResourceId, WorldResourceIdLib, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { RESOURCE_SYSTEM, RESOURCE_TABLE } from "@latticexyz/world/src/worldResourceTypes.sol";
import { EntityRecordTableData } from "@eveworld/world/src/codegen/tables/EntityRecordTable.sol";

import { EveSystem } from "@eveworld/smart-object-framework/src/systems/internal/EveSystem.sol";
import { ENTITY_RECORD_DEPLOYMENT_NAMESPACE, SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE, SMART_OBJECT_DEPLOYMENT_NAMESPACE, SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE, INVENTORY_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { SmartObjectLib } from "@eveworld/smart-object-framework/src/SmartObjectLib.sol";
import { SmartStorageUnitLib } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";

import { IWarEffortErrors } from "../IWarEffortErrors.sol";

import { DeployableTokenTable } from "@eveworld/world/src/codegen/tables/DeployableTokenTable.sol";
import { EntityTable } from "@eveworld/smart-object-framework/src/codegen/tables/EntityTable.sol";
import { EntityRecordData } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { EntityRecordTable } from "@eveworld/world/src/codegen/tables/EntityRecordTable.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";
import { LocationTableData } from "@eveworld/world/src/codegen/tables/LocationTable.sol";
import { InventoryTable } from "@eveworld/world/src/codegen/tables/InventoryTable.sol";
import { InventoryItemTable, InventoryItemTableData } from "@eveworld/world/src/codegen/tables/InventoryItemTable.sol";
import { WarEffortTable } from "../../codegen/tables/WarEffortTable.sol";

import { Utils as SmartObjectFrameworkUtils } from "@eveworld/smart-object-framework/src/utils.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { Utils as EntityRecordUtils } from "@eveworld/world/src/modules/entity-record/Utils.sol";
import { Utils as InventoryUtils } from "@eveworld/world/src/modules/inventory/Utils.sol";
import { Utils } from "../Utils.sol";

import { IERC721Mintable } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721Mintable.sol";
import { IERC20Mintable } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20Mintable.sol";

import { SmartObjectData, WorldPosition } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";


import { OBJECT, WAR_EFFORT_CLASS_ID } from "../constants.sol";

/**
 * @title GateKeep storage unit
 * @notice contains hook logic that modifies a vanilla SSU into a GateKeep storage unit, war-effort-style
 * users can only deposit a pre-determined kind of items in it, no withdrawals are allowed (transaction)
 */
contract WarEffort is EveSystem, IWarEffortErrors {
  using WorldResourceIdInstance for ResourceId;
  using Utils for bytes14;
  using SmartObjectFrameworkUtils for bytes14;
  using SmartDeployableUtils for bytes14;
  using EntityRecordUtils for bytes14;
  using InventoryUtils for bytes14;
  using SmartObjectLib for SmartObjectLib.World;
  using SmartStorageUnitLib for SmartStorageUnitLib.World;

  modifier onlySSUOwner(uint256 smartObjectId) {
    if (
      _initialMsgSender() !=
      IERC721Mintable(DeployableTokenTable.getErc721Address(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE.deployableTokenTableId())).ownerOf(
        smartObjectId
      )
    ) {
      revert WarEffort_NotSSUOwner(smartObjectId);
    }
    _;
  }

  /**
   * @notice Create and anchor a War Effort storage unit
   * @dev Create and anchor a smart storage unit by smart object id
   * @param smartObjectId The smart object id
   * @param entityRecordData The entity record data of the smart object
   * @param smartObjectData is the token metadata of the smart object
   * @param worldPosition The position of the smart object in the game
   * @param storageCapacity The storage capacity of the smart storage unit
   * @param ephemeralStorageCapacity The personal storage capacity of the smart storage unit
   */
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
  ) public hookable(smartObjectId, _systemId()) {
    SmartStorageUnitLib
      .World(IBaseWorld(_world()), SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE)
      .createAndAnchorSmartStorageUnit(
        smartObjectId,
        entityRecordData,
        smartObjectData,
        worldPosition,
        fuelUnitVolume,
        fuelConsumptionPerMinute,
        fuelMaxCapacity,
        storageCapacity,
        ephemeralStorageCapacity
      );
    if (EntityTable.getDoesExists(_namespace().entityTableTableId(), smartObjectId) == false) {
      // register smartObjectId as an object
      _smartObjectLib().registerEntity(smartObjectId, OBJECT);
    }
    _smartObjectLib().tagEntity(smartObjectId, WAR_EFFORT_CLASS_ID);
  }

  /**
   * @notice just tags an already existing SSU as a War Effort storage unit
   * @param smartObjectId The smart object id
   */
  function associateSSUToWarEffort(uint256 smartObjectId) public onlySSUOwner(smartObjectId) hookable(smartObjectId, _systemId()) {
    if (EntityTable.getDoesExists(_namespace().entityTableTableId(), smartObjectId) == false) {
      // register smartObjectId as an object
      _smartObjectLib().registerEntity(smartObjectId, OBJECT);
    }
    SmartObjectLib.World(IBaseWorld(_world()), SMART_OBJECT_DEPLOYMENT_NAMESPACE).tagEntity(
      smartObjectId,
      WAR_EFFORT_CLASS_ID
    );
  }

  function setAcceptedItemTypeId(
    uint256 smartObjectId,
    uint256 entityTypeId
  ) public onlySSUOwner(smartObjectId) hookable(smartObjectId, _systemId()) {
    WarEffortTable.setAcceptedItemTypeId(_namespace().warEffortTableId(), smartObjectId, entityTypeId);
  }

  function setTargetQuantity(
    uint256 smartObjectId,
    uint256 targetItemQuantity
  ) public onlySSUOwner(smartObjectId) hookable(smartObjectId, _systemId()) {
    WarEffortTable.setTargetQuantity(_namespace().warEffortTableId(), smartObjectId, targetItemQuantity);
  }

  function warEffortEphemeralToInventoryTransferHook(uint256 smartObjectId, InventoryItem[] memory items) public {
    if (items.length != 1) revert WarEffort_WrongItemArrayLength();

    uint256 expectedItemTypeId = WarEffortTable.getAcceptedItemTypeId(_namespace().warEffortTableId(), smartObjectId);
    if (items[0].typeId != expectedItemTypeId) revert WarEffort_WrongDepositType(expectedItemTypeId, items[0].typeId);

    uint256 storedQuantity = _getTypeIdQuantity(smartObjectId, expectedItemTypeId);
    uint256 targetQuantity = WarEffortTable.getTargetQuantity(_namespace().warEffortTableId(), smartObjectId);
    if (storedQuantity + items[0].quantity > targetQuantity) {
      revert WarEffort_DepositOverTargetLimit();
    } else if (storedQuantity + items[0].quantity == targetQuantity) {
      WarEffortTable.setIsGoalReached(_namespace().warEffortTableId(), smartObjectId, true);
    }

    // must be added as a BeforeHook to the related Inventory function, to GATE_KEEPER_CLASS_ID tagged entities
    // _;
  }

  function warEffortDepositToInventoryHook(uint256 smartObjectId, InventoryItem[] memory items) public {
    if (items.length != 1) revert WarEffort_WrongItemArrayLength();

    uint256 expectedItemTypeId = WarEffortTable.getAcceptedItemTypeId(_namespace().warEffortTableId(), smartObjectId);
    if (items[0].typeId != expectedItemTypeId) revert WarEffort_WrongDepositType(expectedItemTypeId, items[0].typeId);

    uint256 storedQuantity = _getTypeIdQuantity(smartObjectId, expectedItemTypeId);
    uint256 targetQuantity = WarEffortTable.getTargetQuantity(_namespace().warEffortTableId(), smartObjectId);
    if (storedQuantity + items[0].quantity > targetQuantity) {
      revert WarEffort_DepositOverTargetLimit();
    } else if (storedQuantity + items[0].quantity == targetQuantity) {
      WarEffortTable.setIsGoalReached(_namespace().warEffortTableId(), smartObjectId, true);
    }

    // must be added as a BeforeHook to the related Inventory function, to GATE_KEEPER_CLASS_ID tagged entities
    // _;
  }

  function warEffortInventoryToEphemeralTransferHook(uint256 smartObjectId, InventoryItem[] memory items) public onlySSUOwner(smartObjectId) {
    // restricts item withdrawals from War Effort SSUs to its owner only
    // _;
  }

  function warEffortWithdrawFromInventoryHook(uint256 smartObjectId, InventoryItem[] memory items) public onlySSUOwner(smartObjectId) {
    // restricts item withdrawals from War Effort SSUs to its owner only
    // _;
  }

  function _getTypeIdQuantity(uint256 smartObjectId, uint256 reqTypeId) internal view returns (uint256 quantity) {
    uint256[] memory items = InventoryTable.getItems(INVENTORY_DEPLOYMENT_NAMESPACE.inventoryTableId(), smartObjectId);
    for (uint i = 0; i < items.length; i++) {
      uint256 itemTypeId = EntityRecordTable.getTypeId(
        ENTITY_RECORD_DEPLOYMENT_NAMESPACE.entityRecordTableId(),
        items[i]
      );
      if (itemTypeId == reqTypeId) {
        quantity += InventoryItemTable.getQuantity(
          INVENTORY_DEPLOYMENT_NAMESPACE.inventoryItemTableId(),
          smartObjectId,
          items[i]
        );
      }
    }
  }

  function _smartObjectLib() internal view returns (SmartObjectLib.World memory) {
    return SmartObjectLib.World({ iface: IBaseWorld(_world()), namespace: SMART_OBJECT_DEPLOYMENT_NAMESPACE });
  }

  function _systemId() internal view returns (ResourceId) {
    return _namespace().warEffortSystemId();
  }
}
