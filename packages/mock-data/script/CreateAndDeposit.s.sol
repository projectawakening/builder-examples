pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { InventoryItemTableData, InventoryItemTable } from "@eveworld/world/src/codegen/tables/InventoryItemTable.sol";
import { EphemeralInvItemTable, EphemeralInvItemTableData } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";

import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { Utils } from "@eveworld/world/src/modules/inventory/Utils.sol";

import { SmartStorageUnitLib } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";
import { InventoryLib } from "@eveworld/world/src/modules/inventory/InventoryLib.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE as DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";

contract CreateAndDeposit is Script {
  // assumes CreateAndAnchor.s.sol and BringOnline.s.sol have been run
  using InventoryLib for InventoryLib.World;
  using SmartStorageUnitLib for SmartStorageUnitLib.World;
  using Utils for bytes14;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);

    InventoryLib.World memory inventory = InventoryLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: DEPLOYMENT_NAMESPACE
    });

    SmartStorageUnitLib.World memory SSUInterface = SmartStorageUnitLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: DEPLOYMENT_NAMESPACE
    });

    // SSU ID
    uint256 smartObjectId = uint256(keccak256(abi.encode("item:<tenant_id>-<db_id>-2345")));

    // LOAD THE KEY OF AN APPROVED ADMIN ACCOUNT (ALSO IS SSU OWNER)
    uint256 ownerPrivateKey = vm.envUint("PRIVATE_KEY");
    address ownerSSU = vm.addr(ownerPrivateKey);

    // EPH INV OWNER ACCT
    address ephemeralOwner = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    // ITEM TO MOVE FROM INVENTORY TO EPHEMERAL
    uint256 inventoryItemId = uint256(123);
    InventoryItem[] memory invItems = new InventoryItem[](1);
    invItems[0] = InventoryItem({
      inventoryItemId: inventoryItemId,
      owner: ownerSSU,
      itemId: 12,
      typeId: 3,
      volume: 10,
      quantity: 1
    });

    // ITEM TO MOVE FROM EPHEMERAL TO INVENTORY
    uint256 ephInventoryItemId = uint256(345);
    InventoryItem[] memory ephInvItems = new InventoryItem[](1);
    ephInvItems[0] = InventoryItem({
      inventoryItemId: ephInventoryItemId,
      owner: ephemeralOwner,
      itemId: 22,
      typeId: 3,
      volume: 10,
      quantity: 1
    });

    // Start broadcasting transactions from the deployer account

    vm.startBroadcast(ownerPrivateKey);
    // check if SSU has any items to transfer and if not create them with SmartStorageUnit.createAndDepositItemsToInventory
    InventoryItemTableData memory invItemToTransfer = InventoryItemTable.get(
      DEPLOYMENT_NAMESPACE.inventoryItemTableId(),
      smartObjectId,
      invItems[0].inventoryItemId
    );
    if (invItemToTransfer.quantity == 0) {
      SSUInterface.createAndDepositItemsToInventory(smartObjectId, invItems);
    }
    // check if EPH INV has items to transfer and if not create them with SmartStorageUnit.createAndDepositItemsToEphemeralInventory(
    EphemeralInvItemTableData memory ephInvItemToTransfer = EphemeralInvItemTable.get(
      DEPLOYMENT_NAMESPACE.ephemeralInventoryItemTableId(),
      smartObjectId,
      ephInvItems[0].inventoryItemId,
      ephemeralOwner
    );
    if (ephInvItemToTransfer.quantity == 0) {
      SSUInterface.createAndDepositItemsToEphemeralInventory(smartObjectId, ephemeralOwner, ephInvItems);
    }
    vm.stopBroadcast();
  }
}
