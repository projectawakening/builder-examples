import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "access_control",
  excludeSystems: ["AccessControl"], // it is inherited by PermissionedSystem
  systems: {
    PermissionedSystem: {
      name: "PermissionedSyst",
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