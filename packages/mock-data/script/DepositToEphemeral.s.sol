pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { SmartStorageUnitLib } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

contract DepositToEphemeral is Script {
  using SmartStorageUnitLib for SmartStorageUnitLib.World;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address ephemeralInvOwner1 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    address ephemeralInvOwner2 = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);
    SmartStorageUnitLib.World memory smartStorageUnit = SmartStorageUnitLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    uint256 smartObjectId = uint256(keccak256(abi.encode("item:<tenant_id>-<db_id>-2345")));
    InventoryItem[] memory items = new InventoryItem[](2);
    items[0] = InventoryItem({
      inventoryItemId: 456,
      owner: ephemeralInvOwner1,
      itemId: 22,
      typeId: 3,
      volume: 10,
      quantity: 3
    });

    items[1] = InventoryItem({
      inventoryItemId: 789,
      owner: ephemeralInvOwner1,
      itemId: 0,
      typeId: 34,
      volume: 10,
      quantity: 10
    });

    smartStorageUnit.createAndDepositItemsToEphemeralInventory(smartObjectId, ephemeralInvOwner1, items);

    items = new InventoryItem[](1);
    items[0] = InventoryItem({
      inventoryItemId: 888,
      owner: ephemeralInvOwner2,
      itemId: 0,
      typeId: 35,
      volume: 10,
      quantity: 300
    });

    smartStorageUnit.createAndDepositItemsToEphemeralInventory(smartObjectId, ephemeralInvOwner2, items);

    vm.stopBroadcast();
  }
}
