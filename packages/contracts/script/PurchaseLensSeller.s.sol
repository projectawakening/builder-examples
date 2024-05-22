// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IItemSeller } from "../src/codegen/world/IItemSeller.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { RatioConfig } from "../src/codegen/tables/RatioConfig.sol";

import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { PuppetModule } from "@latticexyz/world-modules/src/modules/puppet/PuppetModule.sol";
import { IERC20Mintable } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20Mintable.sol";
import { ERC20Module } from "@latticexyz/world-modules/src/modules/erc20-puppet/ERC20Module.sol";

contract PurchaseLensSeller is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(playerPrivateKey);

    address owner = vm.addr(playerPrivateKey);

    console.log(owner);

    //Read from .env
    // uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 inventoryItemId = vm.envUint("INVENTORY_ITEM_ID");

    uint256 smartStorageUnitId = uint256(keccak256(abi.encode("item:<tenant_id>-<db_id>-2345")));

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    IItemSeller(worldAddress).test2__purchaseItem(smartStorageUnitId, inventoryItemId, 1);

    vm.stopBroadcast();
  }

  function itemSellerSystemId() internal pure returns (uint256) {
    return 0;
  }
}
