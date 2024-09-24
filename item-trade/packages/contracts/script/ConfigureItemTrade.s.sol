// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { Utils } from "../src/systems/Utils.sol";
import { ItemTradeSystem } from "../src/systems/ItemTradeSystem.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";

contract ConfigureItemTrade is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    vm.startBroadcast(playerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    //Read from .env
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    address tokenAddress = vm.envAddress("ERC20_TOKEN_ADDRESS");
    address receiver = vm.envAddress("RECEIVER_ADDRESS");
    uint256 itemOutId = vm.envUint("ITEM_OUT_ID");
    uint256 price = vm.envUint("PRICE_IN_WEI");

    uint256 enforcedItemMultiple = vm.envUint("ENFORCED_ITEM_MULTIPLE");
    uint256 tokenAmount = vm.envUint("TOKEN_AMOUNT");
    uint256 itemInId = vm.envUint("ITEM_IN_ID");

    ResourceId systemId = Utils.itemSellerSystemId();

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    world.call(
      systemId,
      abi.encodeCall(ItemTradeSystem.registerERC20Token, (smartStorageUnitId, tokenAddress, receiver))
    );

    world.call(systemId, abi.encodeCall(ItemTradeSystem.setItemSellPrice, (smartStorageUnitId, itemOutId, price)));

    world.call(
      systemId,
      abi.encodeCall(
        ItemTradeSystem.setItemPurchaseMultiple,
        (smartStorageUnitId, itemInId, enforcedItemMultiple, tokenAmount)
      )
    );

    vm.stopBroadcast();
  }
}
