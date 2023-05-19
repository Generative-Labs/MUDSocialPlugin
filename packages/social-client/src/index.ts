import { KeyPairsType, SocialClientBridgeOptions } from "./types";
import { Client, EventTypes } from "@web3mq/client";
import { sleep, socialAbi } from "./utils";
import Web3 from "web3";
import { Contract } from "web3-eth-contract";
import { AbiItem } from "web3-utils";

const password = "123123";
const web3 = new Web3(
  new Web3.providers.HttpProvider("https://rpc.ankr.com/polygon_mumbai")
);

// todo methods
// BlockedUserMapping
// FriendsList
// FriendsMapping
// ViewBlockedUsers
export class SocialClient {
  web3mqClient: Client | null;
  web3mqKeys: KeyPairsType | null;
  socialContract: Contract | null;
  contractAddress: string;
  privateKey: string;
  didKey: string;
  tempPubkey: string;
  fastUrl: string;
  env: "dev" | "test";

  constructor(options: SocialClientBridgeOptions) {
    const { env = "test", privateKey, keys = null, contractAddress } = options;
    this.env = env;
    this.privateKey = privateKey;
    this.contractAddress = contractAddress;
    this.didKey = "";
    this.tempPubkey = "";
    this.fastUrl = "";
    this.web3mqClient = null;
    this.socialContract = null;
    this.web3mqKeys = keys;
    const account = web3.eth.accounts.privateKeyToAccount("0x" + privateKey);
    web3.eth.accounts.wallet.add(account);
    web3.eth.defaultAccount = account.address;
    this.init().then();
  }

  async init() {
    const fastestUrl = await Client.init({
      connectUrl: this.fastUrl,
      app_key: "vAUJTFXbBZRkEDRE",
      env: this.env,
      didKey: this.didKey,
      tempPubkey: this.tempPubkey,
    });
    this.fastUrl = fastestUrl;
    await this.initContract();
    return fastestUrl;
  }

  async initContract() {
    this.socialContract = new web3.eth.Contract(
      socialAbi as AbiItem[],
      this.contractAddress
    );
  }

  /**
   * @status complete
   * @param avatarUrl
   * @param nickname
   */
  async connectWeb3MQNetwork(avatarUrl?: string, nickname?: string) {
    if (!this.fastUrl) {
      await this.init();
    }
    if (!this.socialContract) {
      await this.initContract();
    }
    // const signer = new ethers.Wallet(this.privateKey);
    const accountAddress = web3.eth.defaultAccount?.toLowerCase() || "";
    const registerRes = await this.register(accountAddress);
    if (!registerRes) {
      return false;
    }
    const { userid, userExist } = await Client.register.getUserInfo({
      did_value: accountAddress,
      did_type: "eth",
    });

    const { publicKey, secretKey } = await this.getMainKeys(
      accountAddress,
      password
    );
    if (!userExist) {
      const { signContent } = await Client.register.getRegisterSignContent({
        userid,
        mainPublicKey: publicKey,
        didType: "eth",
        didValue: accountAddress,
      });
      const signRes = await web3.eth.sign(signContent, accountAddress);
      const params = {
        userid,
        didValue: accountAddress,
        mainPublicKey: publicKey,
        did_pubkey: "",
        nickname: nickname || "",
        avatar_url:
          avatarUrl || `https://cdn.stamp.fyi/avatar/${accountAddress}?s=300`,
        signature: signRes,
      };
      await Client.register.register(params);
    }
    const { tempPrivateKey, tempPublicKey } = await Client.register.login({
      password,
      mainPublicKey: publicKey,
      mainPrivateKey: secretKey,
      userid,
      didType: "eth",
      didValue: accountAddress,
    });
    this.web3mqKeys = {
      PrivateKey: tempPrivateKey,
      PublicKey: tempPublicKey,
      userid,
    };
    this.tempPubkey = tempPublicKey;
    this.didKey = `eth:${accountAddress}`;
    this.web3mqClient = await Client.getInstance(this.web3mqKeys);
    this.web3mqClient.on("message.getList", (event: any) => {
      this.callback(event);
    });
    this.web3mqClient.on("connect.changeReadyStatus", (event: any) => {
      this.callback(event);
    });
    this.web3mqClient.on("message.delivered", (event: any) => {
      this.callback(event);
    });
    return this.web3mqKeys;
  }

  /**
   * @status complete
   * @param content
   * @param value
   */
  async sendMessage(content: string, value: string) {
    if (!this.web3mqClient) {
      await this.connectWeb3MQNetwork();
      await sleep(2000);
    }
    await this.web3mqClient?.message.sendMessage(content, value);
  }

  /**
   * @status complete
   * @param address
   * @param content
   */
  async requestFriend(address: string, content?: string) {
    if (!this.socialContract) {
      await this.initContract();
    }
    if (!this.web3mqClient) {
      await this.connectWeb3MQNetwork();
      await sleep(2000);
    }
    const accountAddress = web3.eth.defaultAccount?.toLowerCase() || "";
    const registerRes = await this.register(accountAddress);
    if (!registerRes) return false;
    const targetPubKey = await this.getPubKey(address);
    if (!targetPubKey) {
      throw Error("Target user is not register");
    }
    const res = await this.socialContract?.methods
      .AddFriend(address)
      .send({ from: accountAddress, gas: 500000 })
      .catch((e: any) => {
        console.log(e, "e");
        return e.receipt;
      });
    if (res) {
      await this.web3mqClient?.contact.sendFriend(address, content);
      return res;
    }
  }

  /**
   * @status complete
   * @param address
   */
  async removeFriend(address: string) {
    if (!this.socialContract) {
      await this.initContract();
    }
    const accountAddress = web3.eth.defaultAccount?.toLowerCase() || "";
    const registerRes = await this.register(accountAddress);
    if (!registerRes) return false;
    return await this.socialContract?.methods
      .RemoveFriend(address)
      .send({ from: accountAddress, gas: 500000 })
      .catch((e: any) => {
        return e.receipt;
      });
  }

  // async getFriends(page?: number, size?: number) {
  /**
   * @status WIP
   * @todo page and users detail
   */
  async getFriends() {
    if (!this.web3mqClient) {
      await this.connectWeb3MQNetwork();
      await sleep(2000);
    }
    if (!this.socialContract) {
      await this.initContract();
    }
    return await this.socialContract?.methods.ViewFriends().call();
    // getFriends from web3mq
    // await this.web3mqClient?.contact.getContactList({
    //   page: page || 1,
    //   size: size || 20,
    // });
  }

  /**
   * @status complete
   * @param address
   * @param operation
   */
  async blockUser(address: string, operation?: "block" | "remove-block") {
    if (!this.socialContract) {
      await this.initContract();
    }
    const accountAddress = web3.eth.defaultAccount?.toLowerCase() || "";
    const registerRes = await this.register(accountAddress);
    if (!registerRes) return false;
    if (operation === "remove-block") {
      return await this.socialContract?.methods
        .RemoveBlockedUser(address)
        .send({ from: accountAddress, gas: 500000 })
        .catch((e: any) => {
          return e.receipt;
        });
    }
    return await this.socialContract?.methods
      .BlockUser(address)
      .send({ from: accountAddress, gas: 500000 })
      .catch((e: any) => {
        return e.receipt;
      });
  }

  /**
   * @status complete
   */
  async getBlockList() {
    if (!this.socialContract) {
      await this.initContract();
    }
    return await this.socialContract?.methods.ViewBlockedUsers().call();
  }

  async callback(props: { type: EventTypes }) {
    if (!this.web3mqClient) return;
    const { type } = props;
    console.log(type, "type");
  }

  private async register(address: string) {
    const pubKey = await this.getPubKey(address);
    if (!pubKey) {
      const { publicKey: magicPubKey } = await this.getMainKeys(address);
      return await this.socialContract?.methods
        .Register(magicPubKey.substring(0, 10))
        .send({ from: address, gas: 500000 })
        .catch((e: any) => {
          console.log(e, "e");
          return false;
        });
    }
    return true;
  }

  private async getPubKey(address: string) {
    return await this.socialContract?.methods.GetPubKey(address).call();
  }

  private async getMainKeys(
    accountAddress: string,
    password = "mud_magic_word"
  ) {
    const { signContent } = await Client.register.getMainKeypairSignContent({
      password,
      did_value: accountAddress,
      did_type: "eth",
    });
    const keysSignRes = await web3.eth.sign(signContent, accountAddress);
    return await Client.register.getMainKeypairBySignature(
      keysSignRes,
      password
    );
  }
}

export * from "./types";
