import { getComponentValue } from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls({
  worldSend,
  txReduced$,
  singletonEntity,
}: SetupNetworkResult) {
  const joinGame = async () => {
    // @ts-ignore
    const tx = await worldSend("joinGame", []);
    console.log(tx.hash);
    await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
    // return getComponentValue(Counter, singletonEntity);
  };

  return {
    joinGame,
  };
}
