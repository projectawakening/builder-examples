// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { UNLIMITED_DELEGATION } from "@latticexyz/world/src/constants.sol";

import { IBaseWorld } from "@eveworld/world-v2/src/codegen/world/IWorld.sol";
import { SmartCharacterSystem, smartCharacterSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartCharacterSystemLib.sol";
import { Location, LocationData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Location.sol";
import { DeployableState } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/DeployableState.sol";
import { FuelSystem, fuelSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/FuelSystemLib.sol";
import { FuelParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/fuel/types.sol";
import { SmartAssemblySystem, smartAssemblySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartAssemblySystemLib.sol";
import { EntityRecordParams, EntityMetadataParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/types.sol";
import { Tenant, Characters, CharactersByAccount, EntityRecord } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { SmartStorageUnitSystem, smartStorageUnitSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartStorageUnitSystemLib.sol";
import { CreateAndAnchorParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/deployable/types.sol";
import { DeployableSystem, deployableSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/DeployableSystemLib.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { State } from "@eveworld/world-v2/src/codegen/common.sol";

import { InventorySystem, inventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/InventorySystemLib.sol";
import { EphemeralInventorySystem, ephemeralInventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EphemeralInventorySystemLib.sol";

import { CreateInventoryItemParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/inventory/types.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { ToggleSystem } from "../src/systems/ToggleSystem.sol";
import { ToggleTable } from "../src/codegen/tables/ToggleTable.sol";

import { ConfigureToggle } from "../script/ConfigureToggle.s.sol";

contract ConfigureToggleTest is MudTest {
  ResourceId systemId = Utils.toggleSystemId();

  IWorld world;

  bytes32 tenantId;

  address admin;
  address player;

  uint256 inventoryItemIn;
  uint256 inventoryItemOut;

  uint256 smartStorageUnitId = 1246;
  uint256 smartStorageUnitSmartId;

  ConfigureToggle configureToggleScript;

  uint64 INV_ITEM_QUANTITY = 100;
  uint64 EPH_ITEM_QUANTITY = 100;

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
    }
  }

  function setUp() public override {
    super.setUp();

    world = IWorld(worldAddress);
    StoreSwitch.setStoreAddress(worldAddress);

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    admin = vm.addr(deployerPrivateKey);

    player = address(this); // setting the address to the system contract as prank does not work for subsequent calls in world() calls

    inventoryItemIn = vm.envUint("ITEM_IN_TYPE_ID");
    inventoryItemOut = vm.envUint("ITEM_OUT_TYPE_ID");

    tenantId = Tenant.getTenantId();

    vm.startPrank(player, admin);
    safeCreateCharacter(admin, 1, 7777, "adminCharacter");
    safeCreateCharacter(player, 2, 7777, "playerCharacter");
    vm.stopPrank();

    // Add delegation setup
    vm.startPrank(player);
    world.registerDelegation(admin, UNLIMITED_DELEGATION, new bytes(0));
    vm.stopPrank();

    vm.startPrank(admin);
    smartStorageUnitSmartId = ObjectIdLib.calculateObjectId(tenantId, smartStorageUnitId);

    console.log("Creating and anchoring smart storage unit");
    
    if(DeployableState.getCurrentState(smartStorageUnitSmartId) == State.NULL){
      createAnchorAndOnline(smartStorageUnitSmartId, admin);
    }
    console.log("Smart storage unit created and anchored");

    //Create and deposit inventory items
    uint256 itemOutTypeID = vm.envUint("ITEM_OUT_TYPE_ID");
    uint256 itemOutSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, itemOutTypeID);

    CreateInventoryItemParams[] memory items = new CreateInventoryItemParams[](1);
    
    items[0] = CreateInventoryItemParams({
      smartObjectId: itemOutSmartObjectId,
      tenantId: tenantId,
      typeId: itemOutTypeID,
      itemId: 0,
      quantity: INV_ITEM_QUANTITY,
      volume: 10
    });

    vm.startPrank(admin, admin);

    console.log("Creating and depositing inventory items");
    inventorySystem.createAndDepositInventory(smartStorageUnitSmartId, items);
    
    uint256 itemInTypeID = vm.envUint("ITEM_IN_TYPE_ID");
    uint256 itemInSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, itemInTypeID);

    items[0] = CreateInventoryItemParams({
      smartObjectId: itemInSmartObjectId,
      tenantId: tenantId,
      typeId: itemInTypeID,
      itemId: 0,
      quantity: EPH_ITEM_QUANTITY,
      volume: 10
    });

    vm.stopPrank();

    vm.startPrank(player, admin);
    ephemeralInventorySystem.createAndDepositEphemeral(smartStorageUnitSmartId, player, items);
    vm.stopPrank();

    configureToggleScript = new ConfigureToggle();
  }  

  function testWorldExists() public {
    uint256 codeSize;
    address addr = worldAddress;
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function testConfigureToggle() public {
    bool isSet = ToggleTable.getIsSet(smartStorageUnitSmartId);
    assertFalse(isSet, "Toggle should be false");

    vm.setEnv("SSU_ID", vm.toString(smartStorageUnitSmartId));

    configureToggleScript.run(worldAddress);

    isSet = ToggleTable.getIsSet(smartStorageUnitSmartId);
    assertTrue(isSet, "Toggle should be true");
  }

  function createAnchorAndOnline(uint256 ssuId, address ownerAddress) private {
    LocationData memory locationParams = LocationData({ solarSystemId: 30000042, x: 1001, y: 1001, z: 1001 });

    EntityRecordParams memory entityRecordParams = EntityRecordParams({
      tenantId: tenantId,
      typeId: SSU_TYPE_ID,
      itemId: 1246,
      volume: 1000
    });

    CreateAndAnchorParams memory deployableParams = CreateAndAnchorParams({
      smartObjectId: ssuId,
      assemblyType: "SSU",
      entityRecordParams: entityRecordParams,
      owner: ownerAddress,
      locationData: locationParams
    });

    vm.startPrank(admin, admin);

    world.callFrom(
      ownerAddress,
      smartStorageUnitSystem.toResourceId(),
      abi.encodeCall(
        SmartStorageUnitSystem.createAndAnchorStorageUnit,
        (deployableParams, 100000000, 100000000, 100000000)
      )
    );

    uint256 fuelSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, FUEL_TYPE_ID);

    vm.stopPrank();

    vm.startPrank(admin);

    console.log("Configuring fuel parameters");

    fuelSystem.configureFuelParameters(ssuId, FuelParams({
      fuelMaxCapacity: 100000000,
      fuelBurnRateInSeconds: 100000000
    }));

    console.log("Depositing fuel");

    fuelSystem.depositFuel(ssuId, fuelSmartObjectId, 1000);

    console.log("Fuel deposited");

    deployableSystem.bringOnline(ssuId);
  }
}
