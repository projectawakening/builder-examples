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
import { SmartGateLib } from "@eveworld/world/src/modules/smart-gate/SmartGateLib.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";
import { Coord, WorldPosition, EntityRecordData } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { SmartObjectData } from "@eveworld/world/src/modules/smart-deployable/types.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { GlobalDeployableState } from "@eveworld/world/src/codegen/tables/GlobalDeployableState.sol";
import { SmartGateLib } from "@eveworld/world/src/modules/smart-gate/SmartGateLib.sol";
import { EntityRecordLib } from "@eveworld/world/src/modules/entity-record/EntityRecordLib.sol";
import { SmartCharacterLib } from "@eveworld/world/src/modules/smart-character/SmartCharacterLib.sol";
import { EntityRecordData as CharacterEntityRecord } from "@eveworld/world/src/modules/smart-character/types.sol";
import { EntityRecordOffchainTableData } from "@eveworld/world/src/codegen/tables/EntityRecordOffchainTable.sol";
import { CharactersByAddressTable } from "@eveworld/world/src/codegen/tables/CharactersByAddressTable.sol";
import { DeployableState, DeployableStateData } from "@eveworld/world/src/codegen/tables/DeployableState.sol";
import { State } from "@eveworld/world/src/modules/smart-deployable/types.sol";
import { EphemeralInvItemTableData, EphemeralInvItemTable } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";
import { GlobalDeployableState } from "@eveworld/world/src/codegen/tables/GlobalDeployableState.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { SmartGateSystem } from "../src/systems/SmartGateSystem.sol";
import { GateAccess } from "../src/codegen/tables/GateAccess.sol";


contract SmartGateTest is MudTest {
  using SmartDeployableLib for SmartDeployableLib.World;
  using SmartGateLib for SmartGateLib.World;
  using EntityRecordLib for EntityRecordLib.World;
  using SmartCharacterLib for SmartCharacterLib.World;
  using SmartDeployableUtils for bytes14;

  SmartDeployableLib.World smartDeployable;
  SmartGateLib.World smartGate;
  EntityRecordLib.World entityRecord;
  SmartCharacterLib.World smartCharacter;
  ResourceId systemId = Utils.smartGateSystemId();

  IWorld world;

  uint256 sourceGateId;
  uint256 destinationGateId;

  //Setup for the tests
  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(deployerPrivateKey);

    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    smartDeployable = SmartDeployableLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    smartGate = SmartGateLib.World({
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

    //Get the allowed corp
    uint256 corpID = vm.envUint("ALLOWED_CORP_ID");
    sourceGateId = vm.envUint("SOURCE_GATE_ID");
    sourceGateId = vm.envUint("DESTINATION_GATE_ID");

    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.setAllowedCorp,
        (sourceGateId, corpID)
      )
    );

    if (CharactersByAddressTable.get(admin) == 0) {
      smartCharacter.createCharacter(
        400,
        admin,
        corpID,
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "ron", dappURL: "noURL", description: "." }),
        ""
      );
    }
    if (CharactersByAddressTable.get(player) == 0) {
      smartCharacter.createCharacter(
        456,
        player,
        4041,
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "harryporter", dappURL: "noURL", description: "." }),
        ""
      );
    }

    createAnchorAndOnline(sourceGateId, admin);
    createAnchorAndOnline(destinationGateId, admin);    
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
    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.setAllowedCorp,
        (sourceGateId, 200)
      )
    );

    uint256 allowedCorp = GateAccess.get(sourceGateId);

    assertEq(allowedCorp, 200, "Allowed corp should now be 200");
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