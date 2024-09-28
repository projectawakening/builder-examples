pragma solidity >=0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { InventoryItemTableData, InventoryItemTable } from "@eveworld/world/src/codegen/tables/InventoryItemTable.sol";
import { EphemeralInvItemTable, EphemeralInvItemTableData } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";

import { TransferItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { Utils } from "@eveworld/world/src/modules/inventory/Utils.sol";

import { SmartStorageUnitLib } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";
import { InventoryLib } from "@eveworld/world/src/modules/inventory/InventoryLib.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE as DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";

contract Transfer is Script {
  // assumes CreateAndAnchor.s.sol, BringOnline.s.sol and CreateAndDeposit.s.sol have been run
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

    // LOAD THE KEY THAT IS INTERACTING WITH THE TRANSFER FUNCTION
    uint256 ephemeralPrivateKey = uint256(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d);
    address ephemeralOwner = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    // LOAD THE KEY OF THE OWNER FOR THE SSU
    uint256 ownerPrivateKey = vm.envUint("PRIVATE_KEY");
    address ownerSSU = vm.addr(ownerPrivateKey);

    // // Start broadcasting transactions from the deployer account

    // ITEM TO MOVE FROM INVENTORY TO EPHEMERAL
    uint256 itemId = uint256(123);
    TransferItem[] memory invTransferItems = new TransferItem[](1);
    invTransferItems[0] = TransferItem(itemId, ownerSSU, 1);

    // ITEM TO MOVE FROM EPHEMERAL TO INVENTORY
    uint256 ephItemId = uint256(345);
    TransferItem[] memory ephInvTransferItems = new TransferItem[](1);
    ephInvTransferItems[0] = TransferItem(ephItemId, ephemeralOwner, 1);

    vm.startBroadcast(ephemeralPrivateKey); // if triggered the createItem functions need to be called from the owner/deployer account

    // TRANSFER
    inventory.inventoryToEphemeralTransfer(smartObjectId, ephemeralOwner, invTransferItems);
    inventory.ephemeralToInventoryTransfer(smartObjectId, ephInvTransferItems);

    // After transfer 1 invItem should go into ephemeral and 1 ephInvItem should go into inventory
    // SSU owner should have 1 ephInvItem after transfer
    // Ephermeral owner should have 1 invItem after transfer

    InventoryItemTableData memory ephItemInInv = InventoryItemTable.get(
      smartObjectId,
      ephInvTransferItems[0].inventoryItemId
    );
    console.log(ephItemInInv.quantity); //1

    EphemeralInvItemTableData memory itemInEphInv = EphemeralInvItemTable.get(
      smartObjectId,
      invTransferItems[0].inventoryItemId,
      ephemeralOwner
    );
    console.log(itemInEphInv.quantity); //1

    // STOP THE BROADCAST
    vm.stopBroadcast();
  }
}
