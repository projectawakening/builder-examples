// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";
import { ResourceId, WorldResourceIdLib, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { RESOURCE_SYSTEM, RESOURCE_TABLE } from "@latticexyz/world/src/worldResourceTypes.sol";
import { EntityRecordTableData } from "@eveworld/world/src/codegen/tables/EntityRecordTable.sol";

import { EveSystem } from "@eveworld/smart-object-framework/src/systems/internal/EveSystem.sol";
import { ENTITY_RECORD_DEPLOYMENT_NAMESPACE, SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE, SMART_OBJECT_DEPLOYMENT_NAMESPACE, SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE, INVENTORY_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { SmartObjectLib } from "@eveworld/smart-object-framework/src/SmartObjectLib.sol";
import { SmartStorageUnitLib } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";

import { IItemSellerErrors } from "../IItemSellerErrors.sol";

import { DeployableTokenTable } from "@eveworld/world/src/codegen/tables/DeployableTokenTable.sol";
import { EntityTable } from "@eveworld/smart-object-framework/src/codegen/tables/EntityTable.sol";
import { EntityRecordData } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { EntityRecordTable } from "@eveworld/world/src/codegen/tables/EntityRecordTable.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";
import { LocationTableData } from "@eveworld/world/src/codegen/tables/LocationTable.sol";
import { InventoryTable } from "@eveworld/world/src/codegen/tables/InventoryTable.sol";
import { InventoryItemTable, InventoryItemTableData } from "@eveworld/world/src/codegen/tables/InventoryItemTable.sol";
import { ItemSellerTable } from "../../codegen/tables/ItemSellerTable.sol";

import { Utils as SmartObjectFrameworkUtils } from "@eveworld/smart-object-framework/src/utils.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { Utils as EntityRecordUtils } from "@eveworld/world/src/modules/entity-record/Utils.sol";
import { Utils as InventoryUtils } from "@eveworld/world/src/modules/inventory/Utils.sol";
import { Utils } from "../Utils.sol";

import { IERC721Mintable } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721Mintable.sol";
import { IERC20Mintable } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20Mintable.sol";

import { SmartObjectData, WorldPosition } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";

import { OBJECT, ITEM_SELLER_CLASS_ID } from "../constants.sol";

/**
 * @title Item Seller
 * @notice contains hook logic that modifies a vanilla SSU into a Item Seller, war-effort-style
 * users can only deposit a pre-determined kind of items in it, no withdrawals are allowed (transaction)
 */
contract ItemSeller is EveSystem, IItemSellerErrors {
  using WorldResourceIdInstance for ResourceId;
  using Utils for bytes14;
  using SmartObjectFrameworkUtils for bytes14;
  using SmartDeployableUtils for bytes14;
  using EntityRecordUtils for bytes14;
  using InventoryUtils for bytes14;
  using SmartObjectLib for SmartObjectLib.World;
  using SmartStorageUnitLib for SmartStorageUnitLib.World;

  modifier onlySSUOwner(uint256 smartObjectId) {
    if (
      _initialMsgSender() !=
      IERC721Mintable(DeployableTokenTable.getErc721Address(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE.deployableTokenTableId())).ownerOf(
        smartObjectId
      )
    ) {
      revert ItemSeller_NotSSUOwner(smartObjectId);
    }
    _;
  }

  /**
   * @notice Create and anchor a smart storage unit
   * @dev Create and anchor a smart storage unit by smart object id
   * @param smartObjectId The smart object id
   * @param entityRecordData The entity record data of the smart object
   * @param smartObjectData is the token metadata of the smart object
   * @param worldPosition The position of the smart object in the game
   * @param storageCapacity The storage capacity of the smart storage unit
   * @param ephemeralStorageCapacity The personal storage capacity of the smart storage unit
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
  ) public hookable(smartObjectId, _systemId()) {
    SmartStorageUnitLib
      .World(IBaseWorld(_world()), SMART_STORAGE_UNIT_DEPLOYMENT_NAMESPACE)
      .createAndAnchorSmartStorageUnit(
        smartObjectId,
        entityRecordData,
        smartObjectData,
        worldPosition,
        fuelUnitVolume,
        fuelConsumptionPerMinute,
        fuelMaxCapacity,
        storageCapacity,
        ephemeralStorageCapacity
      );
    if (EntityTable.getDoesExists(_namespace().entityTableTableId(), smartObjectId) == false) {
      // register smartObjectId as an object
      _smartObjectLib().registerEntity(smartObjectId, OBJECT);
    }
    SmartObjectLib.World(IBaseWorld(_world()), SMART_OBJECT_DEPLOYMENT_NAMESPACE).tagEntity(
      smartObjectId,
      ITEM_SELLER_CLASS_ID
    );
  }

  /**
   * @notice just tags an already existing SSU as an entityId
   * @param smartObjectId The smart object id
   */
  function associateSSUToItemSeller(uint256 smartObjectId) public onlySSUOwner(smartObjectId) hookable(smartObjectId, _systemId()) {
    if (EntityTable.getDoesExists(_namespace().entityTableTableId(), smartObjectId) == false) {
      // register smartObjectId as an object
      _smartObjectLib().registerEntity(smartObjectId, OBJECT);
    }
    SmartObjectLib.World(IBaseWorld(_world()), SMART_OBJECT_DEPLOYMENT_NAMESPACE).tagEntity(
      smartObjectId,
      ITEM_SELLER_CLASS_ID
    );
  }

  /**
   * @notice Sets the accepted item type ID for a seller in a given smart object.
   * @param smartObjectId The ID of the smart object.
   * @param entityTypeId The ID of the item type that is accepted by the seller.
   */
  function setItemSellerAcceptedItemTypeId(
    uint256 smartObjectId,
    uint256 entityTypeId
  ) public onlySSUOwner(smartObjectId) hookable(smartObjectId, _systemId()) {
    ItemSellerTable.setAcceptedItemTypeId(_namespace().itemSellerTableId(), smartObjectId, entityTypeId);
  }

  /**
   * @notice Sets the allow purchase status for a given smart object.
   * @param smartObjectId The ID of the smart object.
   * @param isAllowed The new purchase status (true to allow purchase, false to disallow).
   */
  function setAllowPurchase(
    uint256 smartObjectId,
    bool isAllowed
  ) public onlySSUOwner(smartObjectId) hookable(smartObjectId, _systemId()) {
    ItemSellerTable.setIsPurchaseAllowed(_namespace().itemSellerTableId(), smartObjectId, isAllowed);
  }

  /**
   * @notice Sets the allow buyback status for a given smart object.
   * @param smartObjectId The ID of the smart object.
   * @param isAllowed The new buyback status (true to allow buyback, false to disallow).
   */
  function setAllowBuyback(
    uint256 smartObjectId,
    bool isAllowed
  ) public onlySSUOwner(smartObjectId) hookable(smartObjectId, _systemId()) {
    ItemSellerTable.setIsBuybackAllowed(_namespace().itemSellerTableId(), smartObjectId, isAllowed);
  }

  /**
   * @notice Sets the ERC20 purchase price for a given smart object.
   * @param smartObjectId The ID of the smart object.
   * @param purchasePriceInWei The target item quantity for the purchase price.
   */
  function setERC20PurchasePrice(
    uint256 smartObjectId,
    uint256 purchasePriceInWei
  ) public onlySSUOwner(smartObjectId) hookable(smartObjectId, _systemId()) {
    ItemSellerTable.setErc20PurchasePriceWei(_namespace().itemSellerTableId(), smartObjectId, purchasePriceInWei);
  }

  /**
   * @notice Sets the ERC20 buyback price for a given smart object.
   * @param smartObjectId The ID of the smart object.
   * @param buybackPriceInWei The target item quantity for the buyback price.
   */
  function setERC20BuybackPrice(
    uint256 smartObjectId,
    uint256 buybackPriceInWei
  ) public onlySSUOwner(smartObjectId) hookable(smartObjectId, _systemId()) {
    ItemSellerTable.setErc20BuybackPriceWei(_namespace().itemSellerTableId(), smartObjectId, buybackPriceInWei);
  }

  /**
   * @notice Sets the ERC20 currency address for a given smart object.
   * @param smartObjectId The ID of the smart object.
   * @param erc20Address The address of the ERC20 currency.
   */
  function setERC20Currency(
    uint256 smartObjectId,
    address erc20Address
  ) public onlySSUOwner(smartObjectId) hookable(smartObjectId, _systemId()) {
    ItemSellerTable.setErc20Address(_namespace().itemSellerTableId(), smartObjectId, erc20Address);
  }

  /**
   * @notice Hook that is called when a seller deposits items to the inventory of a smart object.
   * @dev The SSU owner needs to `approve` this system's address to enable the item buyback feature (makes an `ERC20.transferFrom()` from him)
   * Also, needs to be an AFTER hook because the ERC20 transfer needs to be done _after_ internal state changes
   * @param smartObjectId The ID of the smart object.
   * @param items The list of inventory items being deposited.
   */
  function itemSellerDepositToInventoryHook(
    uint256 smartObjectId,
    InventoryItem[] memory items
  ) public hookable(smartObjectId, _systemId()) {
    if (!ItemSellerTable.getIsBuybackAllowed(_namespace().itemSellerTableId(), smartObjectId)) {
      revert ItemSeller_BuybackPriceNotSet(smartObjectId);
    }
    // TODO: perhaps double check the hook is only applied once and the InventoryInteract version is not present either to prevent double spend
    uint256 totalQuantity = _getTypeIdQuantity(smartObjectId, items);
    uint256 priceWei = ItemSellerTable.getErc20BuybackPriceWei(_namespace().itemSellerTableId(), smartObjectId) *
      totalQuantity;
    address erc20Address = ItemSellerTable.getErc20Address(_namespace().itemSellerTableId(), smartObjectId);
    // sending ERC20 from this contract to the user initiating the transfer
    address ssuOwner = IERC721Mintable(DeployableTokenTable.getErc721Address(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE.deployableTokenTableId()))
      .ownerOf(smartObjectId);
    IERC20Mintable(erc20Address).transferFrom(ssuOwner, _initialMsgSender(), priceWei);
  }

  /**
   * @notice Hook that is called when a seller deposits items to the inventory of a smart object.
   * @dev The SSU owner needs to `approve` this system's address to enable the item buyback feature (makes an `ERC20.transferFrom()` from him)
   * needs to be an AFTER hook because the ERC20 transfer needs to be done _after_ internal state changes
   * @param smartObjectId The ID of the smart object.
   * @param items The list of inventory items being deposited.
   */
  function itemSellerEphemeralToInventoryTransferHook(
    uint256 smartObjectId,
    InventoryItem[] memory items
  ) public hookable(smartObjectId, _systemId()) {
    if (!ItemSellerTable.getIsBuybackAllowed(_namespace().itemSellerTableId(), smartObjectId)) {
      revert ItemSeller_BuybackPriceNotSet(smartObjectId);
    }
    // TODO: perhaps double check the hook is only applied once and the InventoryInteract version is not present either to prevent double spend
    uint256 totalQuantity = _getTypeIdQuantity(smartObjectId, items);
    uint256 priceWei = ItemSellerTable.getErc20BuybackPriceWei(_namespace().itemSellerTableId(), smartObjectId) *
      totalQuantity;
    address erc20Address = ItemSellerTable.getErc20Address(_namespace().itemSellerTableId(), smartObjectId);
    // sending ERC20 from this contract to the user initiating the transfer
    address ssuOwner = IERC721Mintable(DeployableTokenTable.getErc721Address(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE.deployableTokenTableId()))
      .ownerOf(smartObjectId);
    IERC20Mintable(erc20Address).transferFrom(ssuOwner, _initialMsgSender(), priceWei);
  }

  /**
   * @notice Hook that is called when a seller withdraws items from the inventory of a smart object.
   * @dev _initialMsgSender() need to first call `IERC20.approve()` on this System's address
   * also, needs to be an AFTER hook because the ERC20 transfer needs to be done _after_ internal state changes
   * @param smartObjectId The ID of the smart object.
   * @param items The list of inventory items being withdrawn.
   */
  function itemSellerWithdrawFromInventoryHook(
    uint256 smartObjectId,
    InventoryItem[] memory items
  ) public hookable(smartObjectId, _systemId()) {
    if (!ItemSellerTable.getIsPurchaseAllowed(_namespace().itemSellerTableId(), smartObjectId)) {
      revert ItemSeller_PurchasePriceNotSet(smartObjectId);
    }
    // TODO: perhaps double check the hook is only applied once and the InventoryInteract version is not present either to prevent double spend
    uint256 totalQuantity = _getTypeIdQuantity(smartObjectId, items);
    uint256 priceWei = ItemSellerTable.getErc20PurchasePriceWei(_namespace().itemSellerTableId(), smartObjectId) *
      totalQuantity;
    address erc20Address = ItemSellerTable.getErc20Address(_namespace().itemSellerTableId(), smartObjectId);
    address ssuOwner = IERC721Mintable(DeployableTokenTable.getErc721Address(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE.deployableTokenTableId()))
      .ownerOf(smartObjectId);
    IERC20Mintable(erc20Address).transferFrom(_initialMsgSender(), ssuOwner, priceWei);
  }

  /**
   * @notice Hook that is called when a seller withdraws items from the inventory of a smart object.
   * @dev _initialMsgSender() need to first call `IERC20.approve()` on this System's address
   * also, needs to be an AFTER hook because the ERC20 transfer needs to be done _after_ internal state changes
   * @param smartObjectId The ID of the smart object.
   * @param items The list of inventory items being withdrawn.
   */
  function itemSellerInventoryToEphemeralTransferHook(
    uint256 smartObjectId,
    InventoryItem[] memory items
  ) public hookable(smartObjectId, _systemId()) {
    if (!ItemSellerTable.getIsPurchaseAllowed(_namespace().itemSellerTableId(), smartObjectId)) {
      revert ItemSeller_PurchasePriceNotSet(smartObjectId);
    }
    // TODO: perhaps double check the hook is only applied once and the InventoryInteract version is not present either to prevent double spend
    uint256 totalQuantity = _getTypeIdQuantity(smartObjectId, items);
    uint256 priceWei = ItemSellerTable.getErc20PurchasePriceWei(_namespace().itemSellerTableId(), smartObjectId) *
      totalQuantity;
    address erc20Address = ItemSellerTable.getErc20Address(_namespace().itemSellerTableId(), smartObjectId);
    address ssuOwner = IERC721Mintable(DeployableTokenTable.getErc721Address(SMART_DEPLOYABLE_DEPLOYMENT_NAMESPACE.deployableTokenTableId()))
      .ownerOf(smartObjectId);
    IERC20Mintable(erc20Address).transferFrom(_initialMsgSender(), ssuOwner, priceWei);
  }

  function _getTypeIdQuantity(
    uint256 smartObjectId,
    InventoryItem[] memory items
  ) internal view returns (uint256 quantity) {
    uint256 acceptedTypeId = ItemSellerTable.getAcceptedItemTypeId(_namespace().itemSellerTableId(), smartObjectId);
    uint256 totalQuantity = 0;
    for (uint i = 0; i < items.length; i++) {
      uint256 itemTypeId = EntityRecordTable.getTypeId(
        ENTITY_RECORD_DEPLOYMENT_NAMESPACE.entityRecordTableId(),
        items[i].inventoryItemId
      );
      if (itemTypeId != acceptedTypeId) revert ItemSeller_WrongWithdrawType(acceptedTypeId, items[i].inventoryItemId);
      else {
        totalQuantity += InventoryItemTable.getQuantity(
          INVENTORY_DEPLOYMENT_NAMESPACE.inventoryItemTableId(),
          smartObjectId,
          items[i].inventoryItemId
        );
      }
    }
  }

  function _smartObjectLib() internal view returns (SmartObjectLib.World memory) {
    return SmartObjectLib.World({ iface: IBaseWorld(_world()), namespace: SMART_OBJECT_DEPLOYMENT_NAMESPACE });
  }

  function _systemId() internal view returns (ResourceId) {
    return _namespace().itemSellerSystemId();
  }
}
