// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

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
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE as DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

import { ItemTradeERC20, ItemTradeERC20Data } from "../codegen/tables/ItemTradeERC20.sol";
import { ItemPriceInToken, ItemPriceInTokenData } from "../codegen/tables/ItemPriceInToken.sol";
import { ItemQuantityMultipleForToken, ItemQuantityMultipleForTokenData } from "../codegen/tables/ItemQuantityMultipleForToken.sol";
import { Utils as ItemTradeUtils } from "./Utils.sol";

/**
 * @dev This contract implements an ItemTrade system that allows buying and selling of items using ERC-20 tokens
 */
contract ItemTradeSystem is System {
  using InventoryLib for InventoryLib.World;
  using EntityRecordUtils for bytes14;
  using ItemTradeUtils for bytes14;
  using SmartDeployableUtils for bytes14;

  /**
   * @dev Only owner modifier
   */
  modifier onlyOwner(uint256 smartObjectId) {
    address ssuOwner = IERC721(DeployableTokenTable.getErc721Address()).ownerOf(smartObjectId);
    require(_msgSender() == ssuOwner, "Only owner can call this function");
    _;
  }

  /**
   * @dev Register an ERC-20 token to be used for swapping with Inventory items
   * @param smartObjectId The smart object id of the SSU
   * @param tokenAddress The address of the ERC-20 token
   * @param receiver The address of the receiver of the token
   */
  function registerERC20Token(
    uint256 smartObjectId,
    address tokenAddress,
    address receiver
  ) public onlyOwner(smartObjectId) {
    require(tokenAddress != address(0) && receiver != address(0), "Invalid address");

    uint256 tokenDecimals = IERC20(tokenAddress).decimals();

    ItemTradeERC20.set(smartObjectId, tokenAddress, tokenDecimals, receiver);
  }

  /**
   * @dev Update the receiver address for the ERC-20 token
   * @param smartObjectId The smart object id of the SSU
   * @param receiver The address of the receiver of the token
   */
  function updateERC20Receiver(uint256 smartObjectId, address receiver) public onlyOwner(smartObjectId) {
    require(receiver != address(0), "Invalid address");

    ItemTradeERC20Data memory ssuData = ItemTradeERC20.get(smartObjectId);
    require(ssuData.tokenAddress != address(0), "Invalid SSU ID");

    ItemTradeERC20.setReceiver(smartObjectId, receiver);
  }

  /**
   * @dev Set the price of an item in ERC-20 tokens
   * This function transfer the item from the owners inventory to players ephemeral inventory return for EVE tokens to the player
   * @param smartObjectId The smart object id of the SSU
   * @param itemId The id of the item
   * @param priceInWei The price of the item in ERC-20 tokens
   */
  function setItemPrice(uint256 smartObjectId, uint256 itemId, uint256 priceInWei) public onlyOwner(smartObjectId) {
    require(priceInWei > 0, "Price cannot be 0");

    ItemTradeERC20Data memory ssuData = ItemTradeERC20.get(smartObjectId);
    require(ssuData.tokenAddress != address(0), "Invalid Smart Object ID");

    ItemPriceInToken.set(smartObjectId, itemId, true, priceInWei);
  }

  /**
   * @dev Set the price of an item in ERC-20 tokens based on enforced multiples
   * @param smartObjectId The smart object id of the SSU
   * @param itemId The id of the item
   * @param enforcedItemMultiple is the enforced multiple for the item per token
   */
  function setEnforcedItemMultiple(
    uint256 smartObjectId,
    uint256 itemId,
    uint256 enforcedItemMultiple,
    uint256 tokenAmount
  ) public onlyOwner(smartObjectId) {
    require(enforcedItemMultiple > 0, "Multiple must be greater than 0");
    require(tokenAmount > 0, "Token amount must be greater than 0");

    ItemTradeERC20Data memory ssuData = ItemTradeERC20.get(smartObjectId);
    require(ssuData.tokenAddress != address(0), "Invalid Smart Object ID");

    ItemQuantityMultipleForToken.set(smartObjectId, itemId, true, enforcedItemMultiple, tokenAmount);
  }

  /**
   * @dev Purchase an item with ERC-20 tokens
   * @param smartObjectId The smart object id of the SSU
   * @param itemId The id of the item
   * @param quantity The quantity of the item to purchase
   */
  function purchaseItems(uint256 smartObjectId, uint256 itemId, uint256 quantity) public {
    ItemTradeERC20Data memory ssuData = ItemTradeERC20.get(smartObjectId);
    require(ssuData.tokenAddress != address(0), "Invalid ERC20 Data");

    ItemPriceInTokenData memory itemPriceInTokenData = ItemPriceInToken.get(smartObjectId, itemId);
    require(itemPriceInTokenData.isSet, "Item price not set");

    uint256 tokenAmount = itemPriceInTokenData.price * quantity;

    // Transfer tokens from the msg.sender to the receiver
    IERC20(ssuData.tokenAddress).transferFrom(_msgSender(), ssuData.receiver, tokenAmount);

    EntityRecordTableData memory itemOutEntity = EntityRecordTable.get(itemId);

    if (!itemOutEntity.recordExists) {
      revert IInventoryErrors.Inventory_InvalidItem("ItemTrade: item not found on-chain", itemOutEntity.itemId);
    }

    InventoryItem[] memory outItems = new InventoryItem[](1);
    outItems[0] = InventoryItem(
      itemId,
      _msgSender(),
      itemOutEntity.itemId,
      itemOutEntity.typeId,
      itemOutEntity.volume,
      quantity
    );

    _inventoryLib().inventoryToEphemeralTransfer(smartObjectId, outItems);
  }

  /**
   * @dev Exchange items for ERC20 tokens based on the configured item multiples.
   * For example: if 99 Salt is configured to return 275 $EVE, exchanging in multiples of 99 Salt will result in $EVE tokens being transferred to the msg.sender.
   * @param smartObjectId The smart object id of the SSU
   * @param itemId The id of the item
   * @param quantity The quantity of the item to purchase
   */
  function sellItems(uint256 smartObjectId, uint256 itemId, uint256 quantity) public {
    // Get the token data for the item trade
    ItemTradeERC20Data memory ssuData = ItemTradeERC20.get(smartObjectId);
    require(ssuData.tokenAddress != address(0), "Invalid ERC20 Data");

    // Get the configured item multiple (e.g., 99 Salt) and verify it's set
    ItemQuantityMultipleForTokenData memory itemData = ItemQuantityMultipleForToken.get(smartObjectId, itemId);
    require(itemData.isSet, "Multiple not set");

    // Ensure the quantity is a multiple of the configured sellItemMultiple
    require(quantity >= itemData.enforcedItemMultiple, "Quantity less than minimum required multiple");

    // Calculate the largest multiple of the configured item multiple that can be processed
    uint256 multiplesToProcess = quantity / itemData.enforcedItemMultiple;

    // Total amount of tokens to transfer (e.g., for 99 Salt, transfer 275 $EVE)
    uint256 totalTokenAmount = multiplesToProcess * itemData.enforcedItemMultiple;

    uint256 itemPurchaseQuantity = 0;

    //purchase items only in the multiples of the enforcedItemMultiple, leave the rest in the SSU, ephemeral inventory of the player
    if (quantity % itemData.enforcedItemMultiple == 0) {
      itemPurchaseQuantity = multiplesToProcess * itemData.enforcedItemMultiple;
    } else {
      itemPurchaseQuantity = quantity - (multiplesToProcess % itemData.enforcedItemMultiple);
    }

    // Transfer from msg.sender to this contract and then from this contract to the receiver
    IERC20(ssuData.tokenAddress).transfer(_msgSender(), totalTokenAmount);

    EntityRecordTableData memory itemInEntity = EntityRecordTable.get(itemId);

    if (!itemInEntity.recordExists) {
      revert IInventoryErrors.Inventory_InvalidItem("ItemTrade: item not found on-chain", itemInEntity.itemId);
    }

    InventoryItem[] memory inItems = new InventoryItem[](1);

    inItems[0] = InventoryItem(
      itemId,
      _msgSender(),
      itemInEntity.itemId,
      itemInEntity.typeId,
      itemInEntity.volume,
      itemPurchaseQuantity
    );

    _inventoryLib().ephemeralToInventoryTransfer(smartObjectId, inItems);
  }

  /**
   * @dev Collect the ERC-20 tokens collected by the SSU
   * @param smartObjectId The smart object id of the SSU
   */
  function collectTokens(uint256 smartObjectId) public onlyOwner(smartObjectId) {
    ItemTradeERC20Data memory ssuData = ItemTradeERC20.get(smartObjectId);
    address tokenAddress = ssuData.tokenAddress;

    IERC20(tokenAddress).transfer(ssuData.receiver, IERC20(tokenAddress).balanceOf(address(this)));  }

  function getItemTradeContractAddress() public view returns (address) {
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
