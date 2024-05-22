// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IItemSeller } from "../src/codegen/world/IItemSeller.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { RatioConfig } from "../src/codegen/tables/RatioConfig.sol";

contract ConfigureLensSeller is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(playerPrivateKey);

    //Read from .env
    // uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    address tokenAddress = vm.envAddress("ERC20_TOKEN_ADDRESS");
    address receiver = vm.envAddress("RECEIVER_ADDRESS");
    uint256 inventoryItemId = vm.envUint("INVENTORY_ITEM_ID");
    uint256 price = vm.envUint("PRICE");

    uint256 smartStorageUnitId = uint256(keccak256(abi.encode("item:<tenant_id>-<db_id>-2345")));

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    IItemSeller(worldAddress).test2__registerERC20Token(smartStorageUnitId, tokenAddress, receiver);

    IItemSeller(worldAddress).test2__setItemPrice(smartStorageUnitId, inventoryItemId, price);

    vm.stopBroadcast();
  }
}
