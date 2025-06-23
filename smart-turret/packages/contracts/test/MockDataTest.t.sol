// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { UNLIMITED_DELEGATION } from "@latticexyz/world/src/constants.sol";

import { console } from "forge-std/console.sol";

import { IBaseWorld } from "@eveworld/world-v2/src/codegen/world/IWorld.sol";
import { SmartCharacterSystem, smartCharacterSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartCharacterSystemLib.sol";
import { Location, LocationData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Location.sol";
import { DeployableState } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/DeployableState.sol";
import { FuelSystem, fuelSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/FuelSystemLib.sol";
import { FuelParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/fuel/types.sol";
import { SmartAssemblySystem, smartAssemblySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartAssemblySystemLib.sol";
import { EntityRecordParams, EntityMetadataParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/types.sol";
import { EntityRecordSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/EntityRecordSystem.sol";
import { entityRecordSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EntityRecordSystemLib.sol";
import { Tenant, Characters, CharactersByAccount, EntityRecord } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { CreateAndAnchorParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/deployable/types.sol";
import { DeployableSystem, deployableSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/DeployableSystemLib.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { State } from "@eveworld/world-v2/src/codegen/common.sol";
import { Turret, SmartTurretTarget } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/types.sol";
import { SmartTurretSystem, smartTurretSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/SmartTurretSystem.sol";
import { TargetPriority } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/types.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";

import { MockData } from "../script/MockData.s.sol";

contract MockDataTest is MudTest {
  ResourceId systemId = Utils.smartTurretSystemId();

  IWorld world;
  bytes32 tenantId;

  MockData mockDataScript;

  address admin;

  uint256 SMART_TURRET_ID = 12342;

  uint256 ADMIN_SMART_CHARACTER_ID = 1348;
  uint256 PLAYER_SMART_CHARACTER_ID = 1349;

  //Setup for the tests
  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    
    tenantId = Tenant.getTenantId();

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    admin = vm.addr(deployerPrivateKey);

    mockDataScript = new MockData();

    vm.setEnv("SMART_TURRET_ID", vm.toString(SMART_TURRET_ID));

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

  function test_MockData_CreateSmartAssembly() public {
    mockDataScript.run(worldAddress);

    // The MockData script creates a smart turret with ID 12341
    uint256 smartTurretSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, SMART_TURRET_ID);
    assertTrue(
      DeployableState.getCurrentState(smartTurretSmartObjectId) != State.NULL, 
      "Smart assembly should exist after deployment"
    );
  }

  function test_MockData_CreateAdminSmartCharacter() public {
    mockDataScript.run(worldAddress);

    // The MockData script creates a smart character with ID 12341
    uint256 smartCharacterSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, ADMIN_SMART_CHARACTER_ID);
    assertTrue(Characters.getTribeId(smartCharacterSmartObjectId) != 0, "Character should exist after deployment");
  }

  function test_MockData_CreatePlayerSmartCharacter() public {
    mockDataScript.run(worldAddress);

    // The MockData script creates a smart character with ID 12341
    uint256 smartCharacterSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, PLAYER_SMART_CHARACTER_ID);
    assertTrue(Characters.getTribeId(smartCharacterSmartObjectId) != 0, "Character should exist after deployment");
  }

  // Test that the script can be run twice without error
  function test_MockData_RunTwice() public {
    mockDataScript.run(worldAddress);
    mockDataScript.run(worldAddress);
  }
}