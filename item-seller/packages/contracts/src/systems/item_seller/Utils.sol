//SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";

import { ITEM_SELLER_DEPLOYMENT_NAMESPACE, ITEM_SELLER_SYSTEM_NAME } from "./constants.sol";

library Utils {
  function itemSellerSystemId() internal pure returns (ResourceId) {
    return
      WorldResourceIdLib.encode({
        typeId: RESOURCE_SYSTEM,
        namespace: ITEM_SELLER_DEPLOYMENT_NAMESPACE,
        name: ITEM_SELLER_SYSTEM_NAME
      });
  }
}
