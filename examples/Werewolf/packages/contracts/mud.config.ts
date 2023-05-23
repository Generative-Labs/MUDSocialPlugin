import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  tables: {
    GameRounds: "uint32",
    Players: {
      schema: {
        players_id: "address",
        actor: "Actor",
        camp: "Camp",
        isDead: "bool",
      }
    },
    PlayersIDList: "address[]",
    GameStatus: "GameStatusEnum",
    DayStatus: "DayStatusEnum",
    Victim: "address",
    GroupChatID: "string",
    Creator: "address",
    FarmerCount: "uint256",
    WolfmanCount: "uint256",
    SYSTEM_MSG: "string",
    NickName: "string",
    DeadPlayersIDList: "address[]",
  },
  enums: {
    Actor: ["Farmer", "Wolfman"],
    Camp: ["Good", "Bad"],
    GameStatusEnum: ["UNSTART", "STARTED", "GAMEOVER"],
    DayStatusEnum: ["DAY", "NIGHT"],
  },
});
