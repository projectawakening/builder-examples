// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";


import { Utils } from "../src/systems/item_seller/Utils.sol";
import { ItemSeller } from "../src/systems/item_seller/ItemSeller.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";

contract ConfigureLensSeller is Script {
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
    uint256 inventoryItemId = vm.envUint("INVENTORY_ITEM_ID");
    uint256 price = vm.envUint("PRICE_IN_WEI");

    ResourceId systemId = Utils.itemSellerSystemId();

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    world.call(
      systemId,
      abi.encodeCall(
        ItemSeller.registerERC20Token,(smartStorageUnitId, tokenAddress, receiver))
    );

    world.call(
      systemId,
      abi.encodeCall(
        ItemSeller.setItemPrice,(smartStorageUnitId, inventoryItemId, price))
    );

    vm.stopBroadcast();
  }
}
