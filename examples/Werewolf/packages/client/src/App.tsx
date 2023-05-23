import { useMUD } from "./MUDContext";
import { getBurnerWallet } from "@latticexyz/std-client";
import useLogin from "./hooks/useWeb3MQ";
import React, { useEffect, useState } from "react";
import { Client } from "@web3mq/client";
import {
  AppTypeEnum,
  Button,
  Channel,
  ChannelList,
  Chat,
  ConnectMessage,
  Main,
  MessageConsole,
  MessageInput,
  MessageList,
  Modal,
  Window,
  toast,
} from "@web3mq/react-components";
import "@web3mq/react-components/dist/css/index.css";
import ss from "./index.module.css";
import MsgInput from "./components/MsgInput";
import ChannelHeader from "./components/ChannelHeader";
import { LoginBgcIcon, RoomAvatarIcon } from "./icons";

enum Actor {
  Farmer,
  Wolfman,
}

enum GameStatusEnum {
  UNSTART,
  STARTED,
  GAMEOVER,
}

enum DayStatusEnum {
  DAY,
  NIGHT,
}

export const App = () => {
  const {
    systemCalls: {
      joinGame,
      SYSTEM_MSG,
      GameStatus,
      DayStatus,
      setGroupId,
      getGroupId,
      getPlayerInfo,
      PlayersIDList,
      GameRounds,
      beginGame,
      restartGame,
      killPeople,
    },
    network: { playerEntity },
  } = useMUD();
  const pk = getBurnerWallet().value;
  const { keys, fastestUrl, init, connectWeb3MQNetwork } = useLogin(pk);

  const [showVote, setShowVote] = useState(false);
  const [disableInput, setDisableInput] = useState(false);
  const [systemMsg, setSystemMsg] = useState("");
  const [gameStatus, setGameStatus] = useState<GameStatusEnum>(
    GameStatusEnum.UNSTART
  );
  const [dayStatus, setDayStatus] = useState<DayStatusEnum>();
  const [nickName, setNickName] = useState("");
  const [playersCount, setPlayersCount] = useState(0);
  const [gameRuns, setGameRuns] = useState(0);
  const [showModal, setShowModal] = useState(false);
  const [memberList, setMemberList] = useState([]);
  const [isDead, setIsDead] = useState(false);
  const [stateChannelList, setStateChannelList] = useState<any>([]);

  useEffect(() => {
    SYSTEM_MSG.update$.subscribe((update) => {
      const [nextValue, prevValue] = update.value;
      setSystemMsg(nextValue?.value || "error message");
    });
    GameStatus.update$.subscribe((update) => {
      const [nextValue, prevValue] = update.value;
      setGameStatus(
        (nextValue?.value as GameStatusEnum) || GameStatusEnum.UNSTART
      );
    });
    GameRounds.update$.subscribe((update) => {
      const [nextValue, prevValue] = update.value;
      setGameRuns(nextValue?.value || 0);
    });
    PlayersIDList.update$.subscribe((update) => {
      const [nextValue, prevValue] = update.value;
      setPlayersCount(nextValue?.value.length || 0);
    });
    DayStatus.update$.subscribe((update) => {
      const [nextValue, prevValue] = update.value;
      setDayStatus(nextValue?.value);
    });
    init();
    document.body.setAttribute("data-theme", "light");
  }, []);
  useEffect(() => {
    toast(systemMsg);
  }, [systemMsg]);

  useEffect(() => {
    try {
      onGameStatusChange();
    } catch (e) {}
  }, [gameRuns, gameStatus, dayStatus, stateChannelList]);
  const connectAndJoinGame = async () => {
    if (!nickName) {
      alert("Please enter your nickname");
      return;
    }
    await connectWeb3MQNetwork(nickName);
    await joinGame(nickName);
  };

  if (!keys || !fastestUrl) {
    return (
      <div className={ss.login_container}>
        <div className={ss.testBgc}>
          <LoginBgcIcon />
        </div>
        <div className={ss.connectBtnBox}>
          <div>
            <input
              className={ss.nicknameInput}
              value={nickName}
              onChange={(e) => setNickName(e.target.value)}
              placeholder={"Enter your nickname"}
            />
          </div>
          <Button
            type={"primary"}
            className={ss.walletConnectBtn}
            disabled={!fastestUrl || !nickName}
            onClick={connectAndJoinGame}
          >
            {fastestUrl ? "Connect" : "Initializing"}
          </Button>
        </div>
      </div>
    );
  }
  const client = Client.getInstance(keys);

  const handleEvent = async (event: any) => {
    const { type } = event;
    if (type === "channel.getList") {
      const { channelList } = client.channel;
      setStateChannelList(channelList);
    }
    if (type === "message.send") {
      const { messageList } = client.message;
      let messageObj = undefined;
      let senderId = "";
      try {
        //@ts-ignore
        const newMessage = messageList[messageList.length - 1];
        //@ts-ignore
        const { content } = newMessage;
        //@ts-ignore
        senderId = newMessage?.senderId || "";
        messageObj = JSON.parse(content);
      } catch (e) {}
      if (
        messageObj &&
        messageObj.messageType === "werewolf_notify" &&
        messageObj.content
      ) {
        setDisableInput(false);
      } else {
        // isWolf
        const address = localStorage.getItem("WALLET_ADDRESS") || "";
        const playerInfo = await getPlayerInfo(address);
        if (playerInfo?.isDead && senderId === keys.userid) {
          setIsDead(true);
        }

        if (playerInfo?.actor === Actor.Wolfman) {
        } else {
          setDisableInput(true);
        }
      }
    }
  };

  client.on("message.getList", handleEvent);
  client.on("message.send", handleEvent);
  client.on("message.delivered", handleEvent);
  client.on("connect.changeReadyStatus", handleEvent);
  client.on("message.delivered", handleEvent);
  client.on("channel.getList", handleEvent);
  client.on("channel.activeChange", handleEvent);
  client.on("channel.updated", handleEvent);

  const joinGameAndReady = async () => {
    const groupId = await getGroupId();
    const publicGroupId = groupId?.value || "";
    const privateGroup = await getGroupId(true);
    const address = localStorage.getItem("WALLET_ADDRESS") || "";
    const playerInfo = await getPlayerInfo(address);
    if (playerInfo?.actor === Actor.Wolfman) {
      const privateExist = stateChannelList?.filter(
        (item: any) => item.chatid === privateGroup?.value
      );
      if (!privateExist || privateExist.length === 0) {
        if (!privateGroup || !privateGroup.value) {
          await client.channel.createRoom({
            groupName: "Werewolf-Wolfman",
            permissions: {
              "group:join": {
                type: "enum",
                value: "public",
              },
            },
          });
          const { channelList } = client.channel;
          if (channelList && channelList[0]) {
            await setGroupId(channelList[0].chatid, true);
          }
        } else {
          await client.channel.joinGroup(privateGroup.value);
        }
      }
    }
    const publicExist = stateChannelList?.filter(
      (item: any) => item.chatid === publicGroupId
    );
    if (!publicExist || publicExist.length === 0) {
      if (!groupId || !groupId.value) {
        await client.channel.createRoom({
          groupName: "Werewolf-Public",
          permissions: {
            "group:join": {
              type: "enum",
              value: "public",
            },
          },
        });
        const { channelList } = client.channel;
        if (channelList && channelList[0]) {
          await setGroupId(channelList[0].chatid);
        }
      } else {
        await client.channel.joinGroup(groupId.value);
      }
    }

    await client.channel.queryChannels({
      page: 1,
      size: 10,
    });
  };

  const sendNotify = async (msg: string) => {
    const notify = JSON.stringify({
      content: msg,
      messageType: "werewolf_notify",
    });
    await client.message.sendMessage(notify);
  };
  const onGameStatusChange = async () => {
    const { channelList } = client.channel;
    const groupId = await getGroupId();
    const publicGroupId = groupId?.value || "";
    const address = localStorage.getItem("WALLET_ADDRESS") || "";
    const playerInfo = await getPlayerInfo(address);
    if (publicGroupId && stateChannelList) {
      const channelItem = stateChannelList.filter(
        (item: any) => item.chatid === publicGroupId
      );
      if (channelItem && channelItem[0]) {
        await client.channel.setActiveChannel(channelItem[0]);
        const members = await client.channel.getGroupMemberList({
          page: 1,
          size: 99,
        });
        if (members && members.data && members.data.result) {
          const result = members.data.result;
          setMemberList(result);
          let creatorId = (result[0] && result[0].userid) || "";
          if (creatorId === keys.userid) {
            if (gameRuns === 1) {
              await sendNotify(
                "Darkness falls and the werewolves start killing"
              );
            } else {
              await sendNotify(systemMsg);
            }
          }
          if (dayStatus === DayStatusEnum.DAY) {
            setDisableInput(false);
            setShowVote(true);
          } else {
            if (playerInfo?.actor === Actor.Wolfman) {
              // set active channel is private
              setShowVote(true);
            } else {
              setDisableInput(true);
            }
          }
        }
      }
    }
  };

  const handleVote = () => {
    if (showVote) {
      setShowModal(true);
    }
  };

  const submitVote = async (item: any) => {
    const res = confirm(`Are you sure : ${item.nickname}?`);
    if (res) {
      await killPeople(item.wallet_address || "");
      setShowModal(false);
      setShowVote(true);
    }
  };

  return (
    <div className={ss.container}>
      {playersCount === 6 ? (
        <div>Ready start</div>
      ) : (
        <div>Waiting for other plers</div>
      )}
      <div>
        <button onClick={joinGameAndReady}>joinGameAndReady</button>
        <button onClick={beginGame}>startGame</button>
        <button
          onClick={async () => {
            localStorage.clear();
            window.location.reload();
          }}
        >
          clear storage
        </button>
        <button
          onClick={async () => {
            await restartGame();
          }}
        >
          restartGame
        </button>
      </div>
      <div className={ss.chatBox}>
        <div
          id="chat-content"
          className={ss.chatContent}
          style={{
            position: "relative",
          }}
        >
          <Chat
            client={client}
            appType={AppTypeEnum["pc"]}
            logout={() => {}}
            containerId="chat-content"
          >
            <ConnectMessage />
            {/*<ChannelList />*/}
            <Main
              tabMaps={[
                {
                  title: "Rooms",
                  icon: <RoomAvatarIcon />,
                  type: "room",
                  component: <ChannelList />,
                },
              ]}
              ChannelHead={ChannelHeader}
            />
            <Channel>
              <Window hasContainer>
                {/*<MessageHeader avatarSize={40} />*/}
                <div className={ss.messageHeader}>
                  <div className={ss.leftHeader}>
                    <RoomAvatarIcon style={{ marginRight: "8px" }} />
                    <div>Werewolf</div>
                  </div>
                </div>
                <MessageList className={ss.messageListBox} />
                <MessageConsole Input={<MessageInput Input={MsgInput} />} />
              </Window>
            </Channel>
          </Chat>
        </div>
        <Button onClick={handleVote} type={"primary"} className={ss.voteButton}>
          👋🏻 Vote
        </Button>
        {disableInput && <div className={ss.disableInputBox}></div>}

        {isDead && (
          <div className={ss.deadStyle}>
            <div>
              <div className={ss.emoj}>☠️</div>
              <div className={ss.title}>Your are lost !!!</div>
            </div>
          </div>
        )}

        <Modal
          containerId={""}
          appType={AppTypeEnum.pc}
          visible={showModal}
          title={"Choose who you want to eliminate"}
          closeModal={() => {
            setShowModal(false);
          }}
        >
          <div className={ss.voteBtns}>
            {memberList.map((item: any, index) => {
              return (
                <Button
                  onClick={async () => {
                    await submitVote(item);
                  }}
                  className={ss.voteBtn}
                  key={index}
                >
                  {item.nickname}{" "}
                </Button>
              );
            })}
          </div>
        </Modal>
      </div>
    </div>
  );
};
