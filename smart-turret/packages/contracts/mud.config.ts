import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "red_dragon_t",
  tables: {    
    TurretAllowlist: {
      schema: {
        corpID: "uint256"
      },
      key: [],
    }
  },
});
