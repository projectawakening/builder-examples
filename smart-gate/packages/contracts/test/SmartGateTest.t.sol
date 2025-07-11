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
import { SmartGateSystem, smartGateSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartGateSystemLib.sol";

import { SmartGateSystem as CustomSmartGateSystem } from "../src/systems/SmartGateSystem.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { GateAccess } from "../src/codegen/tables/GateAccess.sol";

contract SmartGateTest is MudTest {
  ResourceId systemId = Utils.smartGateSystemId();

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
  uint256 SMART_GATE_TYPE_ID = 84955;
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

    //Create the source gate if it doesn't exist
    if(DeployableState.getCurrentState(sourceGateId) != State.NULL){
      console.log("Source gate already exists");
    } else{
      createAnchorAndOnline(sourceGateId, SOURCE_GATE_ID, player);
    }

    //Create the destination gate if it doesn't exist
    if(DeployableState.getCurrentState(destinationGateId) != State.NULL){
      console.log("Destination gate already exists");
    } else{
      createAnchorAndOnline(destinationGateId, DESTINATION_GATE_ID, player);
    }

    vm.stopPrank();

    vm.startPrank(admin);
    // Set the allowed tribe directly
    GateAccess.set(sourceGateId, ALLOWED_TRIBE_ID);

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

  //Test setting the allowed tribe
  function testSetAllowedTribe() public {
    vm.startPrank(player, admin);

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartGateSystem.setAllowedTribe,
        (sourceGateId, 200)
      )
    );

    uint256 allowedTribe = GateAccess.get(sourceGateId);

    assertEq(allowedTribe, 200, "Allowed tribe should now be 200");

    vm.stopPrank();
  }

  //Test setting the allowed tribe to 0
  function testSetAllowedTribeIncorrectTribeID() public {
    vm.startPrank(player, admin);

    vm.expectRevert("Tribe ID cannot be 0 or negative");

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartGateSystem.setAllowedTribe,
        (sourceGateId, 0)
      )
    );

    vm.stopPrank();
  }

  //Test if the setAllowedTribe function can only be called by the admin
  function testSetAllowedTribeNotAdmin() public {
    vm.expectRevert("Access Denied. You are not the owner of this gate.");

    vm.startPrank(admin);

    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartGateSystem.setAllowedTribe,
        (sourceGateId, 200)
      )
    );

    vm.stopPrank();

    uint256 allowedTribe = GateAccess.get(sourceGateId);

    assertEq(allowedTribe, ALLOWED_TRIBE_ID, "Allowed tribe should be set to tribeID");
  }

  //Test can jump to the destination gate
  function testSourceCanJumpAllowed() public {    
    uint256 characterId = ObjectIdLib.calculateSingletonId(tenantId, PLAYER_CHARACTER_ID);

    uint256 characterTribe = Characters.getTribeId(characterId);
    assertEq(characterTribe, ALLOWED_TRIBE_ID, "Character tribe should be the same as the allowed tribe");

    //Test acccess
    bool canJumpResult = abi.decode(
      world.call(
        systemId,
        abi.encodeCall(
          CustomSmartGateSystem.canJump,
          (characterId, sourceGateId, destinationGateId)
        )
      ),
      (bool)
    );

    assertTrue(canJumpResult, "Should have access to jump to destination");
  }

  function testSourceCanJumpNotAllowed() public {
    //Test no access
    bool canJumpResult = abi.decode(
      world.call(
        systemId,
        abi.encodeCall(
          CustomSmartGateSystem.canJump,
          (ADMIN_CHARACTER_ID, sourceGateId, destinationGateId)
        )
      ),
      (bool)
    );

    assertTrue(canJumpResult == false, "Should not have access to jump to destination");
  }

  function createAnchorAndOnline(uint256 smartAssemblyId, uint256 itemId, address ownerAddress) private {
    LocationData memory locationParams = LocationData({ solarSystemId: 30000042, x: 1001, y: 1001, z: 1001 });

    EntityRecordParams memory entityRecordParams = EntityRecordParams({
      tenantId: tenantId,
      typeId: SMART_GATE_TYPE_ID,
      itemId: itemId,
      volume: 1000
    });

    CreateAndAnchorParams memory deployableParams = CreateAndAnchorParams({
      smartObjectId: smartAssemblyId,
      assemblyType: "SG",
      entityRecordParams: entityRecordParams,
      owner: ownerAddress,
      locationData: locationParams
    });

    world.callFrom(
      ownerAddress,
      smartGateSystem.toResourceId(),
      abi.encodeCall(
        SmartGateSystem.createAndAnchorGate,
        (deployableParams, 100000000, 0)
      )
    );

    entityRecordSystem.createMetadata(smartAssemblyId, EntityMetadataParams({
      name: "Name Here",
      dappURL: "",
      description: "Example SSU for the Smart Assembly Scaffold"
    }));

    vm.startPrank(admin);

    uint256 fuelSmartObjectId = ObjectIdLib.calculateNonSingletonId(tenantId, FUEL_TYPE_ID);

    fuelSystem.configureFuelParameters(smartAssemblyId, FuelParams({
      fuelMaxCapacity: 100000000,
      fuelBurnRateInSeconds: 100000000
    }));

    vm.startPrank(player, admin);

    fuelSystem.depositFuel(smartAssemblyId, fuelSmartObjectId, 1000);

    deployableSystem.bringOnline(smartAssemblyId);
  }
}