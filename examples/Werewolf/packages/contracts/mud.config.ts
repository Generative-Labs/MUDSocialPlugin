import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  tables: {},
  enums: {
    Actor: ["Farmer", "Wolfman", "Oracle"],
    Camp: ["Good", "Bad"],
  },
});
