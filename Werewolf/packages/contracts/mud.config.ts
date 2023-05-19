import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  tables: {
    Counter: {
      keySchema: {},
      schema: "uint32",
    },
    Player: {
      keySchema: {},
      schema: {
        owner: "address",
        name: "string",
        color: "string",
      }
    }
  },
});
