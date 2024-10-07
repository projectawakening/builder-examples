// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";
import { EntityRecordData, WorldPosition, SmartObjectData, Coord } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { GlobalDeployableState } from "@eveworld/world/src/codegen/tables/GlobalDeployableState.sol";
import { SmartStorageUnitLib } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";
import { EntityRecordLib } from "@eveworld/world/src/modules/entity-record/EntityRecordLib.sol";
import { SmartCharacterLib } from "@eveworld/world/src/modules/smart-character/SmartCharacterLib.sol";
import { EntityRecordData as CharacterEntityRecord } from "@eveworld/world/src/modules/smart-character/types.sol";
import { EntityRecordOffchainTableData } from "@eveworld/world/src/codegen/tables/EntityRecordOffchainTable.sol";
import { CharactersByAddressTable } from "@eveworld/world/src/codegen/tables/CharactersByAddressTable.sol";
import { DeployableState, DeployableStateData } from "@eveworld/world/src/codegen/tables/DeployableState.sol";
import { State } from "@eveworld/world/src/modules/smart-deployable/types.sol";
import { EphemeralInvItemTableData, EphemeralInvItemTable } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/gate_keeper/Utils.sol";
import { GateKeeperSystem } from "../src/systems/gate_keeper/GateKeeperSystem.sol";
import { GateKeeperConfig, GateKeeperConfigData } from "../src/codegen/tables/GateKeeperConfig.sol";

contract GateKeeperTest is MudTest {
  using SmartDeployableLib for SmartDeployableLib.World;
  using SmartStorageUnitLib for SmartStorageUnitLib.World;
  using EntityRecordLib for EntityRecordLib.World;
  using SmartCharacterLib for SmartCharacterLib.World;
  using SmartDeployableUtils for bytes14;

  SmartDeployableLib.World smartDeployable;
  SmartStorageUnitLib.World smartStorageUnit;
  EntityRecordLib.World entityRecord;
  SmartCharacterLib.World smartCharacter;
  ResourceId systemId = Utils.gateKeeperSystemId();

  IWorld world;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(deployerPrivateKey);

    uint256 playerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    smartDeployable = SmartDeployableLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });
    smartStorageUnit = SmartStorageUnitLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    entityRecord = EntityRecordLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    smartCharacter = SmartCharacterLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    if (CharactersByAddressTable.get(admin) == 0) {
      smartCharacter.createCharacter(
        123,
        admin,
        200003,
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "ron", dappURL: "noURL", description: "." }),
        ""
      );
    }
    if (CharactersByAddressTable.get(player) == 0) {
      smartCharacter.createCharacter(
        456,
        player,
        200004,
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "harryporter", dappURL: "noURL", description: "." }),
        ""
      );
    }

    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 inventoryItem = vm.envUint("INVENTORY_ITEM_ID");
    createAnchorAndOnline(smartStorageUnitId, admin);

    //Create item entity record on-chain
    entityRecord.createEntityRecord(inventoryItem, 0, 23, 50);

    //Put some items in the admin ephemeral inventory
    InventoryItem[] memory items = new InventoryItem[](1);
    items[0] = InventoryItem({
      inventoryItemId: inventoryItem,
      owner: player,
      itemId: 0,
      typeId: 23,
      volume: 10,
      quantity: 15
    });
    smartStorageUnit.createAndDepositItemsToEphemeralInventory(smartStorageUnitId, player, items);
  }

  function testWorldExists() public {
    uint256 codeSize;
    address addr = worldAddress;
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function testConfigureGateKeeper() public {
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 inventoryItemId = vm.envUint("INVENTORY_ITEM_ID");
    uint256 targetQuantity = vm.envUint("TARGET_QUANTITY");

    //Make sure the SSU is online
    assertEq(uint8(DeployableState.getCurrentState(smartStorageUnitId)), uint8(State.ONLINE), "SSU should be online");

    //Make sure the SSU owner is the one configuring the gatekeeper
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(deployerPrivateKey);
    vm.startPrank(admin);

    world.call(
      systemId,
      abi.encodeCall(GateKeeperSystem.configureGateKeeper, (smartStorageUnitId, inventoryItemId, targetQuantity))
    );
  }

  function depositToGateKeeper() public {
    testConfigureGateKeeper();
    //Make sure the SSU is configured as gatekeeper
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 targetQuantity = vm.envUint("TARGET_QUANTITY");
    address player = vm.addr(vm.envUint("PLAYER_PRIVATE_KEY"));

    GateKeeperConfigData memory config = GateKeeperConfig.get(smartStorageUnitId);

    assertEq(config.itemIn, vm.envUint("INVENTORY_ITEM_ID"), "Inventory item id should match");
    assertEq(config.targetItemQuantity, targetQuantity, "Target quantity should match");

    //Ephemeral inventory before deposit
    EphemeralInvItemTableData memory invItem = EphemeralInvItemTable.get(smartStorageUnitId, config.itemIn, player);

    assertEq(invItem.quantity, 15, "Ephemeral inventory should have 15 items");
    world.call(systemId, abi.encodeCall(GateKeeperSystem.depositToSSU, (smartStorageUnitId, targetQuantity)));

    //Ephemeral inventory after deposit
    invItem = EphemeralInvItemTable.get(smartStorageUnitId, config.itemIn, player);
    assertEq(invItem.quantity, 5, "Ephemeral inventory should have 5 items");

    config = GateKeeperConfig.get(smartStorageUnitId);
    assertEq(config.isGoalReached, true, "Goal should be reached");
  }

  function createAnchorAndOnline(uint256 smartStorageUnitId, address admin) private {
    //Create, anchor the ssu and bring online
    smartStorageUnit.createAndAnchorSmartStorageUnit(
      smartStorageUnitId,
      EntityRecordData({ typeId: 7888, itemId: 111, volume: 10 }),
      SmartObjectData({ owner: admin, tokenURI: "test" }),
      WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) }),
      1e18, // fuelUnitVolume,
      1, // fuelConsumptionPerMinute,
      1000000 * 1e18, //fuelMaxCapacity,
      100000000, // storageCapacity,
      100000000000 // ephemeralStorageCapacity
    );

    // check global state and resume if needed
    if (GlobalDeployableState.getIsPaused() == false) {
      smartDeployable.globalResume();
    }

    smartDeployable.depositFuel(smartStorageUnitId, 200010);
    smartDeployable.bringOnline(smartStorageUnitId);
  }
}
