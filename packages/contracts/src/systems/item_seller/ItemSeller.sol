// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { IERC20 } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20.sol";

import { InventoryLib } from "@eveworld/world/src/modules/inventory/InventoryLib.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { IInventoryErrors } from "@eveworld/world/src/modules/inventory/IInventoryErrors.sol";
import { InventoryItemTable } from "@eveworld/world/src/codegen/tables/InventoryItemTable.sol";
import { EphemeralInvTable } from "@eveworld/world/src/codegen/tables/EphemeralInvTable.sol";
import { EntityRecordTable, EntityRecordTableData } from "@eveworld/world/src/codegen/tables/EntityRecordTable.sol";
import { Utils as EntityRecordUtils } from "@eveworld/world/src/modules/entity-record/Utils.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE as DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

import { ItemSellerERC20, ItemSellerERC20Data } from "../../codegen/tables/ItemSellerERC20.sol";
import { ItemPrice, ItemPriceData } from "../../codegen/tables/ItemPrice.sol";

/**
 * @dev This contract is an example for extending Inventory functionality from game.
 * This contract implements an ItemSeller that swaps ERC-20 tokens for Inventory items
 */
contract ItemSeller is System {
  using InventoryLib for InventoryLib.World;
  using EntityRecordUtils for bytes14;

  /**
   * @dev Register an ERC-20 token to be used for swapping with Inventory items
   * @param smartObjectId The smart object id of the vending machine
   * @param tokenAddress The address of the ERC-20 token
   * @param receiver The address of the receiver of the token
   */
  function registerERC20Token(uint256 smartObjectId, address tokenAddress, address receiver) public {
    require(tokenAddress != address(0) && receiver != address(0), "Invalid address");

    uint256 tokenDecimals = IERC20(tokenAddress).decimals();

    ItemSellerERC20.set(smartObjectId, tokenAddress, tokenDecimals, receiver);
  }

  /**
   * @dev Update the receiver address for the ERC-20 token
   * @param smartObjectId The smart object id of the vending machine
   * @param receiver The address of the receiver of the token
   */
  function updateERC20Receiver(uint256 smartObjectId, address receiver) public {
    require(receiver != address(0), "Invalid address");

    ItemSellerERC20Data memory ssuData = ItemSellerERC20.get(smartObjectId);
    require(ssuData.tokenAddress != address(0), "Invalid SSU ID");

    ItemSellerERC20.setReceiver(smartObjectId, receiver);
  }

  /**
   * @dev Get the ERC-20 token data
   * @param smartObjectId The smart object id of the vending machine
   */
  function getERC20Data(uint256 smartObjectId) public view returns (ItemSellerERC20Data memory) {
    return ItemSellerERC20.get(smartObjectId);
  }

  /**
   * @dev Set the price of an item in ERC-20 tokens
   * @param smartObjectId The smart object id of the vending machine
   * @param itemId The item id of the item
   * @param price The price of the item in ERC-20 tokens
   */
  function setItemPrice(uint256 smartObjectId, uint256 itemId, uint256 price) public {
    require(price > 0, "Price cannot be 0");

    ItemSellerERC20Data memory ssuData = ItemSellerERC20.get(smartObjectId);
    require(ssuData.tokenAddress != address(0), "Invalid Smart Object ID");

    ItemPrice.set(smartObjectId, itemId, true, price);
  }

  /**
   * @dev Unset the price of an item in ERC-20 tokens
   * @param smartObjectId The smart object id of the vending machine
   * @param itemId The item id of the item
   */
  function unsetItemPrice(uint256 smartObjectId, uint256 itemId) public {
    ItemPrice.set(smartObjectId, itemId, false, 0);
  }

  /**
   * @dev Get the price of an item in ERC-20 tokens
   * @param smartObjectId The smart object id of the vending machine
   * @param itemId The item id of the item
   */
  function getItemPriceData(uint256 smartObjectId, uint256 itemId) public view returns (ItemPriceData memory) {
    return ItemPrice.get(smartObjectId, itemId);
  }

  /**
   * @dev Purchase an item with ERC-20 tokens
   * @param smartObjectId The smart object id of the vending machine
   * @param itemId The item id of the item
   * @param quantity The quantity of the item to purchase
   */
  function purchaseItem(uint256 smartObjectId, uint256 itemId, uint256 quantity) public {
    ItemSellerERC20Data memory ssuData = ItemSellerERC20.get(smartObjectId);
    require(ssuData.tokenAddress != address(0), "Invalid Smart Object ID");

    ItemPriceData memory itemPriceData = ItemPrice.get(smartObjectId, itemId);
    require(itemPriceData.isSet, "Item price not set");

    uint256 totalAmount = itemPriceData.price * quantity;

    IERC20(ssuData.tokenAddress).transferFrom(msg.sender, ssuData.receiver, totalAmount);

    // check if inventory has sufficient items
    InventoryItem memory inventoryItem = InventoryItemTable.get(
      _namespace().inventoryItemTableId(),
      smartObjectId,
      itemId
    );
    require(inventoryItem.quantity >= quantity, "Insufficient quantity");

    // set inventory quantity to new quantity
    InventoryItemTable.setQuantity(
      _namespace().inventoryItemTableId(),
      smartObjectId,
      itemId,
      inventoryItem.quantity - quantity
    );
  }

  function _namespace() internal view returns (bytes14 namespace) {
    return DEPLOYMENT_NAMESPACE;
  }
}
