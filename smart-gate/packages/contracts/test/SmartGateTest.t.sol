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
import { AccessListDefinitions, AccessListDefinitionsData } from "../src/codegen/tables/AccessListDefinitions.sol";
import { AccessListEntries, AccessListEntriesData } from "../src/codegen/tables/AccessListEntries.sol";

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

  address gateOwner;

  //Setup for the tests
  function setUp() public override {
    super.setUp();
    
    world = IWorld(worldAddress);

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    gateOwner = vm.addr(deployerPrivateKey);

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
    destinationGateId = vm.envUint("DESTINATION_GATE_ID");

    if (CharactersByAddressTable.get(gateOwner) == 0) {
      smartCharacter.createCharacter(
        55555,
        gateOwner,
        44444,
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "gateowner", dappURL: "noURL", description: "." }),
        ""
      );
    }

    createAnchorAndOnline(sourceGateId);
    createAnchorAndOnline(destinationGateId);    

    initializeTestPlayers();
    vm.startPrank(gateOwner);
    initializeTestAccessLists(sourceGateId);
    vm.stopPrank();
  }

  function createAnchorAndOnline(uint256 anchoredSmartGateId) private {
    //Create and anchor the smart gate and bring online
    smartGate.createAndAnchorSmartGate(
      anchoredSmartGateId,
      EntityRecordData({ typeId: 7888, itemId: 111, volume: 10 }),
      SmartObjectData({ owner: gateOwner, tokenURI: "test" }),
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

  function initializeTestAccessLists(uint256 smartObjectId) internal {
    bytes32 testBlacklistId = createAccessList(vm.envString("TEST_BLACKLIST_NAME"), false);
    addCharIdToAccessList(vm.envUint("TEST_PLAYER_CHAR_ID_BLACKLIST_ONLY"), testBlacklistId);
    addCharIdToAccessList(vm.envUint("TEST_PLAYER_CHAR_ID_BLACKLIST_AND_WHITELIST"), testBlacklistId);
   
    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.addAccessListToGate,
        (smartObjectId, testBlacklistId)
      )
    );
        
    bytes32 testWhitelistId = createAccessList(vm.envString("TEST_WHITELIST_NAME"), true);
    addCharIdToAccessList(vm.envUint("TEST_PLAYER_CHAR_ID_WHITELIST_ONLY"), testWhitelistId);
    addCharIdToAccessList(vm.envUint("TEST_PLAYER_CHAR_ID_BLACKLIST_AND_WHITELIST"), testWhitelistId);
    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.addAccessListToGate,
        (smartObjectId, testWhitelistId)
      )
    );
  }
 
  /**
   * @notice Creates a new AccessList entry in the MUD AccessListDefinitions table.
   * @param accessListName A descriptive name (e.g., "MainWhitelist").
   * @param isWhitelist    true for Whitelist, false for Blacklist.
   * @return listId        The generated accessListId (bytes32).
   *
   * Example:
   *   bytes32 newAccessListId = createAccessList("NewWhitelist", true);
   */
  function createAccessList(string memory accessListName, bool isWhitelist) public returns (bytes32 listId) {
    // 1) Generate a hash ID from the name
    listId = keccak256(bytes(accessListName));

    // 2) Check if this name already exists (id is always hashed name)
    AccessListDefinitionsData memory existing = AccessListDefinitions.get(listId);
    if (keccak256(bytes(existing.accessListName)) == listId) {
        revert("AccessList with this name already exists");
    }

    // 3) Create the data structure
    AccessListDefinitionsData memory newList = AccessListDefinitionsData({
      isWhitelist: isWhitelist,
      createdBy: msg.sender,
      accessListName: accessListName
    });

    // 4) Store the data structure in the MUD table
    AccessListDefinitions.set(listId, newList);

    return listId;
  }

  /**
   * @notice Adds a char (charId) to a specific access list (accessListId).
   * Reverts if the list does not exist or if the char is already on the list.
   *
   * @param charId        The unique ID of the char to add
   * @param accessListId  The bytes32 ID of the access list
   */
  function addCharIdToAccessList(uint256 charId, bytes32 accessListId) public {
    // 1) Check if the specified access list exists
    AccessListDefinitionsData memory listDef = AccessListDefinitions.get(accessListId);
    if (listDef.createdBy == address(0)) {
      revert("Access List not found");
    }

    // 2) Verify that this char is not already on the list
    AccessListEntriesData memory existing = AccessListEntries.get(accessListId, charId, 0);
    if (existing.addedBy != address(0)) {
      revert("Char already in list");
    }

    // 3) Create a new entry for the char, including the address of the user who added it
    AccessListEntriesData memory newEntry = AccessListEntriesData({
      addedBy:      msg.sender, // wallet address of the entry creator
      timestamp:    0 // not used yet
    });

    // 4) Store the new entry in the MUD table
    AccessListEntries.set(accessListId, charId, 0, newEntry);
  }

  /////////////////////////////////////////////////////
  //////////////////// TESTS BEGIN ////////////////////
  /////////////////////////////////////////////////////

  function testWorldExists() public {
    uint256 codeSize;
    address addr = worldAddress;
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function testAddAccessListToGate() public {
    bytes32 accessListId = keccak256(bytes("Test_Access_List"));
    vm.startPrank(gateOwner);
    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.addAccessListToGate,
        (sourceGateId, accessListId)
      )
    );
    vm.stopPrank();

    bytes32[] memory accessListIdsInGateAccess = GateAccess.get(sourceGateId);

    bool isSetIdFoundNow = false;

    for(uint256 i = 0; i < accessListIdsInGateAccess.length; i++)
    {
      if(accessListIdsInGateAccess[i] == accessListId) {
        isSetIdFoundNow = true;
        break;
      }
    }

    assertTrue(isSetIdFoundNow, "Add List to gate went wrong");
  }

  function testRemoveAccessListFromGate() public {
    bytes32 accessListId = keccak256(bytes("Test_Access_List"));

    vm.startPrank(gateOwner);
    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.addAccessListToGate,
        (sourceGateId, accessListId)
      )
    );
    vm.stopPrank();

    bytes32[] memory accessListIdsInGateAccess = GateAccess.get(sourceGateId);

    bool isIdFoundPostAdd = false;

    for(uint256 i = 0; i < accessListIdsInGateAccess.length; i++)
    {
      if(accessListIdsInGateAccess[i] == accessListId) {
        isIdFoundPostAdd = true;
        break;
      }
    }

    assertTrue(isIdFoundPostAdd, "Add Access List to gate went wrong before remove could be tested");

    vm.startPrank(gateOwner);
    world.call(
      systemId,
      abi.encodeCall(
        SmartGateSystem.removeAccessListFromGate,
        (sourceGateId, accessListId)
      )
    );
    vm.stopPrank();

    bytes32[] memory accessListIdsInGateAccessAfterRemoval = GateAccess.get(sourceGateId);

    bool isRemovedIdStillThere = false;

    for(uint256 i = 0; i < accessListIdsInGateAccessAfterRemoval.length; i++)
    {
      if(accessListIdsInGateAccessAfterRemoval[i] == accessListId) {
        isRemovedIdStillThere = true;
        break;
      }
    }

    assertFalse(isRemovedIdStillThere, "Access List has not been removed from gate");
  }

  function testPlayerOnCharWhitelistCanJump() public {    
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

  ////////////////////////////////////////////////////
  /////////////////// TESTS END //////////////////////
  ////////////////////////////////////////////////////

  function generateRandomAddressForTest(uint256 seed) private pure returns (address) {
    return address(uint160(uint256(keccak256(abi.encodePacked(seed)))));
  } 
}
