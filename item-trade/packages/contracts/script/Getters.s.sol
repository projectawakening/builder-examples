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

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { ItemTradeSystem } from "../src/systems/ItemTradeSystem.sol";

import { ItemTradeERC20, ItemTradeERC20Data } from "../src/codegen/tables/ItemTradeERC20.sol";
import { ItemPriceInToken, ItemPriceInTokenData } from "../src/codegen/tables/ItemPriceInToken.sol";
import { ItemQuantityMultipleForToken, ItemQuantityMultipleForTokenData } from "../src/codegen/tables/ItemQuantityMultipleForToken.sol";

contract Getters is Script {
  function run(address worldAddress) external {
    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    //Read from .env
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 inventoryInId = vm.envUint("ITEM_IN_ID");
    uint256 inventoryOutId = vm.envUint("ITEM_OUT_ID");
    uint256 playerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    ResourceId systemId = Utils.itemSellerSystemId();
    ItemTradeERC20Data memory erc20Data = IWorld(worldAddress).test__getERC20Data(smartStorageUnitId);
    console.log(erc20Data.tokenAddress);

    ItemQuantityMultipleForTokenData memory sellPriceData = IWorld(worldAddress).test__getItemSellPriceData(
      smartStorageUnitId,
      inventoryInId
    );
    console.log(sellPriceData.enforcedItemMultiple);

    ItemPriceInTokenData memory buyPrice = IWorld(worldAddress).test__getItemBuyPriceData(
      smartStorageUnitId,
      inventoryOutId
    );
    console.log(buyPrice.price);

    console.log(IWorld(worldAddress).test__getPlayerEphemeralItemBalance(smartStorageUnitId, inventoryInId, player));
  }
}
