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
import { Utils as SmartCharacterUtils } from "@eveworld/world/src/modules/smart-character/Utils.sol";
import { SmartCharacterLib } from "@eveworld/world/src/modules/smart-character/SmartCharacterLib.sol";
import { EntityRecordData as EntityRecordCharacter } from "@eveworld/world/src/modules/smart-character/types.sol";
import { EntityRecordOffchainTableData } from "@eveworld/world/src/codegen/tables/EntityRecordOffchainTable.sol";
import { EntityRecordData, WorldPosition, Coord } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { SmartObjectData } from "@eveworld/world/src/modules/smart-deployable/types.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { SmartTurretLib } from "@eveworld/world/src/modules/smart-turret/SmartTurretLib.sol";
import { Utils as SmartTurretUtils } from "@eveworld/world/src/modules/smart-turret/Utils.sol";
import { CharactersByAddressTable } from "@eveworld/world/src/codegen/tables/CharactersByAddressTable.sol";

contract MockData is Script {
  using SmartCharacterUtils for bytes14;
  using SmartDeployableUtils for bytes14;
  using SmartTurretUtils for bytes14;
  using SmartCharacterLib for SmartCharacterLib.World;
  using SmartDeployableLib for SmartDeployableLib.World;
  using SmartTurretLib for SmartTurretLib.World;

  SmartCharacterLib.World smartCharacter;
  SmartDeployableLib.World smartDeployable;
  SmartTurretLib.World smartTurret;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(deployerPrivateKey);

    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);
    uint256 smartTurretId = vm.envUint("SMART_TURRET_ID");

    smartCharacter = SmartCharacterLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    smartDeployable = SmartDeployableLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    smartTurret = SmartTurretLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });    

    uint256 allowedCorpID = vm.envUint("ALLOWED_CORP_ID");

    //Create a smart character that is in the corporation
    if (CharactersByAddressTable.get(admin) == 0) {
      smartCharacter.createCharacter(
        123,           //characterID
        admin,         //characterAddress
        allowedCorpID, //corpID
        EntityRecordCharacter({ typeId: 111, itemId: 1, volume: 10 }),
        EntityRecordOffchainTableData({ name: "admin", dappURL: "noURL", description: "." }),
        "tokenCid"
      );
    }
    if (CharactersByAddressTable.get(player) == 0) {
      smartCharacter.createCharacter(
        77777,   //characterID
        player,  //characterAddress
        100,     //corpID
        EntityRecordCharacter({ typeId: 111, itemId: 1, volume: 10 }),
        EntityRecordOffchainTableData({ name: "testPlayer", dappURL: "noURL", description: "." }),
        "tokenCid"
      );
    }

    anchorAndOnlineSmartTurret(smartTurretId, player);

    vm.stopBroadcast();
  }

  function anchorAndOnlineSmartTurret(uint256 smartObjectId, address player) public {
    EntityRecordData memory entityRecordData = EntityRecordData({ typeId: 12345, itemId: 45, volume: 10 });
    SmartObjectData memory smartObjectData = SmartObjectData({ owner: player, tokenURI: "test" });
    WorldPosition memory worldPosition = WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) });

    uint256 fuelUnitVolume = 100;
    uint256 fuelConsumptionIntervalInSeconds = 100;
    uint256 fuelMaxCapacity = 100;
    smartDeployable.globalResume();
    smartTurret.createAndAnchorSmartTurret(
      smartObjectId,
      entityRecordData,
      smartObjectData,
      worldPosition,
      1e18,           // fuelUnitVolume,
      1,              // fuelConsumptionIntervalInSeconds,
      1000000 * 1e18  // fuelMaxCapacity,
    );

    smartDeployable.depositFuel(smartObjectId, 1);
    smartDeployable.bringOnline(smartObjectId);
  }
}
