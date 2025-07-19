// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { UNLIMITED_DELEGATION } from "@latticexyz/world/src/constants.sol";
import { IWorldWithContext } from "@eveworld/smart-object-framework-v2/src/IWorldWithContext.sol";

import { SmartCharacterSystem, smartCharacterSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartCharacterSystemLib.sol";
import { Location, LocationData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Location.sol";
import { DeployableState } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/DeployableState.sol";
import { FuelSystem, fuelSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/FuelSystemLib.sol";
import { FuelParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/fuel/types.sol";
import { EntityRecordParams, EntityMetadataParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/types.sol";
import { Tenant, Characters, CharactersByAccount, EntityRecord } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { CreateAndAnchorParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/deployable/types.sol";
import { DeployableSystem, deployableSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/DeployableSystemLib.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { State } from "@eveworld/world-v2/src/codegen/common.sol";
import { entityRecordSystem} from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EntityRecordSystemLib.sol";
import { SmartStorageUnitSystem, smartStorageUnitSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartStorageUnitSystemLib.sol";
import { InventoryItem, InventoryItemData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/InventoryItem.sol";
import { EphemeralInvItem, EphemeralInvItemData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/EphemeralInvItem.sol";
import { EntityRecordParams, EntityMetadataParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/types.sol";
import { CreateInventoryItemParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/inventory/types.sol";
import { InventorySystem, inventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/InventorySystemLib.sol";
import { EphemeralInventorySystem, ephemeralInventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EphemeralInventorySystemLib.sol";
import { InventoryOwnershipSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/ownership/InventoryOwnershipSystem.sol";

import { SmartStorageUnitSystem as CustomSmartStorageUnitSystem } from "../src/systems/SmartStorageUnitSystem.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { RatioConfig, RatioConfigData } from "../src/codegen/tables/RatioConfig.sol";
import { EphemeralInteractSystem, ephemeralInteractSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EphemeralInteractSystemLib.sol";


/**
 * @title SmartStorageUnitTest
 * @notice These tests are used to test the example custom SSU contract in src/systems/SmartStorageUnitSystem.sol
 */
contract SmartStorageUnitTest is MudTest {
  ResourceId systemId = Utils.smartStorageUnitSystemId();

  IWorldWithContext world;

  bytes32 tenantId;

  address admin;
  address player;

  uint256 smartStorageUnitId;

  uint256 itemInTypeID;
  uint256 itemOutTypeID;

  uint256 itemInSmartObjectId;
  uint256 itemOutSmartObjectId;

  //Tribe that can use the Smart Gate
  uint256 ALLOWED_TRIBE_ID = 500;

  //Character IDs
  uint256 ADMIN_CHARACTER_ID = 35000;
  uint256 PLAYER_CHARACTER_ID = 400;

  //Smart Storage Unit ID
  uint256 SSU_ID = 9000;

  // Item Quantities
  uint256 ITEM_IN_QUANTITY = 15;
  uint256 ITEM_OUT_QUANTITY = 10;

  // Test Ratios ( Changing this will cause some tests to fail, and will require some changes to the tests expected values )
  uint64 TEST_RATIO_IN = 5;
  uint64 TEST_RATIO_OUT = 1;

  //Type IDs
  uint256 CHARACTER_TYPE_ID = 42000000100;
  uint256 SSU_TYPE_ID = 77917;
  uint256 FUEL_TYPE_ID = 78437;

  function safeCreateCharacter(address account, uint256 characterId, uint256 tribeId, string memory name) private {
    uint256 smartObjectId = ObjectIdLib.calculateObjectId(tenantId, characterId);
    if (CharactersByAccount.get(account) == 0) {
      smartCharacterSystem.createCharacter(
        smartObjectId, 
        account, 
        tribeId, 
        EntityRecordParams({ tenantId: tenantId, typeId: CHARACTER_TYPE_ID, itemId: characterId, volume: 100 }), 
        EntityMetadataParams({ name: name, dappURL: "noURL", description: "." })
      );
    } else{
      console.log("Character already exists");
    }
  }

  function setUp() public override {
    super.setUp();

    world = IWorldWithContext(worldAddress);
    StoreSwitch.setStoreAddress(worldAddress);

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    admin = vm.addr(deployerPrivateKey);

    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    player = address(this);

    tenantId = Tenant.get();

    vm.startPrank(player, admin);

    safeCreateCharacter(admin, ADMIN_CHARACTER_ID, 7777, "adminCharacter");
    safeCreateCharacter(player, PLAYER_CHARACTER_ID, ALLOWED_TRIBE_ID, "playerCharacter");

    vm.stopPrank();

    // Add delegation setup
    vm.startPrank(player);
    world.registerDelegation(admin, UNLIMITED_DELEGATION, new bytes(0));
    vm.stopPrank();
    vm.startPrank(admin);
    world.registerDelegation(address(this), UNLIMITED_DELEGATION, new bytes(0));
    vm.stopPrank();

    smartStorageUnitId = ObjectIdLib.calculateObjectId(tenantId, SSU_ID);
    
    vm.startPrank(admin, admin);

    createAnchorAndOnline(smartStorageUnitId, SSU_ID, admin, admin);
    
    vm.stopPrank();

    vm.startPrank(admin);

    (address contractAddress, ) = Systems.get(systemId);

    ephemeralInteractSystem.setTransferFromEphemeralAccess(smartStorageUnitId, address(contractAddress), true);
    ephemeralInteractSystem.setTransferToEphemeralAccess(smartStorageUnitId, address(contractAddress), true);

    vm.stopPrank();

    vm.startPrank(player, admin);

    // Create and deposit inventory items
    _depositToInventory(smartStorageUnitId, tenantId, admin);
    _depositToEphemeralInventory(smartStorageUnitId, tenantId, player);

    itemInTypeID = vm.envUint("ITEM_IN_TYPE_ID");
    itemOutTypeID = vm.envUint("ITEM_OUT_TYPE_ID");

    itemInSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, itemInTypeID);
    itemOutSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, itemOutTypeID);
    
    vm.stopPrank();
  }  

  //Test if the world exists
  function testWorldExists() public {
    uint256 codeSize;
    address addr = worldAddress;
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function testCharactersExist() public {
    uint256 playerCharacter = CharactersByAccount.get(player);
    uint256 adminCharacter = CharactersByAccount.get(admin);

    assertTrue(playerCharacter != 0, "Player character should exist");
    assertTrue(adminCharacter != 0, "Admin character should exist");
  }

  function testSSUExists() public {
    assertTrue(DeployableState.getCurrentState(smartStorageUnitId) != State.NULL);
  }

  function testSSUIsOnline() public {
    assertTrue(DeployableState.getCurrentState(smartStorageUnitId) == State.ONLINE);
  }

  function testSSUHasInventoryItems() public {
    uint256 itemInQuantity = InventoryItem.getQuantity(smartStorageUnitId, itemInSmartObjectId);

    assertEq(itemInQuantity, 0, "Item in quantity should be 0");

    uint256 itemOutQuantity = InventoryItem.getQuantity(smartStorageUnitId, itemOutSmartObjectId);

    assertEq(itemOutQuantity, 10, "Item out quantity should be 10");
  }

  function testSSUHasEphemeralItems() public {
    uint256 itemInQuantity = EphemeralInvItem.getQuantity(smartStorageUnitId, player, itemInSmartObjectId);

    assertEq(itemInQuantity, 15, "Item in quantity should be 15");
  }

  function testSetRatio() public {
    vm.startPrank(admin);

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.setRatio,
        (smartStorageUnitId, itemInSmartObjectId, itemOutSmartObjectId, TEST_RATIO_IN, TEST_RATIO_OUT)
      )
    );

    RatioConfigData memory ratioConfigData = RatioConfig.get(smartStorageUnitId, itemInSmartObjectId);

    assertEq(ratioConfigData.ratioIn, TEST_RATIO_IN, "Ratio in should be 5");
    assertEq(ratioConfigData.ratioOut, TEST_RATIO_OUT, "Ratio out should be 1");

    vm.stopPrank();
  }

  function testSetRatioRevertNotAdmin() public {
    vm.startPrank(player);

    vm.expectRevert("Access Denied. You are not the owner of this SSU.");

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.setRatio,
        (smartStorageUnitId, itemInSmartObjectId, itemOutSmartObjectId, TEST_RATIO_IN, TEST_RATIO_OUT)
      )
    );

    vm.stopPrank();
  }

  function testSetRatioRevertInvalidRatio() public {
    uint64 ratioIn = 0;
    uint64 ratioOut = 1;

    vm.startPrank(admin);

    vm.expectRevert("Ratio cannot be less than 1");

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.setRatio,
        (smartStorageUnitId, itemInSmartObjectId, itemOutSmartObjectId, ratioIn, ratioOut)
      )
    );

    ratioIn = 1;
    ratioOut = 0;

    vm.expectRevert("Ratio cannot be less than 1");

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.setRatio,
        (smartStorageUnitId, itemInSmartObjectId, itemOutSmartObjectId, ratioIn, ratioOut)
      )
    );

    vm.stopPrank();
  }
  
  function testSetRatioRevertInvalidItem() public {
    vm.startPrank(admin);

    uint256 randomId = 1;

    vm.expectRevert(abi.encodeWithSelector(InventorySystem.Inventory_InvalidItemObjectId.selector, randomId));

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.setRatio,
        (smartStorageUnitId, randomId, itemOutSmartObjectId, 1, 1)
      )
    );

    vm.stopPrank();
  }

  function testCalculateOutput() public {
    vm.startPrank(admin);

    (uint64 outputAmount, uint64 remainingInput) = abi.decode(world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.calculateOutput,
        (1, 1, 10)
      )
    ), (uint64, uint64));

    assertEq(outputAmount, 10, "Output amount should be 10");
    assertEq(remainingInput, 0, "Remaining input should be 0");

    (outputAmount, remainingInput) = abi.decode(world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.calculateOutput,
        (4, 1, 10)
      )
    ), (uint64, uint64));

    assertEq(outputAmount, 2, "Output amount should be 2");
    assertEq(remainingInput, 2, "Remaining input should be 2");

    vm.stopPrank();
  }

  function testExecute() public {
    testSetRatio();

    expectItems(
      0, // Item In Expected Quantity
      ITEM_IN_QUANTITY, // Item In Expected Ephemeral Quantity
      ITEM_OUT_QUANTITY, // Item Out Expected Quantity
      0 // Item Out Expected Ephemeral Quantity
    );

    vm.startPrank(player);
    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.execute,
        (smartStorageUnitId, 5, itemInSmartObjectId)
      )
    );

    expectItems(
      5, // Item In Expected Quantity
      10, // Item In Expected Ephemeral Quantity
      9, // Item Out Expected Quantity
      1 // Item Out Expected Ephemeral Quantity
    );

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.execute,
        (smartStorageUnitId, 5, itemInSmartObjectId)
      )
    );

    expectItems(
      10, // Item In Expected Quantity
      5, // Item In Expected Ephemeral Quantity
      8, // Item Out Expected Quantity
      2 // Item Out Expected Ephemeral Quantity
    );

    vm.stopPrank();
  }

  function testExecuteItemsLeftOver() public {
    testSetRatio();

    expectItems(
      0, // Item In Expected Quantity
      ITEM_IN_QUANTITY, // Item In Expected Ephemeral Quantity
      ITEM_OUT_QUANTITY, // Item Out Expected Quantity
      0 // Item Out Expected Ephemeral Quantity
    );

    vm.startPrank(player);
    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.execute,
        (smartStorageUnitId, 7, itemInSmartObjectId)
      )
    );

    // It should only take 5 items, not 7
    expectItems(
      5, // Item In Expected Quantity
      10, // Item In Expected Ephemeral Quantity
      9, // Item Out Expected Quantity
      1 // Item Out Expected Ephemeral Quantity
    );

    vm.stopPrank();
  }

  function testExecuteRevertQuantityZero() public {
    vm.startPrank(admin);

    RatioConfig.set(smartStorageUnitId, itemInSmartObjectId, itemOutSmartObjectId, 5, 1);

    expectItems(
      0, // Item In Expected Quantity
      ITEM_IN_QUANTITY, // Item In Expected Ephemeral Quantity
      ITEM_OUT_QUANTITY, // Item Out Expected Quantity
      0 // Item Out Expected Ephemeral Quantity
    );

    vm.stopPrank();
    vm.startPrank(player);

    vm.expectRevert("Quantity cannot be 0 or less");

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.execute,
        (smartStorageUnitId, 0, itemInSmartObjectId)
      )
    );

    expectItems(
      0, // Item In Expected Quantity
      ITEM_IN_QUANTITY, // Item In Expected Ephemeral Quantity
      ITEM_OUT_QUANTITY, // Item Out Expected Quantity
      0 // Item Out Expected Ephemeral Quantity
    );

    vm.stopPrank();
  }

  function testExecuteRevertNoRatio() public {
    expectItems(
      0, // Item In Expected Quantity
      ITEM_IN_QUANTITY, // Item In Expected Ephemeral Quantity
      ITEM_OUT_QUANTITY, // Item Out Expected Quantity
      0 // Item Out Expected Ephemeral Quantity
    );

    vm.startPrank(player);

    vm.expectRevert("Invalid ratio");

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.execute,
        (smartStorageUnitId, 5, itemInSmartObjectId)
      )
    );

    expectItems(
      0, // Item In Expected Quantity
      ITEM_IN_QUANTITY, // Item In Expected Ephemeral Quantity
      ITEM_OUT_QUANTITY, // Item Out Expected Quantity
      0 // Item Out Expected Ephemeral Quantity
    );

    vm.stopPrank();
  }

  function testExecuteRevertOutputQuantityZero() public {
    vm.startPrank(admin);
    RatioConfig.set(smartStorageUnitId, itemInSmartObjectId, itemOutSmartObjectId, 5, 1);
    vm.stopPrank();

    expectItems(
      0, // Item In Expected Quantity
      ITEM_IN_QUANTITY, // Item In Expected Ephemeral Quantity
      ITEM_OUT_QUANTITY, // Item Out Expected Quantity
      0 // Item Out Expected Ephemeral Quantity
    );

    vm.startPrank(player);

    vm.expectRevert("Output quantity cannot be 0 or less");

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.execute,
        (smartStorageUnitId, 1, itemInSmartObjectId)
      )
    );

    expectItems(
      0, // Item In Expected Quantity
      ITEM_IN_QUANTITY, // Item In Expected Ephemeral Quantity
      ITEM_OUT_QUANTITY, // Item Out Expected Quantity
      0 // Item Out Expected Ephemeral Quantity
    );

    vm.stopPrank();
  }

  function testExecuteRevertNotEnoughItemsInput() public {
    vm.startPrank(admin);
    RatioConfig.set(smartStorageUnitId, itemInSmartObjectId, itemOutSmartObjectId, 20, 1);
    vm.stopPrank();

    expectItems(
      0, // Item In Expected Quantity
      ITEM_IN_QUANTITY, // Item In Expected Ephemeral Quantity
      ITEM_OUT_QUANTITY, // Item Out Expected Quantity
      0 // Item Out Expected Ephemeral Quantity
    );

    vm.startPrank(player);

    vm.expectRevert();

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.execute,
        (smartStorageUnitId, 20, itemInSmartObjectId)
      )
    );

    expectItems(
      0, // Item In Expected Quantity
      ITEM_IN_QUANTITY, // Item In Expected Ephemeral Quantity
      ITEM_OUT_QUANTITY, // Item Out Expected Quantity
      0 // Item Out Expected Ephemeral Quantity
    );

    vm.stopPrank();
  }


  function testExecuteRevertNotEnoughItemsOutput() public {
    vm.startPrank(admin);
    RatioConfig.set(smartStorageUnitId, itemInSmartObjectId, itemOutSmartObjectId, 1, 20);
    vm.stopPrank();

    vm.startPrank(player);

    expectItems(
      0, // Item In Expected Quantity
      ITEM_IN_QUANTITY, // Item In Expected Ephemeral Quantity
      ITEM_OUT_QUANTITY, // Item Out Expected Quantity
      0 // Item Out Expected Ephemeral Quantity
    );

    vm.expectRevert();

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartStorageUnitSystem.execute,
        (smartStorageUnitId, 1, itemInSmartObjectId)
      )
    );

    expectItems(
      0, // Item In Expected Quantity
      ITEM_IN_QUANTITY, // Item In Expected Ephemeral Quantity
      ITEM_OUT_QUANTITY, // Item Out Expected Quantity
      0 // Item Out Expected Ephemeral Quantity
    );

    vm.stopPrank();
  }

  function createAnchorAndOnline(uint256 smartAssemblyId, uint256 itemId, address ownerAddress, address admin) private {
    LocationData memory locationParams = LocationData({ solarSystemId: 30000042, x: 1001, y: 1001, z: 1001 });

    EntityRecordParams memory entityRecordParams = EntityRecordParams({
      tenantId: tenantId,
      typeId: SSU_TYPE_ID,
      itemId: itemId,
      volume: 1000
    });

    CreateAndAnchorParams memory deployableParams = CreateAndAnchorParams({
      smartObjectId: smartAssemblyId,
      assemblyType: "SSU",
      entityRecordParams: entityRecordParams,
      owner: ownerAddress,
      locationData: locationParams
    });

    bytes memory result = world.callFrom(
      ownerAddress,
      smartStorageUnitSystem.toResourceId(),
      abi.encodeCall(SmartStorageUnitSystem.createAndAnchorStorageUnit, (deployableParams, 100000000, 100000000, 0))
    );

    entityRecordSystem.createMetadata(smartAssemblyId, EntityMetadataParams({
      name: "Name Here",
      dappURL: "",
      description: "Example SSU for the Smart Assembly Scaffold"
    }));

    vm.stopPrank();

    vm.startPrank(admin);

    uint256 fuelSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, FUEL_TYPE_ID);

    fuelSystem.configureFuelParameters(smartAssemblyId, FuelParams({
      fuelMaxCapacity: 100000000,
      fuelBurnRateInSeconds: 100000000
    }));

    vm.stopPrank();

    vm.startPrank(ownerAddress, admin);

    fuelSystem.depositFuel(smartAssemblyId, fuelSmartObjectId, 1000);

    deployableSystem.bringOnline(smartAssemblyId);
  }

  function expectItems(
    uint256 itemInQuantityExpected,
    uint256 itemInEphemeralQuantityExpected,
    uint256 itemOutQuantityExpected,
    uint256 itemOutEphemeralQuantityExpected
  ) internal {
    uint256 itemInQuantity = InventoryItem.getQuantity(smartStorageUnitId, itemInSmartObjectId);
    assertEq(itemInQuantity, itemInQuantityExpected, "Item in quantity incorrect");

    uint256 itemInEphemeralQuantity = EphemeralInvItem.getQuantity(smartStorageUnitId, player, itemInSmartObjectId);
    assertEq(itemInEphemeralQuantity, itemInEphemeralQuantityExpected, "Item in ephemeral quantity incorrect");

    uint256 itemOutEphemeralQuantity = EphemeralInvItem.getQuantity(smartStorageUnitId, player, itemOutSmartObjectId);
    assertEq(itemOutEphemeralQuantity, itemOutEphemeralQuantityExpected, "Item out ephemeral quantity incorrect");

    uint256 itemOutQuantity = InventoryItem.getQuantity(smartStorageUnitId, itemOutSmartObjectId);
    assertEq(itemOutQuantity, itemOutQuantityExpected, "Item out quantity incorrect");
  }

  function _depositToInventory(uint256 smartStorageUnitId, bytes32 tenantId, address player) private {
    uint256 itemOutTypeID = vm.envUint("ITEM_OUT_TYPE_ID");
    uint256 itemOutSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, itemOutTypeID);

    CreateInventoryItemParams[] memory items = new CreateInventoryItemParams[](1);

    items[0] = CreateInventoryItemParams({
      smartObjectId: itemOutSmartObjectId,
      tenantId: tenantId,
      typeId: itemOutTypeID,
      itemId: 0, // For non-singleton items, itemId is zero
      quantity: ITEM_OUT_QUANTITY, // Non-singleton can have any quantity
      volume: 1
    });

    world.callFrom(
      player,
      inventorySystem.toResourceId(),
      abi.encodeCall(InventorySystem.createAndDepositInventory, (smartStorageUnitId, items))
    );
  }

  function _depositToEphemeralInventory(uint256 smartStorageUnitId, bytes32 tenantId, address player) private {
    uint256 itemInTypeID = vm.envUint("ITEM_IN_TYPE_ID");
    uint256 itemInSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, itemInTypeID);
    CreateInventoryItemParams[] memory ephemeralItems = new CreateInventoryItemParams[](1);

    ephemeralItems[0] = CreateInventoryItemParams({
      smartObjectId: itemInSmartObjectId,
      tenantId: tenantId,
      typeId: itemInTypeID,
      itemId: 0, // For non-singleton items, itemId is zero
      quantity: ITEM_IN_QUANTITY, // Non-singleton can have any quantity
      volume: 10
    });

    world.callFrom(
      player,
      ephemeralInventorySystem.toResourceId(),
      abi.encodeCall(EphemeralInventorySystem.createAndDepositEphemeral, (smartStorageUnitId, player, ephemeralItems))
    );
  }
}