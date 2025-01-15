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
import { AccessLists, AccessListsData } from "../src/codegen/tables/AccessLists.sol";


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

    bytes32 tableId = keccak256("tb:test:AccessLists");

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(deployerPrivateKey);

    //uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    //address player = vm.addr(playerPrivateKey);

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

    sourceGateId = vm.envUint("SOURCE_GATE_ID");
    sourceGateId = vm.envUint("DESTINATION_GATE_ID");

    if (CharactersByAddressTable.get(admin) == 0) {
      smartCharacter.createCharacter(
        55555,
        admin,
        44444,
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "gateowner", dappURL: "noURL", description: "." }),
        ""
      );
    }

    createAnchorAndOnline(sourceGateId, admin);
    createAnchorAndOnline(destinationGateId, admin);    

    initializeTestPlayers();
    vm.startPrank(admin);
    initializeTestAccessLists();
    vm.stopPrank();
  }

  function initializeTestAccessLists() internal {
    // TestWhitelist
    // Zuerst die Arrays im Speicher definieren und initialisieren
    uint256[] memory corpIds = new uint256[](2);
    corpIds[0] = 1;
    corpIds[1] = 2;

    uint256[] memory charIds = new uint256[](2);
    charIds[0] = vm.envUint("TEST_PLAYER_CHAR_ID_WHITELIST_ONLY");
    charIds[1] = vm.envUint("TEST_PLAYER_CHAR_ID_BLACKLIST_AND_WHITELIST");

    // AccessListsData manuell initialisieren
    AccessListsData memory whiteListData = AccessListsData({
        isWhiteList: true,
        accessListName: vm.envString("TEST_WHITELIST_NAME"),
        CorpIds: corpIds,
        CharIds: charIds
    });

    AccessLists.set(keccak256(abi.encodePacked(vm.envString("TEST_WHITELIST_NAME"))), whiteListData);
    AccessListsData memory dataToCheck = AccessLists.get(keccak256(abi.encodePacked(vm.envString("TEST_WHITELIST_NAME"))));

    uint256[] memory charIdsToCheck = dataToCheck.CharIds;
    console.log("HIER MUSS WAS PASSIEREN------------------------");
    console.log("initializeTestAccessLists: CharId[0] ", charIdsToCheck[0]);
    console.log("initializeTestAccessLists: CharId[0] ", charIdsToCheck[1]);
    // Test Blacklist
    // Zuerst die Arrays im Speicher definieren und initialisieren
    uint256[] memory corpIds2 = new uint256[](2);
    corpIds2[0] = 3;
    corpIds2[1] = 4;

    uint256[] memory charIds2 = new uint256[](2);
    charIds2[0] = vm.envUint("TEST_PLAYER_CHAR_ID_BLACKLIST_ONLY");
    charIds2[1] = vm.envUint("TEST_PLAYER_CHAR_ID_BLACKLIST_AND_WHITELIST");

    // AccessListsData manuell initialisieren
    AccessListsData memory blackListData = AccessListsData({
        isWhiteList: false,
        accessListName: vm.envString("TEST_BLACKLIST_NAME"),
        CorpIds: corpIds2,
        CharIds: charIds2
    });

    
    AccessLists.set(keccak256(abi.encodePacked(vm.envString("TEST_BLACKLIST_NAME"))), blackListData);
  }

  function initializeTestPlayers() internal {
    address testPlayerCharWhitelistOnly = generateRandomAddressForTest(vm.envUint("TEST_SEED"));
    address testPlayerCharBlacklistOnly = generateRandomAddressForTest(vm.envUint("TEST_SEED")+51345);
    address testPlayerCharNoList = generateRandomAddressForTest(vm.envUint("TEST_SEED")+198745524);
    address testPlayerBlacklistAndWhitelist = generateRandomAddressForTest(vm.envUint("TEST_SEED")+134355555);

    if (CharactersByAddressTable.get(testPlayerCharWhitelistOnly) == 0) {
      smartCharacter.createCharacter(
        vm.envUint("TEST_PLAYER_CHAR_ID_WHITELIST_ONLY"),
        testPlayerCharWhitelistOnly,
        4041,
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "testPlayerCharWhitelistOnly", dappURL: "noURL", description: "." }),
        ""
      );
    }
    if (CharactersByAddressTable.get(testPlayerCharBlacklistOnly) == 0) {
      smartCharacter.createCharacter(
        vm.envUint("TEST_PLAYER_CHAR_ID_BLACKLIST_ONLY"),
        testPlayerCharBlacklistOnly,
        4041,
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "testPlayerCharBlacklistOnly", dappURL: "noURL", description: "." }),
        ""
      );
    }
    if (CharactersByAddressTable.get(testPlayerCharNoList) == 0) {
      smartCharacter.createCharacter(
        vm.envUint("TEST_PLAYER_CHAR_ID_NO_LIST"),
        testPlayerCharNoList,
        4041,
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "testPlayerNoList", dappURL: "noURL", description: "." }),
        ""
      );
    }
    if (CharactersByAddressTable.get(testPlayerBlacklistAndWhitelist) == 0) {
      smartCharacter.createCharacter(
        vm.envUint("TEST_PLAYER_CHAR_ID_BLACKLIST_AND_WHITELIST"),
        testPlayerBlacklistAndWhitelist,
        4041,
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "testPlayerBlacklistAndWhitelist", dappURL: "noURL", description: "." }),
        ""
      );
    }
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

  function testPlayerOnCharWhitelistCanJump() public {    
    //Test acccess
    bool canJumpResult = abi.decode(
      world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.canJump,
          (vm.envUint("TEST_PLAYER_CHAR_ID_WHITELIST_ONLY"), sourceGateId, destinationGateId)
        )
      ),
      (bool)
    );

    assertTrue(canJumpResult, "Player should have access");
  }

  function testPlayerOnCharBlacklistCanNotJump() public {    
    //Test acccess
    bool canJumpResult = abi.decode(
      world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.canJump,
          (vm.envUint("TEST_PLAYER_CHAR_ID_BLACKLIST_ONLY"), sourceGateId, destinationGateId)
        )
      ),
      (bool)
    );

    assertFalse(canJumpResult, "Player should not have access");
  }

  function testPlayerOnNoListCanNotJump() public {    
    //Test acccess
    bool canJumpResult = abi.decode(
      world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.canJump,
          (vm.envUint("TEST_PLAYER_CHAR_ID_NO_LIST"), sourceGateId, destinationGateId)
        )
      ),
      (bool)
    );

    assertFalse(canJumpResult, "Player should not have access");
  }

  function testPlayerOnWhitelsitAndBlacklistCanNotJump() public {    
    //Test acccess
    bool canJumpResult = abi.decode(
      world.call(
        systemId,
        abi.encodeCall(
          SmartGateSystem.canJump,
          (vm.envUint("TEST_PLAYER_CHAR_ID_BLACKLIST_AND_WHITELIST"), sourceGateId, destinationGateId)
        )
      ),
      (bool)
    );

    assertFalse(canJumpResult, "Player should not have access");
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

  function generateRandomAddressForTest(uint256 seed) private pure returns (address) {
    return address(uint160(uint256(keccak256(abi.encodePacked(seed)))));
  }
  
}