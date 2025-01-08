// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Utils } from "../src/systems/Utils.sol";
import { Utils as SmartTurretUtils } from "@eveworld/world/src/modules/smart-turret/Utils.sol";
import { SmartTurretLib } from "@eveworld/world/src/modules/smart-turret/SmartTurretLib.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { TargetPriority, Turret, SmartTurretTarget } from "@eveworld/world/src/modules/smart-turret/types.sol";
import { DeployableState, DeployableStateData } from "@eveworld/world/src/codegen/tables/DeployableState.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { SmartTurretConfigTable } from "@eveworld/world/src/codegen/tables/SmartTurretConfigTable.sol";
import { CharactersTableData, CharactersTable } from "@eveworld/world/src/codegen/tables/CharactersTable.sol";

import { RatioConfig, RatioConfigData } from "../src/codegen/tables/RatioConfig.sol";
import { SmartStorageUnitSystem } from "../src/systems/SmartStorageUnitSystem.sol";

contract ReadOutput is Script {

  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(playerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    uint256 ssuID = vm.envUint("SSU_ID");
    uint256 itemIn = vm.envUint("ITEM_IN_ID");
    uint64 quantity = 10;

    ResourceId systemId = Utils.smartStorageUnitSystemId();

    (uint64 outputAmount, uint64 remainingInput) = abi.decode(
      world.call(systemId, abi.encodeCall(SmartStorageUnitSystem.readOutput, (quantity, ssuID, itemIn))),
      (uint64, uint64)
    );

    console.log("OUTPUT AMOUNT: ");
    console.log(outputAmount);

    console.log(remainingInput);

    vm.stopBroadcast();
  }

  function _namespace() internal pure returns (bytes14 namespace) {
    return FRONTIER_WORLD_DEPLOYMENT_NAMESPACE;
  }
}
