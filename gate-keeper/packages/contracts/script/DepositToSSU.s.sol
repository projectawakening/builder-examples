// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Utils } from "../src/systems/gate_keeper/Utils.sol";
import { GateKeeper } from "../src/systems/gate_keeper/GateKeeper.sol";

contract DepositToSSU is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    vm.startBroadcast(playerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 quantity = 9; // test value

    ResourceId systemId = Utils.gateKeeperSystemId();

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    world.call(systemId, abi.encodeCall(GateKeeper.depositToSSU, (smartStorageUnitId, quantity)));
    vm.stopBroadcast();
  }
}
