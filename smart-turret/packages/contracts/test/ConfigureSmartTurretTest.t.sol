// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { console } from "forge-std/console.sol";

import { DeployableState } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/DeployableState.sol";
import { Tenant } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { State } from "@eveworld/world-v2/src/codegen/common.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { TurretAllowlist } from "../src/codegen/tables/TurretAllowlist.sol";

import { ConfigureSmartTurret } from "../script/ConfigureSmartTurret.s.sol";
import { MockData } from "../script/MockData.s.sol";

contract ConfigureSmartTurretTest is MudTest {
  IWorld world;
  bytes32 tenantId;

  address admin;

  ConfigureSmartTurret configureSmartTurretScript;
  MockData mockDataScript;

  uint256 SMART_TURRET_ID = 12342;
  uint256 ALLOWED_TRIBE_ID = 2000;

  //Setup for the tests
  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    
    tenantId = Tenant.getTenantId();

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    admin = vm.addr(deployerPrivateKey);

    configureSmartTurretScript = new ConfigureSmartTurret();
    mockDataScript = new MockData();

    uint256 smartTurretId = ObjectIdLib.calculateSingletonId(tenantId, SMART_TURRET_ID);
    vm.setEnv("SMART_TURRET_ID", vm.toString(smartTurretId));
    vm.setEnv("ALLOWED_TRIBE_ID", vm.toString(ALLOWED_TRIBE_ID));

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

  function test_ConfigureSmartTurret_ConfigureSmartTurretRevertIfSmartTurretDoesNotExist() public {
    vm.expectRevert("No Smart Assembly found. Please run 'pnpm mock-data' to generate one.");
    configureSmartTurretScript.run(worldAddress);
  }

  function test_ConfigureSmartTurret_Configure() public {
    uint256 allowedTribeIdBefore = TurretAllowlist.get();
    require(allowedTribeIdBefore == 0, "Allowed tribe should be 0 before deployment");
    
    mockDataScript.run(worldAddress);

    configureSmartTurretScript.run(worldAddress);

    uint256 smartTurretId = ObjectIdLib.calculateSingletonId(tenantId, SMART_TURRET_ID);
    console.log("SMART TURRET ID AFTER DEPLOYMENT:", vm.toString(smartTurretId));
    assertTrue(
      DeployableState.getCurrentState(smartTurretId) != State.NULL, 
      "Smart assembly should exist after deployment"
    );

    uint256 allowedTribeId = TurretAllowlist.get();
    assertTrue(allowedTribeId == ALLOWED_TRIBE_ID, "Allowed tribe should be set to the allowed tribe ID");
  }
}
