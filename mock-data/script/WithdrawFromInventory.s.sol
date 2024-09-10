pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { InventoryLib } from "@eveworld/world/src/modules/inventory/InventoryLib.sol";
import { SmartStorageUnitLib } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { InventoryItemTableData, InventoryItemTable } from "@eveworld/world/src/codegen/tables/InventoryItemTable.sol";
import { Utils as InventoryUtils } from "@eveworld/world/src/modules/inventory/Utils.sol";

contract WithdrawFromInventory is Script {
  using InventoryLib for InventoryLib.World;
  using InventoryUtils for bytes14;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address invOwner = vm.addr(deployerPrivateKey);

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);
    InventoryLib.World memory inventory = InventoryLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    uint256 smartObjectId = uint256(keccak256(abi.encode("item:<tenant_id>-<db_id>-2345")));
    InventoryItem[] memory items = new InventoryItem[](3);
    items[0] = InventoryItem({ inventoryItemId: 123, owner: invOwner, itemId: 0, typeId: 23, volume: 10, quantity: 1 });
    items[1] = InventoryItem({
      inventoryItemId: 1234,
      owner: invOwner,
      itemId: 0,
      typeId: 34,
      volume: 10,
      quantity: 10
    });
    items[2] = InventoryItem({
      inventoryItemId: 1235,
      owner: invOwner,
      itemId: 0,
      typeId: 35,
      volume: 10,
      quantity: 10
    });

    inventory.withdrawFromInventory(smartObjectId, items);

    InventoryItemTableData memory inventoryItem1 = InventoryItemTable.get(
      FRONTIER_WORLD_DEPLOYMENT_NAMESPACE.inventoryItemTableId(),
      smartObjectId,
      items[0].inventoryItemId
    );
    InventoryItemTableData memory inventoryItem2 = InventoryItemTable.get(
      FRONTIER_WORLD_DEPLOYMENT_NAMESPACE.inventoryItemTableId(),
      smartObjectId,
      items[1].inventoryItemId
    );

    console.log(inventoryItem1.quantity);
    InventoryItemTableData memory inventoryItem3 = InventoryItemTable.get(
      FRONTIER_WORLD_DEPLOYMENT_NAMESPACE.inventoryItemTableId(),
      smartObjectId,
      items[2].inventoryItemId
    );

    console.log(inventoryItem1.quantity);
    console.log(inventoryItem2.quantity);
    console.log(inventoryItem3.quantity);

    vm.stopBroadcast();
  }
}
