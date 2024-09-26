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
    address player = vm.addr(deployerPrivateKey);

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

    //Create a smart character
    smartCharacter.createCharacter(
      11111,
      address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266),
      100,
      EntityRecordCharacter({ typeId: 111, itemId: 1, volume: 10 }),
      EntityRecordOffchainTableData({ name: "characterName", dappURL: "noURL", description: "." }),
      "tokenCid"
    );

    anchorAndOnlineSmartTurret(smartTurretId);

    vm.stopBroadcast();
  }

  function anchorAndOnlineSmartTurret(uint256 smartObjectId) public {
    EntityRecordData memory entityRecordData = EntityRecordData({ typeId: 12345, itemId: 45, volume: 10 });
    SmartObjectData memory smartObjectData = SmartObjectData({
      owner: address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266),
      tokenURI: "test"
    });
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
      1e18, // fuelUnitVolume,
      1, // fuelConsumptionIntervalInSeconds,
      1000000 * 1e18 // fuelMaxCapacity,
    );

    smartDeployable.depositFuel(smartObjectId, 1);
    smartDeployable.bringOnline(smartObjectId);
  }
}
