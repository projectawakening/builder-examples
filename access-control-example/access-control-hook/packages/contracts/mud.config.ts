import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "access_control",
  systems: {
    AccessControlHook: {
      name: "AccessControlHoo",
      openAccess: true,
    },
    PermissionedSystem: {
      name: "PermissionedSyst",
      openAccess: true,
    },
    UnapprovedForwarderSystem:{
      name: "UnapprovedForwarderSystem",
      openAccess: true,
    },
    ForwarderSystem: {
      name: "ForwarderSystem",
      openAccess: true,
    },
  },
  tables: {
    AccessRole: {
      keySchema: { roleId: "bytes32" },
      valueSchema: {
        accounts: "address[]",
      },
    },
  },
});