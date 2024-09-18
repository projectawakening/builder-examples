import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "test2",
  systems: {
    SmartTurret: {
      name: "SmartTurret",
      openAccess: true,
    },
  },
  tables: {
  }
});
