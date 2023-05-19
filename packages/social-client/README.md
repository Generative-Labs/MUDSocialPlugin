# Quickstart

---

## Feature

1. register to mud and web3mq
2. Friends List: add / remove friend / get friends list
3. User Blacklist : block user / remove block user / get block user list
4. send message to Registered Ethernet addresses

## Usage

1. Install Social-client sdk
2. Init SocialClient client
3. Call `connectWeb3MQNetwork` function to register to MUD and connect to web3mq network

### Create example

> tips:
> Only the latest version of vite is currently supported

```bash
npm create vite@latest web3mq-example-vite
```

### Install

```bash
npm install @web3mq/social-client
```

or

```bash
yarn add @web3mq/social-client
```

### Init Social client

```tsx
import {SocialClient} from "@web3mq/social-client/src/index";

const pk = 'YOUR_WALLET_PRIVATE_KEY'
const contractAddress = "GAME_CONTRACT_ADDRESS"
// eg: 0xA0c75aABbB8B3E5F2036735E903b7DE7a44839bF
const socialClient = new SocialClient({
    env: "dev",
    privateKey: pk2,
    contractAddress
});
```

### Register user

```tsx
await socialClient.connectWeb3MQNetwork();
```

## Methods

### RegisterUser

```tsx
await socialClient.connectWeb3MQNetwork();
```


### requestFriend

#### params

| name            | type   | format          | desc                          | eg:  | default | required |
| --------------- | ------ | --------------- | ----------------------------- | ---- | ------- | -------- |
| privateKey      | string | -               | your eth wallet private key   | -    | -       | true     |
| contractAddress | string | -               | contract address              | -    | -       | true     |
| env             | string | 'test' \| 'dev' | network environment of web3mq | test | test    | false    |

#### code
```tsx
await socialClient.requestFriend(friendAddress, 'request from social client')
```

### getFriends

#### code
```tsx
await socialClient.getFriends()
```

### removeFriend

#### params

| name    | type   | format | desc               | eg:                                        | default | required |
| ------- | ------ | ------ | ------------------ | ------------------------------------------ | ------- | -------- |
| address | string | -      | eth wallet address | 0x9b6a5A1dD55Ea481f76B782862e7df2977dFfE6C | -       | true     |

#### code
```tsx
await socialClient.removeFriend(friendAddress)
```

### blockUser

#### params

| name      | type                      | format                    | desc               | eg:                                        | default | required |
| --------- | ------------------------- | ------------------------- | ------------------ | ------------------------------------------ | ------- | -------- |
| address   | string                    | -                         | eth wallet address | 0x9b6a5A1dD55Ea481f76B782862e7df2977dFfE6C | -       | true     |
| operation | 'block' \| 'remove-block' | 'block' \| 'remove-block' | operation type     | blockD55Ea481f76B782862e7df2977dFfE6C      | block   | false    |

#### code
```tsx
// block user 
await socialClient.blockUser(friendAddress)
// remove block user 
await socialClient.blockUser(friendAddress, 'remove-block')
```

### getBlockList
#### code
```tsx
await socialClient.getBlockList()
```


### sendMessage

#### params

| name    | type   | format                    | desc            | eg:                                        | default | required |
| ------- | ------ | ------------------------- | --------------- | ------------------------------------------ | ------- | -------- |
| content | string | -                         | message content | 0x9b6a5A1dD55Ea481f76B782862e7df2977dFfE6C | -       | true     |
| value   | string | 'block' \| 'remove-block' | eth address     | 0x9b6a5A1dD55Ea481f76B782862e7df2977dFfE6C | -       | true     |

#### code
```tsx
 await socialClient.sendMessage(sendMessage, '0x9b6a5A1dD55Ea481f76B782862e7df2977dFfE6C')
```



### getConnectLink()

> Create wallet connect deep link

```tsx
import {DappConnect, DappConnectCallbackParams} from "@web3mq/dapp-connect";

const handleDappConnectCallback = (event: DappConnectCallbackParams) => {
};
const dappConnectClient = new DappConnect(
    {dAppID: "SwapChat:im"},
    handleDappConnectCallback
);
const deepLink = dappConnectClient.getConnectLink();
const qrCode = await generateQrCode(deepLink);
console.log(deepLink);
console.log(qrCode);
```

:::tip
When the return value of the callback function
is [SuccessData](/docs/DappConnect-SDK/typeList#when-the-wallet-is-successfully-connected), it means that the wallet and
dapp are successfully connected.

Once the wallet and dapp are successfully connected, the sendSign method can be called to request a signature
:::

### sendSign()

:::tip
After calling the sendsign method, the signature result will not be received directly, but will be returned via a
callback function
:::

```tsx
import {DappConnect, DappConnectCallbackParams} from "@web3mq/dapp-connect";

const handleDappConnectCallback = (event: DappConnectCallbackParams) => {
};
const dappConnectClient = new DappConnect(
    {dAppID: "SwapChat:im"},
    handleDappConnectCallback
);
await dappConnectClient.sendSign({
    signContent: "test sign out",
    didValue: walletAddress || "",
});
```

:::tip

When the return value of the callback function
is [SuccessData](/docs/DappConnect-SDK/typeList#when-the-wallet-signature-is-successful), the wallet is successfully
signed and the signature result is returned

:::

### Full example

```tsx
import React, {useState} from "react";
import {
    DappConnect,
    DappConnectCallbackParams,
    WalletMethodMap,
} from "@web3mq/dapp-connect";
import QRCode from "qrcode";

const generateQrCode = async (text: string) => {
    try {
        return await QRCode.toDataURL(text);
    } catch (err: any) {
        throw new Error(err.message);
    }
};

const App: React.FC = () => {
    const [client, setClient] = useState<DappConnect>();
    const [walletAddress, setWalletAddress] = useState("");
    const [qrCodeImg, setQrCodeImg] = useState("");
    const [signRes, setSignRes] = useState("");

    const handleDappConnectCallback = async (
        event: DappConnectCallbackParams
    ) => {
        console.log(event, "event - handleDappConnectCallback");
        const {type, data} = event;
        if (data.approve) {
            if (type === "connect") {
                console.log("ws connect success");
                return;
            }
            if (type === "dapp-connect") {
                const metadata = data.metadata;
                if (data.method === WalletMethodMap.providerAuthorization) {
                    console.log(
                        "connect success, wallet address is : ",
                        metadata?.address
                    );
                    setWalletAddress(metadata?.address || "");
                }
                if (data.method === WalletMethodMap.personalSign) {
                    console.log("sign success: ", metadata?.signature);
                    setSignRes(metadata?.signature || "");
                }
            }
        } else {
            console.log(`wallet response error: 
       code is: ${data.code}, 
       message is :${data.message}
       `);
            setWalletAddress("");
            setSignRes("");
            setQrCodeImg("");
        }
    };
    const init = async () => {
        const dappConnectClient = new DappConnect(
            {dAppID: "SwapChat:im", keepAlive: false, requestTimeout: 60000},
            handleDappConnectCallback
        );
        console.log("the dapp-connect client: ", dappConnectClient);
        setClient(dappConnectClient);
    };
    const sign = async () => {
        await client?.sendSign({
            signContent: "test sign out",
            address: walletAddress || "",
        });
    };
    const createLink = async () => {
        const link = client?.getConnectLink();
        console.log(link, "link");
        if (link) {
            const qrCode = await generateQrCode(link);
            setQrCodeImg(qrCode);
        }
    };

    return (
        <div>
            <div>
                <button onClick={init}>init</button>
            </div>
            <div>
                <button onClick={createLink}>create link</button>
            </div>
            <div>
                <button onClick={sign}>send Sign</button>
            </div>

            <div>
                {qrCodeImg && (
                    <img
                        src={qrCodeImg}
                        style={{
                            width: "200px",
                            height: "200px",
                        }}
                        alt=""
                    />
                )}
            </div>
            <div>
                {walletAddress && (
                    <p>{"connect success, wallet address is : " + walletAddress}</p>
                )}
            </div>
            <div>{signRes && <p> signature: {signRes} </p>}</div>
        </div>
    );
};

export default App;
```

```ts
const [client, setClient] = useState();
const [event, setEvent] = useState();

const callback = (eventData) => {
    setEvent(eventData);
};

useEffect(() => {
    console.log(client);
}, [eventData]);

const init = () => {
    setClient(new Client({}, callback));
};
```
