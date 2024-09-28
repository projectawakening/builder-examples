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
import { EphemeralInvItemTableData, EphemeralInvItemTable } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";
import { Utils as InventoryUtils } from "@eveworld/world/src/modules/inventory/Utils.sol";

contract WithdrawFromEphemeral is Script {
  using InventoryLib for InventoryLib.World;
  using InventoryUtils for bytes14;

  function run(address worldAddress) public {
    StoreSwitch.setStoreAddress(worldAddress);
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address invOwner = vm.addr(deployerPrivateKey);

    uint256 ephemeralPrivateKey1 = uint256(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d);
    address ephemeralOwner1 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    uint256 ephemeralPrivateKey2 = uint256(0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a);
    address ephemeralOwner2 = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(ephemeralPrivateKey1);
    InventoryLib.World memory inventory = InventoryLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    uint256 smartObjectId = uint256(keccak256(abi.encode("item:<tenant_id>-<db_id>-2345")));
    InventoryItem[] memory items = new InventoryItem[](2);
    items[0] = InventoryItem({
      inventoryItemId: 456,
      owner: ephemeralOwner1,
      itemId: 22,
      typeId: 3,
      volume: 10,
      quantity: 3
    });

    items[1] = InventoryItem({
      inventoryItemId: 789,
      owner: ephemeralOwner1,
      itemId: 0,
      typeId: 34,
      volume: 10,
      quantity: 1
    });

    inventory.withdrawFromEphemeralInventory(smartObjectId, ephemeralOwner1, items);

    items = new InventoryItem[](1);
    items[0] = InventoryItem({
      inventoryItemId: 888,
      owner: ephemeralOwner2,
      itemId: 0,
      typeId: 35,
      volume: 10,
      quantity: 250
    });
    inventory.withdrawFromEphemeralInventory(smartObjectId, ephemeralOwner2, items);

    EphemeralInvItemTableData memory invItem = EphemeralInvItemTable.get(
      smartObjectId,
      items[0].inventoryItemId,
      ephemeralOwner2
    );
    console.log(invItem.quantity); //0

    vm.stopBroadcast();
  }
}
