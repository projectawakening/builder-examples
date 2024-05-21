//SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM, RESOURCE_TABLE } from "@latticexyz/world/src/worldResourceTypes.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";

import { ITEM_SELLER_TABLE_NAME } from "./constants.sol";

// clash with a version of npm that doesnt exist yet
bytes16 constant ITEM_SELLER_SYSTEM_NAME = "ItemSeller";

library Utils {
  function itemSellerTableId(bytes14 namespace) internal pure returns (ResourceId) {
    return WorldResourceIdLib.encode({ typeId: RESOURCE_TABLE, namespace: namespace, name: ITEM_SELLER_TABLE_NAME });
  }

  function itemSellerSystemId(bytes14 namespace) internal pure returns (ResourceId) {
    return WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: namespace, name: ITEM_SELLER_SYSTEM_NAME });
  }
}
