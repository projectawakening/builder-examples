// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
import { console } from "forge-std/console.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM, RESOURCE_TABLE } from "@latticexyz/world/src/worldResourceTypes.sol";
import { IWorldKernel } from "@latticexyz/world/src/IWorldKernel.sol";
import { ResourceAccess } from "@latticexyz/world/src/codegen/tables/ResourceAccess.sol";

import { IERC721 } from "@eveworld/world/src/modules/eve-erc721-puppet/IERC721.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { DeployableTokenTable } from "@eveworld/world/src/codegen/tables/DeployableTokenTable.sol";

import { AccessRole, AccessRoleTableId } from "../codegen/index.sol";

import { IAccessControlErrors } from "../interfaces/IAccessControlErrors.sol";
import { ADMIN, APPROVED, NAMESPACE, EVE_WORLD_NAMESPACE, ACCESS_CONTROL_SYSTEM_NAME, ACCESS_ROLE_TABLE_NAME } from "../constants.sol";

contract AccessControl is System {
  using SmartDeployableUtils for bytes14;

  modifier onlyAdminRoleTxOrigin() {
    address[] memory accessListAdmin = AccessRole.get(ADMIN);
    bool access;
    for (uint256 i = 0; i < accessListAdmin.length; i++) {
      if (tx.origin == accessListAdmin[i]) {
        access = true;
        break;
      }
    }
    if (!access) {
      revert IAccessControlErrors.AccessControl_NoPermission(tx.origin, ADMIN);
    }
    _;
  }

  modifier onlyOwnerInitialMsgSender(uint256 smartObjectId) {
    if (IWorldKernel(_world()).initialMsgSender() != _getOwner(smartObjectId)) {
      revert IAccessControlErrors.AccessControl_NoPermission(IWorldKernel(_world()).initialMsgSender(), bytes32("OWNER"));
    }
    _;
  }

  modifier onlyApprovedRoleMsgSender() {
    address[] memory accessListApproved = AccessRole.get(APPROVED);
    bool access;
    for (uint256 i = 0; i < accessListApproved.length; i++) {
      if (_msgSender() == accessListApproved[i]) {
        access = true;
        break;
      }
    }
    if (!access) {
      revert IAccessControlErrors.AccessControl_NoPermission(_msgSender(), APPROVED);
    }
    _;
  }

  function setAccessListByRole(bytes32 accessRoleId, address[] memory accessList) public virtual {
      // we are reserving "OWNER" for the ERC721 owner accounts (ownership defined in the ERC721 tables, not here)
      if(accessRoleId == bytes32("OWNER")) {
        revert IAccessControlErrors.AccessControl_InvalidRoleId();
      }
      // only account granted access to the AccessRole table can sucessfully call this function
      if(!ResourceAccess.get(AccessRoleTableId, IWorldKernel(_world()).initialMsgSender())) {
        revert IAccessControlErrors.AccessControl_AccessRoleTableAccessDenied();
      }
      AccessRole.set(accessRoleId, accessList);
  }

  function _getOwner(uint256 smartObjectId) internal returns (address owner) {
    owner = IERC721(DeployableTokenTable.getErc721Address(EVE_WORLD_NAMESPACE.deployableTokenTableId())).ownerOf(
      smartObjectId
    );
  }
}