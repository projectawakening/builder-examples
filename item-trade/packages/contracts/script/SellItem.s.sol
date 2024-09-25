// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { PuppetModule } from "@latticexyz/world-modules/src/modules/puppet/PuppetModule.sol";
import { IERC20Mintable } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20Mintable.sol";
import { ERC20Module } from "@latticexyz/world-modules/src/modules/erc20-puppet/ERC20Module.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { EphemeralInvItemTableData, EphemeralInvItemTable } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { ItemTradeSystem } from "../src/systems/ItemTradeSystem.sol";

contract SellItem is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);
    vm.startBroadcast(playerPrivateKey);
    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    //Read from .env
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 inventoryItemId = vm.envUint("ITEM_IN_ID");

    EphemeralInvItemTableData memory invItem = EphemeralInvItemTable.get(smartStorageUnitId, inventoryItemId, player);
    console.log(invItem.quantity); // 1500

    ResourceId systemId = Utils.itemSellerSystemId();
    world.call(systemId, abi.encodeCall(ItemTradeSystem.sellItems, (smartStorageUnitId, inventoryItemId, (99 * 2))));

    invItem = EphemeralInvItemTable.get(smartStorageUnitId, inventoryItemId, player);
    console.log(invItem.quantity); // 1302

    vm.stopBroadcast();
  }
}
