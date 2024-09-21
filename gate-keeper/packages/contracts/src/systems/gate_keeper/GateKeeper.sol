// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { IERC20 } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20.sol";
import { IERC721 } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721.sol";

import { DeployableTokenTable } from "@eveworld/world/src/codegen/tables/DeployableTokenTable.sol";
import { InventoryLib } from "@eveworld/world/src/modules/inventory/InventoryLib.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { IInventoryErrors } from "@eveworld/world/src/modules/inventory/IInventoryErrors.sol";
import { InventoryItemTable } from "@eveworld/world/src/codegen/tables/InventoryItemTable.sol";
import { EphemeralInvTable } from "@eveworld/world/src/codegen/tables/EphemeralInvTable.sol";
import { EntityRecordTable, EntityRecordTableData } from "@eveworld/world/src/codegen/tables/EntityRecordTable.sol";
import { Utils as EntityRecordUtils } from "@eveworld/world/src/modules/entity-record/Utils.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { Utils as InventoryUitls } from "@eveworld/world/src/modules/inventory/Utils.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE as DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { EphemeralInvItemTableData, EphemeralInvItemTable } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";

import { GateKeeperConfig, GateKeeperConfigData } from "../../codegen/tables/GateKeeperConfig.sol";

/**
 * @dev This contract is an example for extending SSU functionality from game.
 * This contract implements an GateKeeper functionality that takes in a item of x type until we reach a certain amount and perform a action
 */
contract GateKeeper is System {
  using InventoryLib for InventoryLib.World;
  using EntityRecordUtils for bytes14;
  using SmartDeployableUtils for bytes14;
  using InventoryUitls for bytes14;

  /**
   * @dev Only owner modifer
   */
  modifier onlyOwner(uint256 smartObjectId) {
    address ssuOwner = IERC721(DeployableTokenTable.getErc721Address(_namespace().deployableTokenTableId())).ownerOf(
      smartObjectId
    );
    require(_msgSender() == ssuOwner, "Only owner can call this function");
    _;
  }

  function configureGateKeeper(
    uint256 smartObjectId,
    uint256 inventoryItemId,
    uint256 targetItemQuantity
  ) public onlyOwner(smartObjectId) {
    EntityRecordTableData memory entityInRecord = EntityRecordTable.get(
      _namespace().entityRecordTableId(),
      inventoryItemId
    );

    if (entityInRecord.recordExists == false) {
      revert IInventoryErrors.Inventory_InvalidItem("GateKeeper: item is not created on-chain", entityInRecord.itemId);
    }

    GateKeeperConfig.set(smartObjectId, inventoryItemId, targetItemQuantity, false);
  }

  /**
   * @dev Set the Gatekeeper configuration
   * @param smartObjectId The smart object id of the SSU
   * @param inventoryItemId The item id of the item
   * @param targetQuantity The price of the item in ERC-20 tokens
   */
  function changeTargetQuantity(
    uint256 smartObjectId,
    uint256 inventoryItemId,
    uint256 targetQuantity
  ) public onlyOwner(smartObjectId) {
    require(targetQuantity > 0, "Price cannot be 0");
    GateKeeperConfig.setTargetItemQuantity(smartObjectId, targetQuantity);
  }

  /**
   * @dev deposit items to the Gatekeeper SSU
   * @param smartObjectId The smart object id of the SSU
   * @param quantity The quantity of the item to deposit into the SSU
   */
  function depositToSSU(uint256 smartObjectId, uint256 quantity) public {    
    GateKeeperConfigData memory gatekeeperConfig = GateKeeperConfig.get(smartObjectId);
    
    require(gatekeeperConfig.isGoalReached == false, "GateKeeper goal reached");
    require(quantity != 0, "No items deposited");    

    uint256 quantityInInventory = InventoryItemTable.getQuantity(
      _namespace().inventoryItemTableId(),
      smartObjectId,
      gatekeeperConfig.itemIn
    );

    if (quantityInInventory + quantity > gatekeeperConfig.targetItemQuantity) {
      quantity = gatekeeperConfig.targetItemQuantity - quantityInInventory ;
    }

    if (quantityInInventory + quantity == gatekeeperConfig.targetItemQuantity) {
      GateKeeperConfig.setIsGoalReached(smartObjectId, true);
    }
    
    EntityRecordTableData memory entityInRecord = EntityRecordTable.get(
      _namespace().entityRecordTableId(),
      gatekeeperConfig.itemIn
    );

    if (entityInRecord.recordExists == false) {
      revert IInventoryErrors.Inventory_InvalidItem("GateKeeper: item is not created on-chain", entityInRecord.itemId);
    }

    InventoryItem[] memory inItems = new InventoryItem[](1);
    inItems[0] = InventoryItem(
      gatekeeperConfig.itemIn,
      _msgSender(),
      entityInRecord.itemId,
      entityInRecord.typeId,
      entityInRecord.volume,
      quantity
    );

    _inventoryLib().ephemeralToInventoryTransfer(smartObjectId, inItems);    
  }

  /**
   * @dev Get the GateKeeper configuration
   * @param smartObjectId The smart object id of the SSU
   */
  function getGateKeeperConfig(uint256 smartObjectId) public returns (GateKeeperConfigData memory) {
    return GateKeeperConfig.get(smartObjectId);
  }

  function getContractAddress() public returns (address) {
    return address(this);
  }

  function _inventoryLib() internal view returns (InventoryLib.World memory) {
    if (!ResourceIds.getExists(WorldResourceIdLib.encodeNamespace(DEPLOYMENT_NAMESPACE))) {
      return InventoryLib.World({ iface: IBaseWorld(_world()), namespace: DEPLOYMENT_NAMESPACE });
    } else return InventoryLib.World({ iface: IBaseWorld(_world()), namespace: DEPLOYMENT_NAMESPACE });
  }

  function _namespace() internal pure returns (bytes14 namespace) {
    return DEPLOYMENT_NAMESPACE;
  }
}
