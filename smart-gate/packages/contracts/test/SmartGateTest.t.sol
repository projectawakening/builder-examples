// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { SmartCharacterSystem, smartCharacterSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartCharacterSystemLib.sol";
import { EntityRecordData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/EntityRecord.sol";
import { Location, LocationData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Location.sol";
import { DeployableState } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/DeployableState.sol";
import { FuelSystem, fuelSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/FuelSystemLib.sol";
import { SmartAssemblySystem, smartAssemblySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartAssemblySystemLib.sol";
import { EntityRecordParams, EntityMetadataParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/entity-record/types.sol";
import { Tenant, EntityRecordMetadata, EntityRecordMetadataData, Characters, CharactersData, CharactersByAccount } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { SmartGateSystem, smartGateSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartGateSystemLib.sol";
import { CreateAndAnchorParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/deployable/types.sol";
import { DeployableSystem, deployableSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/DeployableSystemLib.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { State } from "@eveworld/world-v2/src/codegen/common.sol";
import { IBaseWorld } from "@eveworld/world-v2/src/codegen/world/IWorld.sol";

import { Utils } from "../src/systems/Utils.sol";

contract SmartGateTest is MudTest {
  ResourceId systemId = Utils.smartGateSystemId();

  IWorld world;

  address admin;

  uint256 sourceGateId;
  uint256 destinationGateId;
  uint256 corpID;

  //Setup for the tests
  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    admin = vm.addr(deployerPrivateKey);

    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    //Get the allowed corp
    corpID = vm.envUint("ALLOWED_CORP_ID");
    sourceGateId = vm.envUint("SOURCE_GATE_ID");
    sourceGateId = vm.envUint("DESTINATION_GATE_ID");

    if (CharactersByAccount.get(owner) == 0) {
      console.log("Creating admin character");

      smartCharacterSystem.createCharacter(
        ownerCharacterSmartObjectId,
        owner,
        7777,
        EntityRecordParams({ tenantId: tenantId, typeId: 1, itemId: 235, volume: 100 }),
        EntityMetadataParams({ name: "adminCharacter", dappURL: "noURL", description: "." })
      );
    }

    if (CharactersByAccount.get(player) == 0) {
      console.log("Creating player character");
      smartCharacterSystem.createCharacter(
        playerCharacterSmartObjectId,
        player,
        7777,
        EntityRecordParams({ tenantId: tenantId, typeId: 1, itemId: 234, volume: 100 }),
        EntityMetadataParams({ name: "playerCharacter", dappURL: "noURL", description: "." })
      );
    }

    createAnchorAndOnline(sourceGateId, admin);
    createAnchorAndOnline(destinationGateId, admin);     

    vm.startPrank(admin);
    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.setAllowedCorp,
        (sourceGateId, corpID)
      )
    );
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

  function testSetAllowedCorp() public {
    vm.startPrank(admin);

    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.setAllowedCorp,
        (sourceGateId, 200)
      )
    );

    uint256 allowedCorp = GateAccess.get(sourceGateId);

    assertEq(allowedCorp, 200, "Allowed corp should now be 200");

    vm.stopPrank();
  }

  function testSetAllowedCorpNotAdmin() public {
    vm.expectRevert();

    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.setAllowedCorp,
        (sourceGateId, 200)
      )
    );

    uint256 allowedCorp = GateAccess.get(sourceGateId);

    assertEq(allowedCorp, corpID, "Allowed corp should be set to ALLOWED_CORP_ID");
  }

  //Test can jump to the destination gate
  function testSourceCanJumpAllowed() public {    
    //Test acccess
    bool canJumpResult = abi.decode(
      world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.canJump,
          (400, sourceGateId, destinationGateId)
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
          SmartGateSystem.canJump,
          (456, sourceGateId, destinationGateId)
        )
      ),
      (bool)
    );

    assertTrue(canJumpResult == false, "Should not have access to jump to destination");
  }

  function createAnchorAndOnline(uint256 anchoredSmartGateId, address admin) private {
    //Create and anchor the smart gate and bring online
    smartGate.createAndAnchorSmartGate(
      anchoredSmartGateId,
      EntityRecordData({ typeId: 7888, itemId: 111, volume: 10 }),
      SmartObjectData({ owner: admin, tokenURI: "test" }),
      WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) }),
      1e18,             // fuelUnitVolume,
      1,                // fuelConsumptionPerMinute,
      1000000 * 1e18,   // fuelMaxCapacity,
      100010000 * 1e18  // maxDistance
    );

    // check global state and resume if needed
    if (GlobalDeployableState.getIsPaused() == false) {
      smartDeployable.globalResume();
    }

    smartDeployable.depositFuel(anchoredSmartGateId, 200010);
    smartDeployable.bringOnline(anchoredSmartGateId);
  }
}