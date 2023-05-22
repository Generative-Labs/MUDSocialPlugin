import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  tables: {
    GameRounds: {
      keySchema: {},
      schema: "uint32",
    },
    Player: {
      keySchema: {},
      schema: {
        players_id: "address",
        isDead: "bool",
        actor: "Actor",
        camp: "Camp",
      }
    },
    GameStatus: {
      keySchema: {},
      schema: "string",
    },
    Victim: "address",
    GroupChatID: "string",
    PlayersIDList: "address[]",
  },
  enums: {
    Actor: ["Farmer", "Wolfman", "Oracle"],
    Camp: ["Good", "Bad"],
  }
});
