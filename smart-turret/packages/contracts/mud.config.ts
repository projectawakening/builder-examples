import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "test",
  tables: {    
    TurretAllowlist: {
      schema: {
        corpID: "uint256"
      },
      key: [],
    }
  },
});