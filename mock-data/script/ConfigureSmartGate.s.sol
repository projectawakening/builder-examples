pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";

import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";
import { EntityRecordData, WorldPosition, Coord } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { SmartObjectData } from "@eveworld/world/src/modules/smart-deployable/types.sol";
import { SmartGateLib } from "@eveworld/world/src/modules/smart-gate/SmartGateLib.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { GlobalDeployableState } from "@eveworld/world/src/codegen/tables/GlobalDeployableState.sol";

contract ConfigureSmartGate is Script {
  using SmartGateLib for SmartGateLib.World;
  using SmartDeployableLib for SmartDeployableLib.World;
  using SmartDeployableUtils for bytes14;

  SmartDeployableLib.World smartDeployable;
  SmartGateLib.World smartGate;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address player = vm.addr(deployerPrivateKey);

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    smartDeployable = SmartDeployableLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    smartGate = SmartGateLib.World({ iface: IBaseWorld(worldAddress), namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE });

    uint256 sourceGateId = uint256(keccak256(abi.encode("item:<tenant_id>-<db_id>-5550")));
    uint256 destinationGateId = uint256(keccak256(abi.encode("item:<tenant_id>-<db_id>-5551")));

    //Create, anchor the smart gate and bring online
    anchorFuelAndOnline(sourceGateId, player);
    anchorFuelAndOnline(destinationGateId, player);

    //Deploy the Mock contract and configure the smart gate to use it
    IBaseWorld world = IBaseWorld(worldAddress);
    SmartGateTestSystem smartGateTestSystem = new SmartGateTestSystem();
    ResourceId smartGateTestSystemId = ResourceId.wrap(
      (bytes32(abi.encodePacked(RESOURCE_SYSTEM, FRONTIER_WORLD_DEPLOYMENT_NAMESPACE, "SmartGateTestSys")))
    );

    //register the smart gate system
    world.registerSystem(smartGateTestSystemId, smartGateTestSystem, true);
    //register the function selector
    world.registerFunctionSelector(smartGateTestSystemId, "canJump(uint256, uint256, uint256)");
    smartGate.configureSmartGate(sourceGateId, smartGateTestSystemId);

    //Link the smart gates
    smartGate.linkSmartGates(sourceGateId, destinationGateId);

    uint256 characterId = 12513;
    bool possibleToJump = smartGate.canJump(characterId, sourceGateId, destinationGateId);

    console.logBool(possibleToJump);

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

//Mock Contract for testing
contract SmartGateTestSystem is System {
  function canJump(uint256 characterId, uint256 sourceGateId, uint256 destinationGateId) public view returns (bool) {
    return false;
  }
}
