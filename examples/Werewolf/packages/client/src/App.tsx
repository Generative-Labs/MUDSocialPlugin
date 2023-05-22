import { useMUD } from "./MUDContext";
import { getBurnerWallet } from "@latticexyz/std-client";
import useLogin from "./hooks/useWeb3MQ";
import React, { useEffect, useState } from "react";
import { Client } from "@web3mq/client";
import {
  Chat,
  AppTypeEnum,
  ConnectMessage,
  Channel,
  MessageConsole,
  MessageList,
  MessageInput,
  Window,
  Main,
  Button,
  ChannelList,
} from "@web3mq/react-components";
import "@web3mq/react-components/dist/css/index.css";
import ss from "./index.module.css";
import MsgInput from "./components/MsgInput";
import ChannelHeader from "./components/ChannelHeader";
import { RoomAvatarIcon } from "./icons";
import DisableMsgInput from "./components/DisableMsgInput";

// const GroupId = web3mq_mud_werewolf_group_id
export const App = () => {
  const {
    systemCalls: { joinGame },
    network: { singletonEntity },
  } = useMUD();
  const pk = getBurnerWallet().value;
  const {
    keys,
    fastestUrl,
    init,
    connectWeb3MQNetwork,
    getGroupId,
    setGroupId,
  } = useLogin(pk);

  const [myProfile, setMyProfile] = useState<any>();
  const [activeChannel, setActiveChannel] = useState("");
  const [showVote, setShowVote] = useState(false);
  const [disableInput, setDisableInput] = useState(false);

  useEffect(() => {
    init();
    document
      .getElementsByTagName("body")[0]
      .setAttribute("data-theme", "light");
  }, []);

  if (!keys || !fastestUrl) {
    return (
      <button onClick={connectWeb3MQNetwork} disabled={!fastestUrl}>
        {fastestUrl ? "Connect" : "Initializing"}
      </button>
    );
  }
  const client = Client.getInstance(keys);

  client.channel.queryChannels({
    page: 1,
    size: 10,
  });
  const handleEvent = (event: any) => {
    const { type } = event;
    const { channelList } = client.channel;
    if (type === "channel.getList") {
      const groupId = getGroupId();
      if (groupId && channelList) {
        const channelItem = channelList.filter(
          (item) => item.chatid === groupId
        );
        if (channelItem && channelItem[0]) {
          client.channel.setActiveChannel(channelItem[0]);
          // setActiveChannel(channelItem[0].chatid)
        }
      }
    }
    if (type === "message.send") {
      setDisableInput(true);
    }

    // if (type === 'channel.activeChange') {
    //   setDisableInput(false)
    // }
  };

  client.on("message.getList", handleEvent);
  client.on("message.send", handleEvent);
  client.on("message.delivered", handleEvent);
  client.on("connect.changeReadyStatus", handleEvent);
  client.on("message.delivered", handleEvent);
  client.on("channel.getList", handleEvent);
  client.on("channel.activeChange", handleEvent);
  client.on("channel.updated", handleEvent);
  const getMyProfile = async () => {
    const res = await client.user.getMyProfile();
    console.log(res, "res");
    setMyProfile(res);
  };

  const startGame = async () => {
    const groupId = getGroupId();
    if (!groupId) {
      await client.channel.createRoom({
        groupName: "Werewolf2",
        permissions: {
          "group:join": {
            type: "enum",
            value: "public",
          },
        },
      });
      const { channelList } = client.channel;
      if (channelList) {
        setGroupId(channelList[0].chatid);
      }
    } else {
      const res = await client.channel.joinGroup(groupId);
      console.log(res, "res");
    }
  };

  const sendNotify = async () => {
    const notify = JSON.stringify({
      content: "night is comming",
      messageType: "werewolf_notify",
    });

    await client.message.sendMessage(notify);
  };
  return (
    <div className={ss.container}>
      {!myProfile && <button onClick={getMyProfile}>getMyProfile</button>}
      <div>
        connected: <div> {myProfile?.wallet_address || ""} </div>
      </div>
      <div>
        <button onClick={joinGame}>joinGame</button>
      </div>
      <div>
        <button onClick={startGame}>startGame</button>
      </div>

      {/*{activeChannel && (*/}
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
                  <Button type={"primary"} className={ss.voteButton}>
                    👋🏻 Vote
                  </Button>
                </div>
                <MessageList className={ss.messageListBox} />
                <MessageConsole
                  Input={
                    <MessageInput
                      Input={disableInput ? DisableMsgInput : MsgInput}
                    />
                  }
                />
              </Window>
            </Channel>
          </Chat>
        </div>
      </div>
      {/*)}*/}
    </div>
  );
};
