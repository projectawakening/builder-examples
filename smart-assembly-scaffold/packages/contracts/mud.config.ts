import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "example",
  tables: {
    ToggleTable: {
      schema: {
        smartObjectId: "uint256",
        isSet: "bool"
      },
      key: ["smartObjectId"],
    },
  },
});
