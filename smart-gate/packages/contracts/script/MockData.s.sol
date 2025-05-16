pragma solidity >=0.8.24;

//External imports
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { UNLIMITED_DELEGATION } from "@latticexyz/world/src/constants.sol";

//@eveworld imports
import { IBaseWorld } from "@eveworld/world-v2/src/codegen/world/IWorld.sol";

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

contract MockData is Script {
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

    //Get the allowed corp
    uint256 corpID = vm.envUint("ALLOWED_CORP_ID");

    uint256 adminCharacterSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, 234);
    uint256 playerCharacterSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, 235);

    //Create a smart character
    if (CharactersByAccount.get(admin) == 0) {
      console.log("Creating admin character");
      smartCharacterSystem.createCharacter(
        adminCharacterSmartObjectId,
        admin,
        7777,
        EntityRecordParams({ tenantId: tenantId, typeId: 1, itemId: 234, volume: 100 }),
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

    anchorFuelAndOnline(sourceGateId, player);
    anchorFuelAndOnline(destinationGateId, player);

    vm.stopBroadcast();
  }

  function anchorFuelAndOnline(uint256 smartObjectId, address player) public {
    smartGateSystem.createAndAnchorSmartGate(
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
      smartDeployableSystem.globalResume();
    }

    smartDeployableSystem.depositFuel(smartObjectId, 200010);
    smartDeployableSystem.bringOnline(smartObjectId);
  }
}