// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
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

import { SmartStorageUnitSystem as CustomSmartStorageUnitSystem } from "../src/systems/SmartStorageUnitSystem.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { RatioConfig } from "../src/codegen/tables/RatioConfig.sol";
import { EphemeralInteractSystem, ephemeralInteractSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EphemeralInteractSystemLib.sol";

contract SmartGateTest is MudTest {
  ResourceId systemId = Utils.smartStorageUnitSystemId();

  IWorldWithContext world;

  bytes32 tenantId;

  //Smart Gate Smart Object IDs (These are generated from the Smart Gate IDs)
  uint256 sourceGateId;
  uint256 destinationGateId;

  //Tribe that can use the Smart Gate
  uint256 ALLOWED_TRIBE_ID = 500;

  //Character IDs
  uint256 ADMIN_CHARACTER_ID = 35000;
  uint256 PLAYER_CHARACTER_ID = 400;

  //Smart Gate IDs
  uint256 SOURCE_GATE_ID = 9000;
  uint256 DESTINATION_GATE_ID = 9001; 

  //Type IDs
  uint256 CHARACTER_TYPE_ID = 42000000100;
  uint256 SSU_TYPE_ID = 77917;
  uint256 FUEL_TYPE_ID = 78437;

  function safeCreateCharacter(address account, uint256 characterId, uint256 tribeId, string memory name) private {
    uint256 smartObjectId = ObjectIdLib.calculateSingletonId(tenantId, characterId);

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

    world = IWorldWithContext(worldAddress);
    StoreSwitch.setStoreAddress(worldAddress);

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(deployerPrivateKey);

    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    tenantId = Tenant.getTenantId();

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

    uint256 smartStorageUnitId = ObjectIdLib.calculateSingletonId(tenantId, SOURCE_GATE_ID);
    
    vm.startPrank(admin);

    console.log("0");

    if(DeployableState.getCurrentState(smartStorageUnitId) != State.NULL){
      console.log("SSU already exists");
    } else{
      createAnchorAndOnline(smartStorageUnitId, SOURCE_GATE_ID, admin, admin);
    }

    vm.stopPrank();

    vm.startPrank(player);

    console.log("1");

    ephemeralInteractSystem.setTransferFromEphemeralAccess(smartStorageUnitId, address(this), true);
    ephemeralInteractSystem.setTransferToEphemeralAccess(smartStorageUnitId, address(this), true);

    vm.stopPrank();

    vm.startPrank(player, admin);

    console.log("2");



    console.log("Depositing to inventory");
    // Create and deposit inventory items
    _depositToInventory(smartStorageUnitId, tenantId, admin);
    console.log("Depositing to ephemeral inventory");
    _depositToEphemeralInventory(smartStorageUnitId, tenantId, player);
    console.log("Depositing to inventory and ephemeral inventory complete");

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

    uint256 fuelSmartObjectId = ObjectIdLib.calculateNonSingletonId(tenantId, FUEL_TYPE_ID);

    fuelSystem.configureFuelParameters(smartAssemblyId, FuelParams({
      fuelMaxCapacity: 100000000,
      fuelBurnRateInSeconds: 100000000
    }));

    vm.stopPrank();

    vm.startPrank(ownerAddress, admin);

    fuelSystem.depositFuel(smartAssemblyId, fuelSmartObjectId, 1000);

    deployableSystem.bringOnline(smartAssemblyId);
  }


  function _depositToInventory(uint256 smartStorageUnitId, bytes32 tenantId, address player) private {
    uint256 itemOutTypeID = vm.envUint("ITEM_OUT_TYPE_ID");

    uint256 itemOutSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, itemOutTypeID);

    CreateInventoryItemParams[] memory items = new CreateInventoryItemParams[](1);

    items[0] = CreateInventoryItemParams({
      smartObjectId: itemOutSmartObjectId,
      tenantId: tenantId,
      typeId: itemOutTypeID,
      itemId: 0, // For non-singleton items, itemId is zero
      quantity: 10, // Non-singleton can have any quantity
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
    uint256 itemInSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, itemInTypeID);
    CreateInventoryItemParams[] memory ephemeralItems = new CreateInventoryItemParams[](1);

    ephemeralItems[0] = CreateInventoryItemParams({
      smartObjectId: itemInSmartObjectId,
      tenantId: tenantId,
      typeId: itemInTypeID,
      itemId: 0, // For non-singleton items, itemId is zero
      quantity: 15, // Non-singleton can have any quantity
      volume: 10
    });

    world.callFrom(
      player,
      ephemeralInventorySystem.toResourceId(),
      abi.encodeCall(EphemeralInventorySystem.createAndDepositEphemeral, (smartStorageUnitId, player, ephemeralItems))
    );
  }
}