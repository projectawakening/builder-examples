pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";

import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { GlobalDeployableState } from "@eveworld/world/src/codegen/tables/GlobalDeployableState.sol";
import { Utils as SmartCharacterUtils } from "@eveworld/world/src/modules/smart-character/Utils.sol";
import { SmartCharacterLib } from "@eveworld/world/src/modules/smart-character/SmartCharacterLib.sol";
import { EntityRecordData as EntityRecordCharacter } from "@eveworld/world/src/modules/smart-character/types.sol";
import { EntityRecordOffchainTableData } from "@eveworld/world/src/codegen/tables/EntityRecordOffchainTable.sol";
import { EntityRecordData, WorldPosition, Coord } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { SmartObjectData } from "@eveworld/world/src/modules/smart-deployable/types.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { SmartGateLib } from "@eveworld/world/src/modules/smart-gate/SmartGateLib.sol";
import { Utils as SmartGateUtils } from "@eveworld/world/src/modules/smart-gate/Utils.sol";
import { EntityRecordData as CharacterEntityRecord } from "@eveworld/world/src/modules/smart-character/types.sol";
import { EntityRecordOffchainTableData } from "@eveworld/world/src/codegen/tables/EntityRecordOffchainTable.sol";
import { CharactersByAddressTable } from "@eveworld/world/src/codegen/tables/CharactersByAddressTable.sol";

contract MockData is Script {
  using SmartCharacterUtils for bytes14;
  using SmartDeployableUtils for bytes14;
  using SmartGateUtils for bytes14;
  using SmartCharacterLib for SmartCharacterLib.World;
  using SmartDeployableLib for SmartDeployableLib.World;
  using SmartGateLib for SmartGateLib.World;

  SmartCharacterLib.World smartCharacter;
  SmartDeployableLib.World smartDeployable;
  SmartGateLib.World smartGate;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(deployerPrivateKey);

    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);
    uint256 sourceGateId = vm.envUint("SOURCE_GATE_ID");
    uint256 destinationGateId = vm.envUint("DESTINATION_GATE_ID");

    smartCharacter = SmartCharacterLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    smartDeployable = SmartDeployableLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    smartGate = SmartGateLib.World({ iface: IBaseWorld(worldAddress), namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE });

    //Get the allowed corp
    uint256 corpID = vm.envUint("ALLOWED_CORP_ID");

    //Create a smart character
    if (CharactersByAddressTable.get(admin) == 0) {
      smartCharacter.createCharacter(
        100,     //Character ID
        admin,  // Character Address
        corpID,  // Corp ID
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "characterName", dappURL: "noURL", description: "." }),
        ""
      );
    }
    
    //Create a smart character
    if (CharactersByAddressTable.get(player) == 0) {
      smartCharacter.createCharacter(
        200,     //Character ID
        player,  // Character Address
        200,     // Corp ID
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "characterName", dappURL: "noURL", description: "." }),
        ""
      );
    }

    anchorFuelAndOnline(sourceGateId, player);
    anchorFuelAndOnline(destinationGateId, player);

    vm.stopBroadcast();
  }

  function anchorFuelAndOnline(uint256 smartObjectId, address player) public {
    smartGate.createAndAnchorSmartGate(
      smartObjectId,
      EntityRecordData({ typeId: 12345, itemId: 45, volume: 10 }),
      SmartObjectData({ owner: player, tokenURI: "test" }),
      WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) }),
      1e18, // fuelUnitVolume,
      1, // fuelConsumptionIntervalInSeconds,
      1000100 * 1e18, // fuelMaxCapacity,
      100010000 * 1e18 // max Distance
    );

    // check global state and resume if needed
    if (GlobalDeployableState.getIsPaused() == false) {
      smartDeployable.globalResume();
    }

    smartDeployable.depositFuel(smartObjectId, 200010);
    smartDeployable.bringOnline(smartObjectId);
  }
}