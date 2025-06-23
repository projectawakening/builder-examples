// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";

import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { UNLIMITED_DELEGATION } from "@latticexyz/world/src/constants.sol";

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

import { SmartStorageUnitSystem as CustomSmartStorageUnitSystem } from "../src/systems/SmartStorageUnitSystem.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { RatioConfig } from "../src/codegen/tables/RatioConfig.sol";

contract SmartGateTest is MudTest {
  ResourceId systemId = Utils.smartStorageUnitSystemId();

  IWorld world;

  bytes32 tenantId;

  address admin;
  address player;

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
  uint256 SSU_TYPE_ID = 84955;
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

    world = IWorld(worldAddress);
    StoreSwitch.setStoreAddress(worldAddress);

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    admin = vm.addr(deployerPrivateKey);

    player = address(this); // setting the address to the system contract as prank does not work for subsequent calls in world() calls

    tenantId = Tenant.getTenantId();

    vm.startPrank(player, admin);

    safeCreateCharacter(admin, ADMIN_CHARACTER_ID, 7777, "adminCharacter");
    safeCreateCharacter(player, PLAYER_CHARACTER_ID, ALLOWED_TRIBE_ID, "playerCharacter");

    vm.stopPrank();

    // Add delegation setup
    vm.startPrank(player);
    world.registerDelegation(admin, UNLIMITED_DELEGATION, new bytes(0));
    vm.stopPrank();

    sourceGateId = ObjectIdLib.calculateSingletonId(tenantId, SOURCE_GATE_ID);
    destinationGateId = ObjectIdLib.calculateSingletonId(tenantId, DESTINATION_GATE_ID);

    vm.startPrank(player, admin);

    if(DeployableState.getCurrentState(sourceGateId) != State.NULL){
      console.log("Source gate already exists");
    } else{
      createAnchorAndOnline(sourceGateId, SOURCE_GATE_ID, player);
    }

    if(DeployableState.getCurrentState(destinationGateId) != State.NULL){
      console.log("Destination gate already exists");
    } else{
      createAnchorAndOnline(destinationGateId, DESTINATION_GATE_ID, player);
    }

    vm.stopPrank();

    vm.startPrank(admin);

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


  function createAnchorAndOnline(uint256 smartAssemblyId, uint256 itemId, address ownerAddress) private {
    LocationData memory locationParams = LocationData({ solarSystemId: 1, x: 1001, y: 1001, z: 1001 });

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

    vm.startPrank(player, admin);

    fuelSystem.depositFuel(smartAssemblyId, fuelSmartObjectId, 1000);

    deployableSystem.bringOnline(smartAssemblyId);
  }
}