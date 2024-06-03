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

import { IAccessControlHookErrors } from "../interfaces/IAccessControlHookErrors.sol";
import { ADMIN, APPROVED, NAMESPACE, EVE_WORLD_NAMESPACE, ACCESS_CONTROL_HOOK_SYSTEM_NAME, ACCESS_ROLE_TABLE_NAME } from "../constants.sol";

contract AccessControlHook is System {
  using SmartDeployableUtils for bytes14;

  // System ID
  ResourceId ACCESS_CONTROL_HOOK_SYSTEM_ID = WorldResourceIdLib.encode({
        typeId: RESOURCE_SYSTEM,
        namespace: NAMESPACE,
        name: ACCESS_CONTROL_HOOK_SYSTEM_NAME
      });

  function onlyAdminRoleTxOrigin(uint256 smartObjectId) public {
    address[] memory accessListAdmin = AccessRole.get(ADMIN);
    bool access;
    for (uint256 i = 0; i < accessListAdmin.length; i++) {
      if (tx.origin == accessListAdmin[i]) {
        access = true;
        break;
      }
    }
    if (!access) {
      revert IAccessControlHookErrors.AccessControl_NoPermission(tx.origin, ADMIN);
    }
  }

  function onlyOwnerInitialMsgSender(uint256 smartObjectId) public {
    if (IWorldKernel(_world()).initialMsgSender() != _getOwner(smartObjectId)) {
      revert IAccessControlHookErrors.AccessControl_NoPermission(IWorldKernel(_world()).initialMsgSender(), bytes32("OWNER"));
    }
  }

  function onlyApprovedRoleForwardedMsgSender(uint256 smartObjectId) public {
      address[] memory accessListApproved = AccessRole.get(APPROVED);
      address forwardedMsgSender = getStoredAddress(smartObjectId);
      bool access;
      for (uint256 i = 0; i < accessListApproved.length; i++) {
        if (forwardedMsgSender == accessListApproved[i]) {
          access = true;
          break;
        }
      }
      if (!access) {
        revert IAccessControlHookErrors.AccessControl_NoPermission(forwardedMsgSender, APPROVED);
      }
  }

  // based on the `hookable()` implementation, hook executions are always called from their target System. This means that MUD's _msgSender() will always return the target System's address inside of a hook execution
  // So this hook should be added to the function of a forwarding System call, then that forwarder System's address can be picked up and used later down the execution path by using getStoredAddress()
  // NOTE: the stored address in transient storage will be overwritten if storeSystemAddress() is hooked to more than one forwarding System per transaction execution which invloves `smartObjectId`, so be mindful, re-entrancy I'm looking at you
  // NOTE2: the storeSystemAddress/getStoredAddress pattern is a workaround, we are in the process of updating hookable() so that the target's msg.sender is automatically captured and passed to the hook, making this pattern obsolete
  function storeSystemAddress(uint256 smartObjectId) public {
        bytes32 targetSystemAddress = bytes32(uint256(uint160(_msgSender())));
        bytes32 slot = bytes32(smartObjectId);
        assembly {
          // Store msg.sender in transient storage
          tstore(slot, targetSystemAddress)
        }
  }
  
  function getStoredAddress(uint256 smartObjectId) public returns (address) {
      bytes32 slot = bytes32(smartObjectId);

      // retreive any stored forwarder address data for the target System/function
      bytes32 storedForwarderAddress;
      assembly {
        storedForwarderAddress := tload(slot)
      }
    return address(uint160(uint256(storedForwarderAddress)));
  }

  function setAccessListByRole(bytes32 accessRoleId, address[] memory accessList) public {
      // we are reserving "OWNER" for the ERC721 owner accounts (access defined in the ERC721 tables, not here)
      if(accessRoleId == bytes32("OWNER")) {
        revert IAccessControlHookErrors.AccessControl_InvalidRoleId();
      }
      // only account granted access to the AccessRole table can sucessfully call this function
      if(!ResourceAccess.get(AccessRoleTableId, IWorldKernel(_world()).initialMsgSender())) {
        revert IAccessControlHookErrors.AccessControl_AccessRoleTableAccessDenied();
      }
      AccessRole.set(accessRoleId, accessList);
  }

  function _getOwner(uint256 smartObjectId) internal returns (address owner) {
    owner = IERC721(DeployableTokenTable.getErc721Address(EVE_WORLD_NAMESPACE.deployableTokenTableId())).ownerOf(
      smartObjectId
    );
  }

  function _systemId() internal view returns (ResourceId) {
    return ACCESS_CONTROL_HOOK_SYSTEM_ID;
  }

}