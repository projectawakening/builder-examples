// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Utils } from "../src/systems/Utils.sol";

import { SmartAssembly } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/SmartAssembly.sol";
import { SmartTurretSystem, smartTurretSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/smart-turret/SmartTurretSystem.sol";
import { SmartTurretSystem as CustomSmartTurretSystem } from "../src/systems/SmartTurretSystem.sol";

contract ConfigureSmartTurret is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    uint256 smartTurretId = vm.envUint("SMART_TURRET_ID");
    uint256 allowedTribeId = vm.envUint("ALLOWED_TRIBE_ID");

    require(
      SmartAssembly.lengthAssemblyType(smartTurretId) != 0,
      "No Smart Assembly found. Please run 'pnpm mock-data' to generate one."
    );

    ResourceId systemId = Utils.smartTurretSystemId();
    
    // This function can only be called by the owner of the smart turret
    smartTurretSystem.configureTurret(smartTurretId, systemId);
    
    world.call(
      systemId,
      abi.encodeCall(CustomSmartTurretSystem.setAllowedTribe, (allowedTribeId))
    );

    vm.stopBroadcast();
  }
}
