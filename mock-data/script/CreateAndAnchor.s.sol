pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { EntityRecordData, SmartObjectData, WorldPosition, Coord } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { SmartStorageUnitLib } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";
import { SmartCharacterLib } from "@eveworld/world/src/modules/smart-character/SmartCharacterLib.sol";
import { EntityRecordData as CharEntityRecordData } from "@eveworld/world/src/modules/smart-character/types.sol";
import { EntityRecordOffchainTableData } from "@eveworld/world/src/codegen/tables/EntityRecordOffchainTable.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { CharactersTable } from "@eveworld/world/src/codegen/tables/CharactersTable.sol";

contract CreateAndAnchor is Script {
  using SmartStorageUnitLib for SmartStorageUnitLib.World;
  using SmartCharacterLib for SmartCharacterLib.World;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address player = vm.addr(deployerPrivateKey);

    SmartCharacterLib.World memory smartCharacter = SmartCharacterLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);
    SmartStorageUnitLib.World memory smartStorageUnit = SmartStorageUnitLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    uint256 smartObjectId = uint256(keccak256(abi.encode("item:<tenant_id>-<db_id>-23145")));
    if (CharactersTable.getCharacterAddress(12513) == address(0)) {
      smartCharacter.createCharacter(
        12513,
        player,
        222,
        CharEntityRecordData({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "awesome character", dappURL: "noURL", description: "." }),
        "azert"
      );
    }

    smartStorageUnit.createAndAnchorSmartStorageUnit(
      smartObjectId,
      EntityRecordData({ typeId: 7888, itemId: 111, volume: 10 }),
      SmartObjectData({ owner: player, tokenURI: "test" }),
      WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) }),
      1e18, // fuelUnitVolume,
      1, // fuelConsumptionIntervalInSeconds,
      1000000 * 1e18, //fuelMaxCapacity,
      100000000, // storageCapacity,
      100000000000 // ephemeralStorageCapacity
    );

    vm.stopBroadcast();
  }
}
