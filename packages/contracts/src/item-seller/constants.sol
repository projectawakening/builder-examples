// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { RESOURCE_NAMESPACE } from "@latticexyz/world/src/worldResourceTypes.sol";

bytes14 constant ITEM_SELLER_DEPLOYMENT_NAMESPACE = "eveworld";

bytes16 constant ITEM_SELLER_MODULE_NAME = "ItemSeller";
bytes14 constant ITEM_SELLER_MODULE_NAMESPACE = "ItemSeller";

bytes16 constant ITEM_SELLER_TABLE_NAME = "ItemSellerTable";

uint8 constant OBJECT = 1;
uint8 constant CLASS = 2;

uint256 constant ITEM_SELLER_CLASS_ID = 5678;
