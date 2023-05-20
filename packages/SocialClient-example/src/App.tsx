import React, {useState} from "react";
import {SocialClient} from "@web3mq/social-client/src/index";

// const pk = "39c0f7a91c4fbb1c6eb64e9185b6225d1b044999b6afff8d1d3df886aecc5456";
const pk2 = '132f28f780af6516ecb1d31bc836293b5a46a0cc2cbb812579dcd1334cca7c7b'
const contractAddress = '0xA0c75aABbB8B3E5F2036735E903b7DE7a44839bF'
const App: React.FC = () => {
    const [sendMessage, setSendMessage] = useState('message from social client');
    const [friendAddress, setFriendAddress] = useState('0x7236b0F4F1409AFdC7C9fC446943A7b84b6513a1');

    const socialClient = new SocialClient({
        env: "dev",
        privateKey: pk2,
        contractAddress
    });

    const init = async () => {
        const loginRes = await socialClient.connectWeb3MQNetwork("123123");
        console.log(loginRes, "loginRes");
    };
    const sendHello = async () => {
        await socialClient.sendMessage(sendMessage, '0x9b6a5A1dD55Ea481f76B782862e7df2977dFfE6C')
    }

    const sendFriends = async () => {
        console.log('sendFriends')
        const res = await socialClient.requestFriend(friendAddress, 'request from social client')
        console.log(res, 'sendFriends')
    }
    const getFriends = async () => {
        console.log('getFriends')
        const res = await socialClient.getFriends()
        console.log(res, 'getFriends')
    }

    const removeFriend = async () => {
        console.log('removeFriend')
        const res = await socialClient.removeFriend(friendAddress)
        console.log(res, 'removeFriend')
    }
    const blockUser = async () => {
        console.log('blockUser')
        const res = await socialClient.blockUser(friendAddress)
        console.log(res, 'blockUser')
    }
    const removeBlockUser = async () => {
        console.log('removeBlockUser')
        const res = await socialClient.blockUser(friendAddress, 'remove-block')
        console.log(res, 'removeBlockUser')
    }
    const getBlockUser = async () => {
        console.log('getBlockUser')
        const res = await socialClient.getBlockList()
        console.log(res, 'getBlockUser')
    }

    return (
        <div>
            <button onClick={init}>init12211</button>
            <div>
                <input value={sendMessage} type="text" onChange={event => setSendMessage(event.target.value)}/>
                <button onClick={sendHello}>send hello</button>
            </div>
            <div>
                <input value={friendAddress} type="text" onChange={event => setFriendAddress(event.target.value)}/>
                <button onClick={sendFriends}>send friends</button>
            </div>
            <div>
                <button onClick={getFriends}>getFriends</button>
            </div>
            <div>
                <button onClick={removeFriend}>removeFriend</button>
            </div>
            <div>
                <button onClick={blockUser}>blockUser</button>
            </div>
            <div>
                <button onClick={removeBlockUser}>remote blockUser</button>
            </div>
            <div>
                <button onClick={getBlockUser}>getBlockUser</button>
            </div>

        </div>
    );
};

export default App;
