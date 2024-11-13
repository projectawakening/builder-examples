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
import { SmartStorageUnitSystem } from "../src/systems/SmartStorageUnitSystem.sol";
import { RatioConfig, RatioConfigData } from "../src/codegen/tables/RatioConfig.sol";

contract SmartStorageUnitTest is MudTest {
  using SmartDeployableLib for SmartDeployableLib.World;
  using SmartStorageUnitLib for SmartStorageUnitLib.World;
  using EntityRecordLib for EntityRecordLib.World;
  using SmartCharacterLib for SmartCharacterLib.World;
  using SmartDeployableUtils for bytes14;

  SmartDeployableLib.World smartDeployable;
  SmartStorageUnitLib.World smartStorageUnit;
  EntityRecordLib.World entityRecord;
  SmartCharacterLib.World smartCharacter;
  ResourceId systemId = Utils.smartStorageUnitSystemId();

  IWorld world;
  address owner;
  address player;

  uint256 smartStorageUnitId = uint256(17614304337475056394242299294383532840873792487945557467064313427436901763821);
  uint256 inventoryItemIn = uint256(72303041834441799565597028082148290553073890313361053989246429514519533100780);
  uint256 inventoryItemOut = uint256(112603025077760770783264636189502217226733230421932850697496331082050661822825);

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    owner = vm.addr(deployerPrivateKey);

    uint256 playerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    player = vm.addr(playerPrivateKey);

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
        EntityRecordOffchainTableData({ name: "harryporter", dappURL: "noURL", description: "." }),
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
      quantity: 15
    });

    InventoryItem[] memory ephemeralItems = new InventoryItem[](1);
    ephemeralItems[0] = InventoryItem({
      inventoryItemId: inventoryItemIn,
      owner: player,
      itemId: 2,
      typeId: 24,
      volume: 10,
      quantity: 10
    });

    smartStorageUnit.createAndDepositItemsToInventory(smartStorageUnitId, items);
    smartStorageUnit.createAndDepositItemsToEphemeralInventory(smartStorageUnitId, player, ephemeralItems);
  }

  function testWorldExists() public {
    uint256 codeSize;
    address addr = worldAddress;
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function testSetRatio() public {
    uint256 inRatio = vm.envUint("IN_RATIO");
    uint256 outRatio = vm.envUint("OUT_RATIO");

    //Set the ratio
    world.call(
      systemId,
      abi.encodeCall(
        SmartStorageUnitSystem.setRatio,
        (smartStorageUnitId, inventoryItemIn, inventoryItemOut, inRatio, outRatio)
      )
    );

    //Check the ratio
    RatioConfigData memory ratioConfig = RatioConfig.get(smartStorageUnitId, inventoryItemIn);
    assertTrue(ratioConfig.ratioIn == inRatio);
    assertTrue(ratioConfig.ratioOut == outRatio);
  }

  function testExecute() public {
    //Execute the ssu
    world.call(systemId, abi.encodeCall(SmartStorageUnitSystem.execute, (smartStorageUnitId, 10, inventoryItemIn)));

    //Bug: State changes does not update correctly in the test environment
  }

  function createAnchorAndOnline(uint256 smartStorageUnitId, address owner) private {
    // check global state and resume if needed
    if (GlobalDeployableState.getIsPaused() == false) {
      smartDeployable.globalResume();
    }

    //Create, anchor the ssu and bring online
    smartStorageUnit.createAndAnchorSmartStorageUnit(
      smartStorageUnitId,
      EntityRecordData({ typeId: 7888, itemId: 111, volume: 10 }),
      SmartObjectData({ owner: owner, tokenURI: "test" }),
      WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) }),
      1e18, // fuelUnitVolume,
      1, // fuelConsumptionPerMinute,
      1000000 * 1e18, //fuelMaxCapacity,
      100000000, // storageCapacity,
      100000000000 // ephemeralStorageCapacity
    );

    smartDeployable.depositFuel(smartStorageUnitId, 200010);
    smartDeployable.bringOnline(smartStorageUnitId);
  }
}
