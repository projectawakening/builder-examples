// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Utils } from "../src/systems/gate_keeper/Utils.sol";
import { GateKeeperSystem } from "../src/systems/gate_keeper/GateKeeperSystem.sol";

contract ConfigureGateKeeper is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    vm.startBroadcast(playerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    //Read from .env
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 inventoryItemId = vm.envUint("INVENTORY_ITEM_ID");
    uint256 targetQuantity = vm.envUint("TARGET_QUANTITY");

    ResourceId systemId = Utils.gateKeeperSystemId();

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    world.call(
      systemId,
      abi.encodeCall(GateKeeperSystem.configureGateKeeper, (smartStorageUnitId, inventoryItemId, targetQuantity))
    );
    vm.stopBroadcast();
  }
}
