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
import { InventoryItemTableData, InventoryItemTable } from "@eveworld/world/src/codegen/tables/InventoryItemTable.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { ToggleSystem } from "../src/systems/ToggleSystem.sol";
import { ToggleTable } from "../src/codegen/tables/ToggleTable.sol";

contract ToggleTest is MudTest {
  using SmartDeployableLib for SmartDeployableLib.World;
  using SmartStorageUnitLib for SmartStorageUnitLib.World;
  using EntityRecordLib for EntityRecordLib.World;
  using SmartCharacterLib for SmartCharacterLib.World;
  using SmartDeployableUtils for bytes14;

  SmartDeployableLib.World smartDeployable;
  SmartStorageUnitLib.World smartStorageUnit;
  EntityRecordLib.World entityRecord;
  SmartCharacterLib.World smartCharacter;
  ResourceId systemId = Utils.toggleSystemId();

  IWorld world;
  address owner;
  address player;

  uint256 smartStorageUnitId = uint256(17614304337475056394242299294383532840873792487945557467064313427436901763821);
  uint256 inventoryItemIn;
  uint256 inventoryItemOut;
  uint64 invItemQuantity = 100;
  uint64 ephItemQuantity = 100;
  uint64 inRatio = 15;
  uint64 outRatio = 5;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);

    inventoryItemIn = vm.envUint("ITEM_IN_ID");
    inventoryItemOut = vm.envUint("ITEM_OUT_ID");

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    owner = vm.addr(deployerPrivateKey);

    player = address(this); // setting the address to the system contract as prank does not work for subsequent calls in world() calls

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

    if (CharactersByAddressTable.get(owner) == 0) {
      smartCharacter.createCharacter(
        123,
        owner,
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
        EntityRecordOffchainTableData({ name: "harrypotter", dappURL: "noURL", description: "." }),
        ""
      );
    }

    createAnchorAndOnline(smartStorageUnitId, owner);

    InventoryItem[] memory items = new InventoryItem[](1);
    items[0] = InventoryItem({
      inventoryItemId: inventoryItemOut,
      owner: owner,
      itemId: 1,
      typeId: 23,
      volume: 10,
      quantity: invItemQuantity
    });

    InventoryItem[] memory ephemeralItems = new InventoryItem[](1);
    ephemeralItems[0] = InventoryItem({
      inventoryItemId: inventoryItemIn,
      owner: player,
      itemId: 2,
      typeId: 24,
      volume: 10,
      quantity: ephItemQuantity
    });

    smartStorageUnit.createAndDepositItemsToInventory(smartStorageUnitId, items);
    smartStorageUnit.createAndDepositItemsToEphemeralInventory(smartStorageUnitId, player, ephemeralItems);
  }  

  /**
   * @dev Check inventory values are correct.
   * @param inventoryItemOutCount The number of items that are traded to the user in the inventory.
   * @param inventoryItemInCount The number of items that are recieved from the user in the inventory.
   * @param ephemeralItemOutCount The number of items that are traded to the SSU in the ephemeral inventory.
   * @param ephemeralItemInCount The number of items that are recieved from the SSU in the ephemeral inventory.
   */
  function checkInventory(uint256 inventoryItemOutCount, uint256 inventoryItemInCount, uint256 ephemeralItemInCount, uint256 ephemeralItemOutCount) public {
    //Inventory
    InventoryItemTableData memory invItemOut = InventoryItemTable.get(smartStorageUnitId, inventoryItemOut);    
    assertEq(invItemOut.quantity, inventoryItemOutCount, "Incorrect amount of items left in the inventory [Item Out]");
    
    InventoryItemTableData memory invItemIn = InventoryItemTable.get(smartStorageUnitId, inventoryItemIn);    
    assertEq(invItemIn.quantity, inventoryItemInCount, "Incorrect amount of items into in the inventory [Item In]");

    //Ephemeral
    EphemeralInvItemTableData memory ephInvItemIn = EphemeralInvItemTable.get(smartStorageUnitId, inventoryItemIn, player);
    assertEq(ephInvItemIn.quantity, ephemeralItemInCount, "Incorrect amount of items left in the ephemeral inventory [Item In]");

    EphemeralInvItemTableData memory ephInvItemOut = EphemeralInvItemTable.get(smartStorageUnitId, inventoryItemOut, player);
    assertEq(ephInvItemOut.quantity, ephemeralItemOutCount, "Incorrect amount of items put into the ephemeral inventory [Item Out]");
  }

  function displayInventory() public view {    
    InventoryItemTableData memory invItem = InventoryItemTable.get(smartStorageUnitId, inventoryItemOut);
    console.log("[INVENTORY] Owner's Inventory [Item Out]: ", invItem.quantity);

    EphemeralInvItemTableData memory ephInvItem = EphemeralInvItemTable.get(smartStorageUnitId, inventoryItemIn, player);
    console.log("[EPHEMERAL] Other Player's Inventory [Item In]: ", ephInvItem.quantity);
  }

  function testWorldExists() public {
    uint256 codeSize;
    address addr = worldAddress;
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function testSetTrue() public {
    //Set the ratio
    world.call(
      systemId,
      abi.encodeCall(
        ToggleSystem.setTrue, smartStorageUnitId
      )
    );

    //Check has been set
    assertTrue(ToggleTable.getIsSet(smartStorageUnitId));
  }

  function createAnchorAndOnline(uint256 smartStorageUnitIdToCreate, address ssuOwner) private {
    // check global state and resume if needed
    if (GlobalDeployableState.getIsPaused() == false) {
      smartDeployable.globalResume();
    }

    //Create, anchor the ssu and bring online
    smartStorageUnit.createAndAnchorSmartStorageUnit(
      smartStorageUnitIdToCreate,
      EntityRecordData({ typeId: 7888, itemId: 111, volume: 10 }),
      SmartObjectData({ owner: ssuOwner, tokenURI: "test" }),
      WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) }),
      1e18, // fuelUnitVolume,
      1, // fuelConsumptionPerMinute,
      1000000 * 1e18, //fuelMaxCapacity,
      100000000, // storageCapacity,
      100000000000 // ephemeralStorageCapacity
    );

    smartDeployable.depositFuel(smartStorageUnitIdToCreate, 200010);
    smartDeployable.bringOnline(smartStorageUnitIdToCreate);
  }
}
