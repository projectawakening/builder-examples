// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { EntityRecordData, SmartObjectData, WorldPosition } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { ResourceId, WorldResourceIdLib, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { IItemSeller } from "./interfaces/IItemSeller.sol";
import { Utils } from "./Utils.sol";

/**
 * @title ItemSeller Library (makes interacting with the underlying Systems cleaner)
 * Works similarly to direct calls to world, without having to deal with dynamic method's function selectors due to namespacing.
 * @dev To preserve _msgSender() and other context-dependent properties, Library methods like those MUST be `internal`.
 * That way, the compiler is forced to inline the method's implementation in the contract they're imported into.
 */
library ItemSellerLib {
  using Utils for bytes14;

  struct World {
    IBaseWorld iface;
    bytes14 namespace;
  }

  /**
   * @notice Creates and anchors an item seller with the given parameters.
   * @param world The world state.
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
    World memory world,
    uint256 smartObjectId,
    EntityRecordData memory entityRecordData,
    SmartObjectData memory smartObjectData,
    WorldPosition memory worldPosition,
    uint256 fuelUnitVolume,
    uint256 fuelConsumptionPerMinute,
    uint256 fuelMaxCapacity,
    uint256 storageCapacity,
    uint256 ephemeralStorageCapacity
  ) internal {
    world.iface.call(
      world.namespace.itemSellerSystemId(),
      abi.encodeCall(
        IItemSeller.createAndAnchorItemSeller,
        (
          smartObjectId,
          entityRecordData,
          smartObjectData,
          worldPosition,
          fuelUnitVolume,
          fuelConsumptionPerMinute,
          fuelMaxCapacity,
          storageCapacity,
          ephemeralStorageCapacity
        )
      )
    );
  }

  /**
   * @notice Sets the allow purchase status for a given smart object.
   * @param world The world state.
   * @param smartObjectId The ID of the smart object.
   * @param isAllowed The new purchase status (true to allow purchase, false to disallow).
   */
  function setAllowPurchase(World memory world, uint256 smartObjectId, bool isAllowed) internal {
    world.iface.call(
      world.namespace.itemSellerSystemId(),
      abi.encodeCall(IItemSeller.setAllowPurchase, (smartObjectId, isAllowed))
    );
  }

  /**
   * @notice Sets the allow buyback status for a given smart object.
   * @param world The world state.
   * @param smartObjectId The ID of the smart object.
   * @param isAllowed The new buyback status (true to allow buyback, false to disallow).
   */
  function setAllowBuyback(World memory world, uint256 smartObjectId, bool isAllowed) internal {
    world.iface.call(
      world.namespace.itemSellerSystemId(),
      abi.encodeCall(IItemSeller.setAllowBuyback, (smartObjectId, isAllowed))
    );
  }

  /**
   * @notice Sets the accepted item type ID for a seller in a given smart object.
   * @param world The world state.
   * @param smartObjectId The ID of the smart object.
   * @param entityTypeId The ID of the item type that is accepted by the seller.
   */
  function setItemSellerAcceptedItemTypeId(World memory world, uint256 smartObjectId, uint256 entityTypeId) internal {
    world.iface.call(
      world.namespace.itemSellerSystemId(),
      abi.encodeCall(IItemSeller.setItemSellerAcceptedItemTypeId, (smartObjectId, entityTypeId))
    );
  }

  /**
   * @notice Sets the ERC20 purchase price for a given smart object.
   * @param world The world state.
   * @param smartObjectId The ID of the smart object.
   * @param purchasePriceWei The purchase price in wei.
   */
  function setERC20PurchasePrice(World memory world, uint256 smartObjectId, uint256 purchasePriceWei) internal {
    world.iface.call(
      world.namespace.itemSellerSystemId(),
      abi.encodeCall(IItemSeller.setERC20PurchasePrice, (smartObjectId, purchasePriceWei))
    );
  }

  /**
   * @notice Sets the ERC20 buyback price for a given smart object.
   * @param world The world state.
   * @param smartObjectId The ID of the smart object.
   * @param buybackPriceWei The buyback price in wei.
   */
  function setERC20BuybackPrice(World memory world, uint256 smartObjectId, uint256 buybackPriceWei) internal {
    world.iface.call(
      world.namespace.itemSellerSystemId(),
      abi.encodeCall(IItemSeller.setERC20BuybackPrice, (smartObjectId, buybackPriceWei))
    );
  }

  /**
   * @notice Sets the ERC20 currency address for a given smart object.
   * @param world The world state.
   * @param smartObjectId The ID of the smart object.
   * @param erc20Address The address of the ERC20 currency.
   */
  function setERC20Currency(World memory world, uint256 smartObjectId, address erc20Address) internal {
    world.iface.call(
      world.namespace.itemSellerSystemId(),
      abi.encodeCall(IItemSeller.setERC20Currency, (smartObjectId, erc20Address))
    );
  }
}
