// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

// Namespace name - must be unique in the world, must be bytes14 or less in length, must match the value provided to the mud.config.ts "namespace" field
// You can deploy to a previous Namespace if your deployer account is that Namespace's owner @latticexyz/world/src/codegen/tables/NamespaceOwner.sol
// Otherwise you can deploy to a new namespace.
// NOTE: for live deployments if some else has already deployed to that Namespace, your deployment will fail
bytes14 constant NAMESPACE = "access_control";

// System Names - must be unique per Namespace, must match one of the System names provided to the mud.config.ts file
// standard convention is to use the first 16 characters of the System contract name
bytes16 constant ACCESS_CONTROL_HOOK_SYSTEM_NAME = "AccessControlHoo";

// Table Names - must be unique per Namespace, must match one of the Table names provided to the mud.config.ts file
bytes16 constant ACCESS_ROLE_TABLE_NAME = "AccessRole";

// the namespace of the EVE World and modules (for interaction)
bytes14 constant EVE_WORLD_NAMESPACE = "eveworld";

// AccessControl AccessRole constants
bytes32 constant ADMIN = bytes32("ADMIN_ACCESS_ROLE");
bytes32 constant APPROVED = bytes32("APPROVED_ACCESS_ROLE");