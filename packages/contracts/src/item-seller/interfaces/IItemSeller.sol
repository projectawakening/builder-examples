// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { EntityRecordData, SmartObjectData, WorldPosition } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { ResourceId, WorldResourceIdLib, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";

interface IItemSeller {
  /**
   * @notice Creates and anchors an item seller with the given parameters.
   * @param smartObjectId The ID of the smart object.
   * @param entityRecordData The entity record data.
   * @param smartObjectData The smart object data.
   * @param worldPosition The world position data.
   * @param fuelUnitVolume The fuel unit volume.
   * @param fuelConsumptionPerMinute The fuel consumption per minute.
   * @param fuelMaxCapacity The maximum fuel capacity.
   * @param storageCapacity The storage capacity.
   * @param ephemeralStorageCapacity The ephemeral storage capacity.
   */
  function createAndAnchorItemSeller(
    uint256 smartObjectId,
    EntityRecordData memory entityRecordData,
    SmartObjectData memory smartObjectData,
    WorldPosition memory worldPosition,
    uint256 fuelUnitVolume,
    uint256 fuelConsumptionPerMinute,
    uint256 fuelMaxCapacity,
    uint256 storageCapacity,
    uint256 ephemeralStorageCapacity
  ) external;

  /**
   * @notice just tags an already existing SSU as an entityId
   * @param smartObjectId The smart object id
   */
  function associateSSUToItemSeller(uint256 smartObjectId) external;

  /**
   * @notice Sets the allow purchase status for a given smart object.
   * @param smartObjectId The ID of the smart object.
   * @param isAllowed The new purchase status (true to allow purchase, false to disallow).
   */
  function setAllowPurchase(uint256 smartObjectId, bool isAllowed) external;

  /**
   * @notice Sets the allow buyback status for a given smart object.
   * @param smartObjectId The ID of the smart object.
   * @param isAllowed The new buyback status (true to allow buyback, false to disallow).
   */
  function setAllowBuyback(uint256 smartObjectId, bool isAllowed) external;

  /**
   * @notice Sets the accepted item type ID for a seller in a given smart object.
   * @param smartObjectId The ID of the smart object.
   * @param entityTypeId The ID of the item type that is accepted by the seller.
   */
  function setItemSellerAcceptedItemTypeId(uint256 smartObjectId, uint256 entityTypeId) external;

  /**
   * @notice Sets the ERC20 purchase price for a given smart object.
   * @param smartObjectId The ID of the smart object.
   * @param purchasePriceWei The purchase price in wei.
   */
  function setERC20PurchasePrice(uint256 smartObjectId, uint256 purchasePriceWei) external;

  /**
   * @notice Sets the ERC20 buyback price for a given smart object.
   * @param smartObjectId The ID of the smart object.
   * @param buybackPriceWei The buyback price in wei.
   */
  function setERC20BuybackPrice(uint256 smartObjectId, uint256 buybackPriceWei) external;

  /**
   * @notice Sets the ERC20 currency address for a given smart object.
   * @param smartObjectId The ID of the smart object.
   * @param erc20Address The address of the ERC20 currency.
   */
  function setERC20Currency(uint256 smartObjectId, address erc20Address) external;

  /**
   * @notice Hook that is called when a seller deposits items to the inventory of a smart object.
   * @param smartObjectId The ID of the smart object.
   * @param items The list of inventory items being deposited.
   */
  function itemSellerDepositToInventoryHook(uint256 smartObjectId, InventoryItem[] memory items) external;

  /**
   * @notice Hook that is called when a seller deposits items to the inventory of a smart object.
   * @dev needs to be an AFTER hook because the ERC20 transfer needs to be done _after_ internal state changes
   * @param smartObjectId The ID of the smart object.
   * @param items The list of inventory items being deposited.
   */
  function itemSellerEphemeralToInventoryTransferHook(uint256 smartObjectId, InventoryItem[] memory items) external;

  /**
   * @notice Hook that is called when a seller withdraws items from the inventory of a smart object.
   * @param smartObjectId The ID of the smart object.
   * @param items The list of inventory items being withdrawn.
   */
  function itemSellerWithdrawFromInventoryHook(uint256 smartObjectId, InventoryItem[] memory items) external;

  /**
   * @notice Hook that is called when a seller withdraws items from the inventory of a smart object.
   * @dev _initialMsgSender() need to first call `IERC20.approve()` on this System's address
   * also, needs to be an AFTER hook because the ERC20 transfer needs to be done _after_ internal state changes
   * @param smartObjectId The ID of the smart object.
   * @param items The list of inventory items being withdrawn.
   */
  function itemSellerInventoryToEphemeralTransferHook(uint256 smartObjectId, InventoryItem[] memory items) external;
}
