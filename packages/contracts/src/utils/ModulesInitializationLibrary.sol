// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import "@eveworld/common-constants/src/constants.sol";

import { Utils as EntityRecordUtils } from "@eveworld/world/src/modules/entity-record/Utils.sol";
import { ENTITY_RECORD_MODULE_NAME } from "@eveworld/world/src/modules/entity-record/constants.sol";
import { Utils as StaticDataUtils } from "@eveworld/world/src/modules/static-data/Utils.sol";
import { STATIC_DATA_MODULE_NAME } from "@eveworld/world/src/modules/static-data/constants.sol";
import { Utils as LocationUtils } from "@eveworld/world/src/modules/location/Utils.sol";
import { LOCATION_MODULE_NAME } from "@eveworld/world/src/modules/location/constants.sol";
import { Utils as SmartCharacterUtils } from "@eveworld/world/src/modules/smart-character/Utils.sol";
import { SMART_CHARACTER_MODULE_NAME } from "@eveworld/world/src/modules/smart-character/constants.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { SMART_DEPLOYABLE_MODULE_NAME } from "@eveworld/world/src/modules/smart-deployable/constants.sol";
import { Utils as InventoryUtils } from "@eveworld/world/src/modules/inventory/Utils.sol";
import { INVENTORY_MODULE_NAME } from "@eveworld/world/src/modules/inventory/constants.sol";
import { Utils as SSUUtils } from "@eveworld/world/src/modules/smart-storage-unit/Utils.sol";
import { SMART_STORAGE_MODULE_NAME } from "@eveworld/world/src/modules/smart-storage-unit/constants.sol";

import { Utils as ItemSellerUtils } from "../item-seller/Utils.sol";
import { ITEM_SELLER_MODULE_NAME, ITEM_SELLER_DEPLOYMENT_NAMESPACE, OBJECT, CLASS, ITEM_SELLER_CLASS_ID } from "../item-seller/constants.sol";

import { SmartObjectLib } from "@eveworld/smart-object-framework/src/SmartObjectLib.sol";

library ModulesInitializationLibrary {
  using SmartObjectLib for SmartObjectLib.World;
  using EntityRecordUtils for bytes14;
  using StaticDataUtils for bytes14;
  using LocationUtils for bytes14;
  using SmartCharacterUtils for bytes14;
  using SmartDeployableUtils for bytes14;
  using InventoryUtils for bytes14;
  using SSUUtils for bytes14;
  using ItemSellerUtils for bytes14;

  /**
   * @notice registers the Entity Record module into Frontier's Smart Object Framework
   * @dev module must first be registered into MUD through either `mud deploy` and/or a `__Module` contract
   * or both
   * @param world interface
   */
  function initEntityRecord(IBaseWorld world) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).registerEVEModule(
      _moduleId(ENTITY_RECORD_DEPLOYMENT_NAMESPACE, ENTITY_RECORD_MODULE_NAME),
      ENTITY_RECORD_MODULE_NAME,
      ENTITY_RECORD_DEPLOYMENT_NAMESPACE.entityRecordSystemId()
    );
  }

  /**
   * @notice associates an entity to the Entity Record module
   * @dev entity needs to be registered first, and Entity Record module needs to be fully initialized
   * Also, SOF needs to be initialized too before doing the steps above.
   * Ideally, only use this on Object entities, not Classes
   * @param world interface
   * @param entityId entityId of the object or class to associate to the module
   */
  function associateEntityRecord(IBaseWorld world, uint256 entityId) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).associateModule(
      entityId,
      _moduleId(ENTITY_RECORD_DEPLOYMENT_NAMESPACE, ENTITY_RECORD_MODULE_NAME)
    );
  }

  /**
   * @notice creates and associates an entity to the Entity Record module
   * @dev entity needs to be registered first, and Entity Record module needs to be fully initialized
   * Also, SOF needs to be initialized too before doing the steps above.
   * Ideally, only use this on Object entities, not Classes
   * @param world interface
   * @param entityId entityId of the object or class to associate to the module
   */
  function createAndAssociateEntityRecord(IBaseWorld world, uint256 entityId) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).registerEntity(entityId, OBJECT);
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).associateModule(
      entityId,
      _moduleId(ENTITY_RECORD_DEPLOYMENT_NAMESPACE, ENTITY_RECORD_MODULE_NAME)
    );
  }

  /**
   * @notice registers the Static Data module into Frontier's Smart Object Framework
   * @dev module must first be registered into MUD through either `mud deploy` and/or a `__Module` contract
   * @param world interface
   */
  function initStaticData(IBaseWorld world) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).registerEVEModule(
      _moduleId(STATIC_DATA_DEPLOYMENT_NAMESPACE, STATIC_DATA_MODULE_NAME),
      STATIC_DATA_MODULE_NAME,
      STATIC_DATA_DEPLOYMENT_NAMESPACE.staticDataSystemId()
    );
  }

  /**
   * @notice associates an entity to the Static Data module
   * @dev entity needs to be registered first, and StaticData module needs to be fully initialized
   * Also, SOF needs to be initialized too before doing the steps above
   * Ideally, only use this on Object entities, not Classes
   * @param world interface
   * @param entityId entityId of the object or class to associate to the module
   */
  function associateStaticData(IBaseWorld world, uint256 entityId) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).associateModule(
      entityId,
      _moduleId(STATIC_DATA_DEPLOYMENT_NAMESPACE, STATIC_DATA_MODULE_NAME)
    );
  }

  /**
   * @notice registers the Location module into Frontier's Smart Object Framework
   * @dev module must first be registered into MUD through either `mud deploy` and/or a `__Module` contract
   * @param world interface
   */
  function initLocation(IBaseWorld world) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).registerEVEModule(
      _moduleId(LOCATION_DEPLOYMENT_NAMESPACE, LOCATION_MODULE_NAME),
      LOCATION_MODULE_NAME,
      LOCATION_DEPLOYMENT_NAMESPACE.locationSystemId()
    );
  }

  /**
   * @notice associates an entity to the Location module
   * @dev entity needs to be registered first, and Location module needs to be fully initialized
   * Also, SOF needs to be initialized too before doing the steps above
   * Ideally, only use this on Object entities, not Classes
   * @param world interface
   * @param entityId entityId of the object or class to associate to the module
   */
  function associateLocation(IBaseWorld world, uint256 entityId) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).associateModule(
      entityId,
      _moduleId(LOCATION_DEPLOYMENT_NAMESPACE, LOCATION_MODULE_NAME)
    );
  }

  /**
   * @notice registers the Smart Character module into Frontier's Smart Object Framework
   * @dev module must first be registered into MUD through either `mud deploy` and/or a `__Module` contract
   * @param world interface
   */
  function initSmartCharacter(IBaseWorld world) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).registerEVEModule(
      _moduleId(SMART_CHARACTER_DEPLOYMENT_NAMESPACE, SMART_CHARACTER_MODULE_NAME),
      SMART_CHARACTER_MODULE_NAME,
      SMART_CHARACTER_DEPLOYMENT_NAMESPACE.smartCharacterSystemId()
    );
  }

  /**
   * @notice associates an entity to the Smart Character module
   * @dev entity needs to be registered first, and Smart Character module needs to be fully initialized
   * Also, SOF needs to be initialized too before doing the steps above
   * Ideally, only use this on Object entities, not Classes
   * Note: this only associates the Smart Character module; to fully work, the entity needs to be also
   * associated to Entity Record and Static Data modules.
   * @param world interface
   * @param entityId entityId of the object or class to associate to the module
   */
  function associateSmartCharacter(IBaseWorld world, uint256 entityId) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).associateModule(
      entityId,
      _moduleId(SMART_CHARACTER_DEPLOYMENT_NAMESPACE, SMART_CHARACTER_MODULE_NAME)
    );
  }

  /**
   * @notice registers the Smart Deployable module into Frontier's Smart Object Framework
   * @dev module must first be registered into MUD through either `mud deploy` and/or a `__Module` contract
   * @param world interface
   */
  function initSmartDeployable(IBaseWorld world) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).registerEVEModule(
      _moduleId(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE, SMART_DEPLOYABLE_MODULE_NAME),
      SMART_DEPLOYABLE_MODULE_NAME,
      SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE.smartDeployableSystemId()
    );
  }

  /**
   * @notice associates an entity to the Smart Deployable module
   * @dev entity needs to be registered first, and Deployable module needs to be fully initialized
   * Also, SOF needs to be initialized too before doing the steps above
   * Ideally, only use this on Object entities, not Classes
   * Note: this only associates the Smart Character module; to fully work, the entity needs to be also
   * associated to Entity Record, Static Data and Location modules.
   * @param world interface
   * @param entityId entityId of the object or class to associate to the module
   */
  function associateSmartDeployable(IBaseWorld world, uint256 entityId) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).associateModule(
      entityId,
      _moduleId(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE, SMART_DEPLOYABLE_MODULE_NAME)
    );
  }

  /**
   * @notice registers the Inventory module into Frontier's Smart Object Framework
   * @dev module must first be registered into MUD through either `mud deploy` and/or a `__Module` contract
   * @param world interface
   */
  function initInventory(IBaseWorld world) internal {
    ResourceId[] memory systemIds = new ResourceId[](3);
    systemIds[0] = INVENTORY_DEPLOYMENT_NAMESPACE.inventorySystemId();
    systemIds[1] = INVENTORY_DEPLOYMENT_NAMESPACE.ephemeralInventorySystemId();
    systemIds[2] = INVENTORY_DEPLOYMENT_NAMESPACE.inventoryInteractSystemId();
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).registerEVEModules(
      _moduleId(INVENTORY_DEPLOYMENT_NAMESPACE, INVENTORY_MODULE_NAME),
      INVENTORY_MODULE_NAME,
      systemIds
    );
  }

  /**
   * @notice associates an entity to the Inventory module
   * @dev entity needs to be registered first, and Inventory module needs to be fully initialized
   * Also, SOF needs to be initialized too before doing the steps above
   * Ideally, only use this on Object entities, not Classes
   * Note: this only associates the Inventory module; to fully work, the entity needs to be also
   * associated to all modules related to Smart Deployables.
   * @param world interface
   * @param entityId entityId of the object or class to associate to the module
   */
  function associateInventory(IBaseWorld world, uint256 entityId) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).associateModule(
      entityId,
      _moduleId(INVENTORY_DEPLOYMENT_NAMESPACE, INVENTORY_MODULE_NAME)
    );
  }

  /**
   * @notice registers the Smart Storage Unit module into Frontier's Smart Object Framework
   * @dev module must first be registered into MUD through either `mud deploy` and/or a `__Module` contract
   * @param world interface
   */
  function initSSU(IBaseWorld world) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).registerEVEModule(
      _moduleId(SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE, SMART_STORAGE_MODULE_NAME),
      SMART_STORAGE_MODULE_NAME,
      SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE.smartStorageUnitSystemId()
    );
  }

  /**
   * @notice associates an entity to the Smart Storage Unit module
   * @dev entity needs to be registered first, and Smart Storage Unit module needs to be fully initialized
   * Also, SOF needs to be initialized too before doing the steps above
   * Ideally, only use this on Object entities, not Classes
   * Note: this only associates the Smart Storage Unit module; to fully work, the entity needs to be also
   * associated to all modules related to Smart Deployables and Inventory.
   * @param world interface
   * @param entityId entityId of the object or class to associate to the module
   */
  function associateSSU(IBaseWorld world, uint256 entityId) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).associateModule(
      entityId,
      _moduleId(SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE, SMART_STORAGE_MODULE_NAME)
    );
  }

  /**
   * @notice registers the Gate Keeper module into Frontier's Smart Object Framework
   * @dev module must first be registered into MUD through either `mud deploy` and/or a `__Module` contract
   * @param world interface
   */
  function initItemSeller(IBaseWorld world) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).registerEVEModule(
      _moduleId(ITEM_SELLER_DEPLOYMENT_NAMESPACE, ITEM_SELLER_MODULE_NAME),
      ITEM_SELLER_MODULE_NAME,
      ITEM_SELLER_DEPLOYMENT_NAMESPACE.itemSellerSystemId()
    );
  }

  /**
   * @notice associates an entity to the Gate Keeper module
   * @dev entity needs to be registered first, and Gate Keeper module needs to be fully initialized
   * Also, SOF needs to be initialized too before doing the steps above
   * Ideally, only use this on Object entities, not Classes
   * Note: this only associates the Gate Keeper module; to fully work, the entity needs to be also
   * associated to all modules related to Smart Deployables and Inventory.
   * @param world interface
   * @param entityId entityId of the object or class to associate to the module
   */
  function associateItemSeller(IBaseWorld world, uint256 entityId) internal {
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).associateModule(
      entityId,
      _moduleId(ITEM_SELLER_DEPLOYMENT_NAMESPACE, ITEM_SELLER_MODULE_NAME)
    );
  }

  /**
   * @notice creates a class from a given Frontier Type ID and associates all modules related to Gate Keeper to it
   * @param world interface
   * @param frontierTypeId the frontier typeId we want to create a SOF class for
   * @return classId created
   */
  function registerAndAssociateTypeIdToItemSeller(
    IBaseWorld world,
    uint256 frontierTypeId
  ) internal returns (uint256 classId) {
    uint256[] memory moduleIds = new uint256[](7);
    moduleIds[0] = _moduleId(STATIC_DATA_DEPLOYMENT_NAMESPACE, STATIC_DATA_MODULE_NAME);
    moduleIds[1] = _moduleId(ENTITY_RECORD_DEPLOYMENT_NAMESPACE, ENTITY_RECORD_MODULE_NAME);
    moduleIds[2] = _moduleId(LOCATION_DEPLOYMENT_NAMESPACE, LOCATION_MODULE_NAME);
    moduleIds[3] = _moduleId(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE, SMART_DEPLOYABLE_MODULE_NAME);
    moduleIds[4] = _moduleId(INVENTORY_DEPLOYMENT_NAMESPACE, INVENTORY_MODULE_NAME);
    moduleIds[5] = _moduleId(SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE, SMART_STORAGE_MODULE_NAME);
    moduleIds[6] = _moduleId(ITEM_SELLER_DEPLOYMENT_NAMESPACE, ITEM_SELLER_MODULE_NAME);
    classId = _typeIdToClassId(frontierTypeId);
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).registerEntity(classId, CLASS);
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).associateModules(classId, moduleIds);
  }

  /**
   * @notice associates all modules related to Gate Keeper to a classId
   * @dev the class entity needs to be registered in the SOF prior to calling this
   * @param world interface
   * @param classId we want to associate SSU modules and its dependencies to
   */
  function associateClassIdToItemSeller(IBaseWorld world, uint256 classId) internal {
    uint256[] memory moduleIds = new uint256[](7);
    moduleIds[0] = _moduleId(STATIC_DATA_DEPLOYMENT_NAMESPACE, STATIC_DATA_MODULE_NAME);
    moduleIds[1] = _moduleId(ENTITY_RECORD_DEPLOYMENT_NAMESPACE, ENTITY_RECORD_MODULE_NAME);
    moduleIds[2] = _moduleId(LOCATION_DEPLOYMENT_NAMESPACE, LOCATION_MODULE_NAME);
    moduleIds[3] = _moduleId(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE, SMART_DEPLOYABLE_MODULE_NAME);
    moduleIds[4] = _moduleId(INVENTORY_DEPLOYMENT_NAMESPACE, INVENTORY_MODULE_NAME);
    moduleIds[5] = _moduleId(SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE, SMART_STORAGE_MODULE_NAME);
    moduleIds[6] = _moduleId(ITEM_SELLER_DEPLOYMENT_NAMESPACE, ITEM_SELLER_MODULE_NAME);
    _sofLib(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE).associateModules(classId, moduleIds);
  }

  /**
   * @notice helper function that returns a valid Library instance to call SOF methods
   * @param world interface
   * @param namespace where the SOF has been deployed
   * @return a `SmartObjectLib.World` structure
   */
  function _sofLib(IBaseWorld world, bytes14 namespace) internal pure returns (SmartObjectLib.World memory) {
    return SmartObjectLib.World({ namespace: namespace, iface: world });
  }

  /**
   * @notice helper function to calculate SOF moduleIds
   * @param moduleNamespace the namespace that module is deployed to
   * @param moduleName name of the module
   * @return the resourceId of that module, unwrapped into an uint256 variable
   */
  function _moduleId(bytes14 moduleNamespace, bytes16 moduleName) internal pure returns (uint256) {
    return uint256(ResourceId.unwrap(WorldResourceIdLib.encode(RESOURCE_SYSTEM, moduleNamespace, moduleName)));
  }

  /**
   * @notice returns a consumable SOF classId, corresponding to `uint256(keccak256("item:{frontierTypeId}"))`
   * @param frontierTypeId the value of the frontier's entity type id
   */
  function _typeIdToClassId(uint256 frontierTypeId) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked("item:", _uintToStr(frontierTypeId))));
  }

  // Helper function to convert a uint256 to a string
  function _uintToStr(uint256 _i) internal pure returns (string memory) {
    if (_i == 0) {
      return "0";
    }
    uint256 j = _i;
    uint256 len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint256 k = len;
    j = _i;
    while (j != 0) {
      bstr[--k] = bytes1(uint8(48 + (j % 10)));
      j /= 10;
    }
    return string(bstr);
  }
}
