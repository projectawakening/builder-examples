// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Utils } from "../src/systems/Utils.sol";
import { Utils as SmartTurretUtils } from "@eveworld/world/src/modules/smart-turret/Utils.sol";
import { SmartTurretLib } from "@eveworld/world/src/modules/smart-turret/SmartTurretLib.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

import { SmartTurretSystem } from "../src/systems/SmartTurretSystem.sol";

contract ConfigureSmartTurret is Script {
  using SmartTurretUtils for bytes14;
  using SmartTurretLib for SmartTurretLib.World;

  SmartTurretLib.World smartTurret;

  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(playerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    smartTurret = SmartTurretLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    uint256 smartTurretId = vm.envUint("SMART_TURRET_ID");
    uint256 allowedCorpId = vm.envUint("ALLOWED_CORP_ID");

    ResourceId systemId = Utils.smartTurretSystemId();
    
    // This function can only be called by the owner of the smart turret
    smartTurret.configureSmartTurret(smartTurretId, systemId);
    
    world.call(
      systemId,
      abi.encodeCall(SmartTurretSystem.setAllowedCorp, (allowedCorpId))
    );

    vm.stopBroadcast();
  }
}
