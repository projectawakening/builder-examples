import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "test",
  tables: {    
    TurretAllowlist: {
      schema: {
        corpID: "uint256"
      },
      key: [],
    },
    SeenTargets: {
      schema: {
        target: "uint256",
        timestamp: "uint256"
      },
      key: ["target"]
    }
  },
});