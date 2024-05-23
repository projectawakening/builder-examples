// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { World } from "@latticexyz/world/src/World.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { PuppetModule } from "@latticexyz/world-modules/src/modules/puppet/PuppetModule.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { NamespaceOwner } from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";
import { IModule } from "@latticexyz/world/src/IModule.sol";
import { registerERC20 } from "@latticexyz/world-modules/src/modules/erc20-puppet/registerERC20.sol";
import { IERC20Mintable } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20Mintable.sol";
import { IERC20Events } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20Events.sol";
import { ERC20MetadataData } from "@latticexyz/world-modules/src/modules/erc20-puppet/tables/ERC20Metadata.sol";
import { SmartObjectFrameworkModule } from "@eveworld/smart-object-framework/src/SmartObjectFrameworkModule.sol";
import { EntityCore } from "@eveworld/smart-object-framework/src/systems/core/EntityCore.sol";
import { HookCore } from "@eveworld/smart-object-framework/src/systems/core/HookCore.sol";
import { ModuleCore } from "@eveworld/smart-object-framework/src/systems/core/ModuleCore.sol";

import "@eveworld/common-constants/src/constants.sol";
import { OBJECT, CLASS, WAR_EFFORT_CLASS_ID, WAR_EFFORT_DEPLOYMENT_NAMESPACE } from "../src/war-effort/constants.sol";
import { WarEffort } from "../src/war-effort/systems/WarEffort.sol";
import { ModulesInitializationLibrary } from "../src/utils/ModulesInitializationLibrary.sol";
import { SOFInitializationLibrary } from "../src/utils/SOFInitializationLibrary.sol";
import { SmartObjectLib } from "@eveworld/smart-object-framework/src/SmartObjectLib.sol";
import { HookType } from "@eveworld/smart-object-framework/src/types.sol";
import { EntityRecordOffchainTable, EntityRecordOffchainTableData } from "@eveworld/world/src/codegen/tables/EntityRecordOffchainTable.sol";
import { EntityRecordTableData, EntityRecordTable } from "@eveworld/world/src/codegen/tables/EntityRecordTable.sol";
import { LocationTable, LocationTableData } from "@eveworld/world/src/codegen/tables/LocationTable.sol";
import { DeployableState, DeployableStateData } from "@eveworld/world/src/codegen/tables/DeployableState.sol";
import { InventoryTable, InventoryTableData } from "@eveworld/world/src/codegen/tables/InventoryTable.sol";
import { InventoryItemTable, InventoryItemTableData } from "@eveworld/world/src/codegen/tables/InventoryItemTable.sol";
import { EphemeralInvTable, EphemeralInvTableData } from "@eveworld/world/src/codegen/tables/EphemeralInvTable.sol";
import { EphemeralInvItemTable, EphemeralInvItemTableData } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";
import { EntityTable } from "@eveworld/smart-object-framework/src/codegen/tables/EntityTable.sol";
import { EphemeralInvCapacityTable } from "@eveworld/world/src/codegen/tables/EphemeralInvCapacityTable.sol";

import { SmartStorageUnitModule } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitModule.sol";
import { StaticDataModule } from "@eveworld/world/src/modules/static-data/StaticDataModule.sol";
import { EntityRecordModule } from "@eveworld/world/src/modules/entity-record/EntityRecordModule.sol";
import { EntityRecordLib } from "@eveworld/world/src/modules/entity-record/EntityRecordLib.sol";
import { ERC721Module } from "@eveworld/world/src/modules/eve-erc721-puppet/ERC721Module.sol";
import { registerERC721 } from "@eveworld/world/src/modules/eve-erc721-puppet/registerERC721.sol";
import { IERC721Mintable } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721Mintable.sol";
import { SmartDeployableModule } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableModule.sol";
import { SmartDeployable } from "@eveworld/world/src/modules/smart-deployable/systems/SmartDeployable.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";
import { InventoryLib } from "@eveworld/world/src/modules/inventory/InventoryLib.sol";
import { WarEffortModule } from "../src/war-effort/WarEffortModule.sol";
import { WarEffortLib } from "../src/war-effort/WarEffortLib.sol";
import { IWarEffort } from "../src/war-effort/interfaces/IWarEffort.sol";
import { LocationModule } from "@eveworld/world/src/modules/location/LocationModule.sol";
import { InventoryModule } from "@eveworld/world/src/modules/inventory/InventoryModule.sol";
import { Inventory } from "@eveworld/world/src/modules/inventory/systems/Inventory.sol";
import { IInventory } from "@eveworld/world/src/modules/inventory/interfaces/IInventory.sol";
import { EphemeralInventory } from "@eveworld/world/src/modules/inventory/systems/EphemeralInventory.sol";
import { InventoryInteract } from "@eveworld/world/src/modules/inventory/systems/InventoryInteract.sol";
import { IInventoryInteract } from "@eveworld/world/src/modules/inventory/interfaces/IInventoryInteract.sol";
import { SmartDeployableErrors } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableErrors.sol";
import { IInventoryErrors } from "@eveworld/world/src/modules/inventory/IInventoryErrors.sol";

import { Utils as CoreUtils } from "@eveworld/smart-object-framework/src/utils.sol";
import { Utils as SmartStorageUnitUtils } from "@eveworld/world/src/modules/smart-storage-unit/Utils.sol";
import { Utils as EntityRecordUtils } from "@eveworld/world/src/modules/entity-record/Utils.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { Utils as LocationUtils } from "@eveworld/world/src/modules/location/Utils.sol";
import { Utils as InventoryUtils } from "@eveworld/world/src/modules/inventory/Utils.sol";
import { Utils as WarEffortUtils } from "../src/war-effort/Utils.sol";
import { State } from "@eveworld/world/src/modules/smart-deployable/types.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";

import { SmartStorageUnitLib } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";
import { StaticDataGlobalTableData } from "@eveworld/world/src/codegen/tables/StaticDataGlobalTable.sol";
import "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { createCoreModule } from "./CreateCoreModule.sol";

contract WarEffortUnitTest is Test {
  using CoreUtils for bytes14;
  using SmartStorageUnitUtils for bytes14;
  using EntityRecordUtils for bytes14;
  using SmartDeployableUtils for bytes14;
  using InventoryUtils for bytes14;
  using LocationUtils for bytes14;
  using WarEffortUtils for bytes14;
  using ModulesInitializationLibrary for IBaseWorld;
  using SOFInitializationLibrary for IBaseWorld;
  using SmartObjectLib for SmartObjectLib.World;
  using EntityRecordLib for EntityRecordLib.World;
  using SmartStorageUnitLib for SmartStorageUnitLib.World;
  using SmartDeployableLib for SmartDeployableLib.World;
  using WarEffortLib for WarEffortLib.World;
  using InventoryLib for InventoryLib.World;
  using WorldResourceIdInstance for ResourceId;

  IBaseWorld world;
  SmartObjectLib.World smartObject;
  EntityRecordLib.World entityRecord;
  IERC721Mintable erc721DeployableToken;
  SmartStorageUnitLib.World smartStorageUnit;
  WarEffortLib.World warEffort;
  SmartDeployableLib.World smartDeployable;
  InventoryLib.World inventory;

  uint256 storageCapacity = type(uint256).max;
  uint256 ephemeralStorageCapacity = type(uint256).max;

  bytes14 constant ERC721_DEPLOYABLE = "DeployableTokn";

  function setUp() public {
    world = IBaseWorld(address(new World()));
    world.initialize(createCoreModule());
    // required for `NamespaceOwner` and `WorldResourceIdLib` to infer current World Address properly
    StoreSwitch.setStoreAddress(address(world));

    // installing SOF & other modules (SmartCharacterModule dependancies)
    world.installModule(
      new SmartObjectFrameworkModule(),
      abi.encode(SMART_OBJECT_DEPLOYMENT_NAMESPACE, new EntityCore(), new HookCore(), new ModuleCore())
    );
    world.initSOF();
    world.initClassAssociation();
    smartObject = SmartObjectLib.World(world, SMART_OBJECT_DEPLOYMENT_NAMESPACE);

    // install module dependancies
    _installModule(new PuppetModule(), 0);
    _installModule(new StaticDataModule(), STATIC_DATA_DEPLOYMENT_NAMESPACE);
    _installModule(new EntityRecordModule(), ENTITY_RECORD_DEPLOYMENT_NAMESPACE);
    _installModule(new LocationModule(), LOCATION_DEPLOYMENT_NAMESPACE);
    world.initStaticData();
    world.initEntityRecord();
    world.initLocation();

    entityRecord = EntityRecordLib.World({ iface: world, namespace: ENTITY_RECORD_DEPLOYMENT_NAMESPACE });

    erc721DeployableToken = registerERC721(
      world,
      ERC721_DEPLOYABLE,
      StaticDataGlobalTableData({ name: "SmartDeployable", symbol: "SD", baseURI: "" })
    );
    // install SmartDeployableModule
    SmartDeployableModule deployableModule = new SmartDeployableModule();
    if (
      NamespaceOwner.getOwner(WorldResourceIdLib.encodeNamespace(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE)) ==
      address(this)
    )
      world.transferOwnership(
        WorldResourceIdLib.encodeNamespace(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE),
        address(deployableModule)
      );
    world.installModule(deployableModule, abi.encode(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE, new SmartDeployable()));
    world.initSmartDeployable();
    smartDeployable = SmartDeployableLib.World(world, SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE);
    smartDeployable.registerDeployableToken(address(erc721DeployableToken));

    // Inventory module installation
    InventoryModule inventoryModule = new InventoryModule();
    if (NamespaceOwner.getOwner(WorldResourceIdLib.encodeNamespace(INVENTORY_DEPLOYMENT_NAMESPACE)) == address(this))
      world.transferOwnership(
        WorldResourceIdLib.encodeNamespace(INVENTORY_DEPLOYMENT_NAMESPACE),
        address(inventoryModule)
      );

    world.installModule(
      inventoryModule,
      abi.encode(INVENTORY_DEPLOYMENT_NAMESPACE, new Inventory(), new EphemeralInventory(), new InventoryInteract())
    );
    world.initInventory();
    inventory = InventoryLib.World(world, INVENTORY_DEPLOYMENT_NAMESPACE);

    // SmartStorageUnitModule installation
    _installModule(new SmartStorageUnitModule(), SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE);
    world.initSSU();
    smartStorageUnit = SmartStorageUnitLib.World(world, SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE);

    // WarEffortModule installation
    _installModule(new WarEffortModule(), WAR_EFFORT_DEPLOYMENT_NAMESPACE);
    world.initWarEffort();
    warEffort = WarEffortLib.World(world, WAR_EFFORT_DEPLOYMENT_NAMESPACE);

    smartObject.registerEntity(WAR_EFFORT_CLASS_ID, CLASS);
    world.associateClassIdToWarEffort(WAR_EFFORT_CLASS_ID);

    smartDeployable.globalResume();

    smartObject.registerEntity(123, OBJECT);
    world.associateEntityRecord(123);
    smartObject.registerEntity(456, OBJECT);
    world.associateEntityRecord(456);

    _registerClassLevelHookWarEffort();
  }

  // helper function to guard against multiple module registrations on the same namespace
  // TODO: Those kind of functions are used across all unit tests, ideally it should be inherited from a base Test contract
  function _installModule(IModule module, bytes14 namespace) internal {
    if (NamespaceOwner.getOwner(WorldResourceIdLib.encodeNamespace(namespace)) == address(this))
      world.transferOwnership(WorldResourceIdLib.encodeNamespace(namespace), address(module));
    world.installModule(module, abi.encode(namespace));
  }

  function _registerClassLevelHookWarEffort() internal {
    ResourceId warEffortSystemId = WAR_EFFORT_DEPLOYMENT_NAMESPACE.warEffortSystemId();
    ResourceId inventoryInteractSystemId = INVENTORY_DEPLOYMENT_NAMESPACE.inventoryInteractSystemId();
    ResourceId inventorySystemId = INVENTORY_DEPLOYMENT_NAMESPACE.inventorySystemId();

    uint256 depositHookId = _registerHook(warEffortSystemId, IWarEffort.warEffortDepositToInventoryHook.selector);
    uint256 withdrawHookId = _registerHook(
      warEffortSystemId,
      IWarEffort.warEffortWithdrawFromInventoryHook.selector
    );
    uint256 transferToInvHookId = _registerHook(
      warEffortSystemId,
      IWarEffort.warEffortEphemeralToInventoryTransferHook.selector
    );
    uint256 transferToEphHookId = _registerHook(
      warEffortSystemId,
      IWarEffort.warEffortInventoryToEphemeralTransferHook.selector
    );

    smartObject.associateHook(WAR_EFFORT_CLASS_ID, depositHookId);
    smartObject.associateHook(WAR_EFFORT_CLASS_ID, withdrawHookId);
    smartObject.associateHook(WAR_EFFORT_CLASS_ID, transferToInvHookId);
    smartObject.associateHook(WAR_EFFORT_CLASS_ID, transferToEphHookId);

    // associating the direct deposit and withdraw inventory functions but we could add the InventoryInteract `transfer` functions alternatively
    smartObject.addHook(depositHookId, HookType.BEFORE, inventorySystemId, IInventory.depositToInventory.selector);
    smartObject.addHook(withdrawHookId, HookType.BEFORE, inventorySystemId, IInventory.withdrawFromInventory.selector);
  }

  function _registerHook(ResourceId systemId, bytes4 functionSelector) internal returns (uint256 hookId) {
    smartObject.registerHook(systemId, functionSelector);
    hookId = uint256(keccak256(abi.encodePacked(systemId, functionSelector)));
  }

  function _createEntityRecords(InventoryItem[] memory _items) internal {
    for (uint i = 0; i < _items.length; i++) {
      entityRecord.createEntityRecord(_items[i].inventoryItemId, _items[i].itemId, _items[i].typeId, _items[i].volume);
    }
  }

  function testSetup() public {
    address smartStorageUnitSystem = Systems.getSystem(
      SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE.smartStorageUnitSystemId()
    );
    ResourceId smartStorageUnitSystemId = SystemRegistry.get(smartStorageUnitSystem);
    assertEq(smartStorageUnitSystemId.getNamespace(), SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE);
  }

  function testCreateAndAnchorWarEffort(uint256 smartObjectId, address owner) public {
    vm.startPrank(owner);
    vm.assume(owner != address(0));

    EntityRecordData memory entityRecordData = EntityRecordData({ typeId: 12345, itemId: 45, volume: 10 });
    SmartObjectData memory smartObjectData = SmartObjectData({ owner: owner, tokenURI: "test" });
    WorldPosition memory worldPosition = WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) });
    vm.assume(
      smartObjectId != 0 &&
        !EntityTable.getDoesExists(SMART_OBJECT_DEPLOYMENT_NAMESPACE.entityTableTableId(), smartObjectId)
    );

    warEffort.createAndAnchorWarEffort(
      smartObjectId,
      entityRecordData,
      smartObjectData,
      worldPosition,
      1e18, // fuelUnitVolume,
      1, // fuelConsumptionPerMinute,
      1000000 * 1e18, // fuelMaxCapacity,
      storageCapacity,
      ephemeralStorageCapacity
    );

    smartDeployable.depositFuel(smartObjectId, 100000);
    smartDeployable.bringOnline(smartObjectId);

    State currentState = DeployableState.getCurrentState(
      SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE.deployableStateTableId(),
      smartObjectId
    );
    assertEq(uint8(currentState), uint8(State.ONLINE));

    EntityRecordTableData memory entityRecordTableData = EntityRecordTable.get(
      ENTITY_RECORD_DEPLOYMENT_NAMESPACE.entityRecordTableId(),
      smartObjectId
    );

    assertEq(entityRecordTableData.typeId, entityRecordData.typeId);
    assertEq(entityRecordTableData.itemId, entityRecordData.itemId);
    assertEq(entityRecordTableData.volume, entityRecordData.volume);

    LocationTableData memory locationTableData = LocationTable.get(
      LOCATION_DEPLOYMENT_NAMESPACE.locationTableId(),
      smartObjectId
    );
    assertEq(locationTableData.solarSystemId, worldPosition.solarSystemId);
    assertEq(locationTableData.x, worldPosition.position.x);
    assertEq(locationTableData.y, worldPosition.position.y);
    assertEq(locationTableData.z, worldPosition.position.z);

    assertEq(erc721DeployableToken.ownerOf(smartObjectId), owner);

    smartStorageUnit.setDeploybaleMetadata(smartObjectId, "testName", "testDappURL", "testdesc");

    EntityRecordOffchainTableData memory entityRecordOffchainTableData = EntityRecordOffchainTable.get(
      ENTITY_RECORD_DEPLOYMENT_NAMESPACE.entityRecordOffchainTableId(),
      smartObjectId
    );

    assertEq(entityRecordOffchainTableData.name, "testName");
    assertEq(entityRecordOffchainTableData.dappURL, "testDappURL");
    assertEq(entityRecordOffchainTableData.description, "testdesc");
  }

  function testEphemeralToInventoryTransferRevertWrongItemType(uint256 smartObjectId, uint256 entityTypeId, address owner) public {
    testCreateAndAnchorWarEffort(smartObjectId, owner);
    vm.assume(entityTypeId != 0);
    InventoryItem[] memory items = new InventoryItem[](1);
    items[0] = InventoryItem({
      inventoryItemId: 123,
      owner: owner,
      itemId: 12,
      typeId: entityTypeId,
      volume: 10,
      quantity: 5
    });
    _createEntityRecords(items);
    warEffort.setAcceptedItemTypeId(smartObjectId, 0);
    warEffort.setTargetQuantity(smartObjectId, 1000000);
    inventory.depositToEphemeralInventory(smartObjectId, owner, items);

    vm.expectRevert();
    inventory.ephemeralToInventoryTransfer(smartObjectId, items);
  }

  function testEphemeralToInventoryTransferRevertTooMuchDeposited(
    uint256 smartObjectId,
    uint256 entityTypeId,
    uint256 quantity,
    uint256 volume,
    address owner
  ) public {
    testCreateAndAnchorWarEffort(smartObjectId, owner);
    vm.assume(volume < type(uint128).max - 1);
    vm.assume(quantity < type(uint128).max - 1);
    vm.assume(quantity * volume < storageCapacity);
    InventoryItem[] memory items = new InventoryItem[](1);
    items[0] = InventoryItem({
      inventoryItemId: 123,
      owner: owner,
      itemId: 12,
      typeId: entityTypeId,
      volume: volume,
      quantity: quantity + 1
    });
    _createEntityRecords(items);
    warEffort.setAcceptedItemTypeId(smartObjectId, entityTypeId);
    warEffort.setTargetQuantity(smartObjectId, quantity);

    inventory.depositToEphemeralInventory(smartObjectId, owner, items);
    vm.expectRevert();
    inventory.ephemeralToInventoryTransfer(smartObjectId, items);

    // deposit up to goal
    items[0] = InventoryItem({
      inventoryItemId: 123,
      owner: owner,
      itemId: 12,
      typeId: entityTypeId,
      volume: volume,
      quantity: quantity
    });
    inventory.depositToEphemeralInventory(smartObjectId, owner, items);
    inventory.ephemeralToInventoryTransfer(smartObjectId, items);

    // then deposit one and see if it reverts
    items[0] = InventoryItem({
      inventoryItemId: 123,
      owner: owner,
      itemId: 12,
      typeId: entityTypeId,
      volume: volume,
      quantity: 1
    });
    inventory.depositToEphemeralInventory(smartObjectId, owner, items);
    vm.expectRevert();
    inventory.ephemeralToInventoryTransfer(smartObjectId, items);
  }

  function testEphemeralToInventoryTransfer(uint256 smartObjectId, uint256 entityTypeId, address owner) public {
    testCreateAndAnchorWarEffort(smartObjectId, owner);

    InventoryItem[] memory items = new InventoryItem[](1);
    items[0] = InventoryItem({
      inventoryItemId: 123,
      owner: owner,
      itemId: 12,
      typeId: entityTypeId,
      volume: 10,
      quantity: 5
    });
    _createEntityRecords(items);
    warEffort.setAcceptedItemTypeId(smartObjectId, entityTypeId);
    warEffort.setTargetQuantity(smartObjectId, 1000000);
    inventory.depositToEphemeralInventory(smartObjectId, owner, items);

    // transfers items from user's ephemeral inventory to SSU's inventory
    inventory.ephemeralToInventoryTransfer(smartObjectId, items);

    InventoryTableData memory inventoryTableData = InventoryTable.get(
      INVENTORY_DEPLOYMENT_NAMESPACE.inventoryTableId(),
      smartObjectId
    );
    uint256 useCapacity = items[0].volume * items[0].quantity;

    assertEq(inventoryTableData.capacity, storageCapacity);
    assertEq(inventoryTableData.usedCapacity, useCapacity);

    InventoryItemTableData memory inventoryItemTableData = InventoryItemTable.get(
      INVENTORY_DEPLOYMENT_NAMESPACE.inventoryItemTableId(),
      smartObjectId,
      items[0].inventoryItemId
    );

    assertEq(inventoryItemTableData.quantity, items[0].quantity);
    assertEq(inventoryItemTableData.index, 0);
  }
}
