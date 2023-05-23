import { getComponentValue } from "@latticexyz/recs";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";
import keccak256 from "keccak256";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { worldSend, txReduced$ }: SetupNetworkResult,
  {
    SYSTEM_MSG,
    Players,
    GameStatus,
    DayStatus,
    GroupChatID,
    Victim,
    GameRounds,
    PlayersIDList,
  }: ClientComponents
) {
  const joinGame = async (nickname: string) => {
    return  await worldSend("joinGame", [nickname]);
  };

  const getPlayerInfo = async (address: string) => {
    const tx = await worldSend("getPlayerInfo", [address]);
    //@ts-ignore
    return getComponentValue(Players, address);
  };

  const getEntityFromStr = (str: string) => {
    return "0x" + keccak256(str).toString("hex");
  };
  const getGroupId = async (isPrivate: boolean = false) => {
    const tx = await worldSend("getGroupChatID", [isPrivate]);
    const str = isPrivate ? "privateGroupChatID" : "GroupChatID";
    const hex = getEntityFromStr(str);
    //@ts-ignore
    return getComponentValue(GroupChatID, hex);
  };

  const beginGame = async () => {
    return await worldSend("startGame", []);
  };

  const setGroupId = async (value: string, isPrivate: boolean = false) => {
    return  await worldSend("setGroupChatID", [value, isPrivate]);
  };
  const killPeople = async (address: string) => {
     return await worldSend("chooseVictim", [address]);
  };

  const restartGame = async () => {
    await worldSend("initGameData", [])
  }


  return {
    joinGame,
    SYSTEM_MSG,
    Players,
    GameStatus,
    DayStatus,
    Victim,
    GroupChatID,
    setGroupId,
    getPlayerInfo,
    getGroupId,
    PlayersIDList,
    GameRounds,
    beginGame,
    restartGame,
    killPeople
  };
}
