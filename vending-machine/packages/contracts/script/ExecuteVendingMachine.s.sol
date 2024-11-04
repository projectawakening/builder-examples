// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { EphemeralInvItemTableData, EphemeralInvItemTable } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";
import { Utils as InventoryUtils } from "@eveworld/world/src/modules/inventory/Utils.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

import { RatioConfig } from "../src/codegen/tables/RatioConfig.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/vending_machine/Utils.sol";
import { VendingMachineSystem } from "../src/systems/vending_machine/VendingMachineSystem.sol";

contract ExecuteVendingMachine is Script {
  using InventoryUtils for bytes14;
  function run(address worldAddress) external {
    uint256 playerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    vm.startBroadcast(playerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    //Read from .env
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 itemIn = vm.envUint("ITEM_IN_ID");
    uint256 itemOut = vm.envUint("ITEM_OUT_ID");

    ResourceId systemId = Utils.vendingMachineSystemId();

    //Check Players ephemeral inventory before
    EphemeralInvItemTableData memory invItem = EphemeralInvItemTable.get(smartStorageUnitId, itemOut, player);
    console.log(invItem.quantity); //0

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    world.call(systemId, abi.encodeCall(VendingMachineSystem.executeVendingMachine, (smartStorageUnitId, 5, itemIn)));

    //Check Players ephemeral inventory after
    invItem = EphemeralInvItemTable.get(smartStorageUnitId, itemOut, player);
    console.log(invItem.quantity); //2

    vm.stopBroadcast();
  }
}
