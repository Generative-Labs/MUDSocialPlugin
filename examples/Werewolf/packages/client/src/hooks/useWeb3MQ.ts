import { useMemo, useState } from "react";
import { Client, KeyPairsType } from "@web3mq/client";
import Web3 from "web3";

const password = "123123";
const useLogin = (privateKey: string) => {
  const hasKeys = useMemo(() => {
    const PrivateKey = localStorage.getItem("PRIVATE_KEY") || "";
    const PublicKey = localStorage.getItem("PUBLIC_KEY") || "";
    const userid = localStorage.getItem("userid") || "";
    if (PrivateKey && PublicKey && userid) {
      return { PrivateKey, PublicKey, userid };
    }
    return null;
  }, []);

  const [keys, setKeys] = useState<KeyPairsType | null>(hasKeys);
  const [fastestUrl, setFastUrl] = useState<string | null>(null);
  const web3 = new Web3(
    new Web3.providers.HttpProvider("https://rpc.ankr.com/polygon_mumbai")
  );
  const account = web3.eth.accounts.privateKeyToAccount(privateKey);
  web3.eth.accounts.wallet.add(account);
  web3.eth.defaultAccount = account.address;

  const init = async () => {
    const tempPubkey = localStorage.getItem("PUBLIC_KEY") || "";
    const didKey = localStorage.getItem("DID_KEY") || "";
    const fastUrl = await Client.init({
      connectUrl: "",
      app_key: "vAUJTFXbBZRkEDRE",
      env: "dev",
      didKey,
      tempPubkey,
    });
    setFastUrl(fastUrl);
  };

  const getMainKeys = async (accountAddress: string, password = "123123") => {
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
  };
  const connectWeb3MQNetwork = async (nickname: string) => {
    const avatarUrl = "";
    const accountAddress = web3.eth.defaultAccount?.toLowerCase() || "";
    const { userid, userExist } = await Client.register.getUserInfo({
      did_value: accountAddress,
      did_type: "eth",
    });

    const { publicKey, secretKey } = await getMainKeys(
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
    const {
      tempPrivateKey,
      tempPublicKey,
      pubkeyExpiredTimestamp,
      mainPrivateKey,
      mainPublicKey,
    } = await Client.register.login({
      password,
      mainPublicKey: publicKey,
      mainPrivateKey: secretKey,
      userid,
      didType: "eth",
      didValue: accountAddress,
    });
    const didKey = `eth:${accountAddress}`;
    localStorage.setItem("userid", userid);
    localStorage.setItem("PRIVATE_KEY", tempPrivateKey);
    localStorage.setItem("PUBLIC_KEY", tempPublicKey);
    localStorage.setItem("WALLET_ADDRESS", accountAddress);
    localStorage.setItem(`MAIN_PRIVATE_KEY`, secretKey);
    localStorage.setItem(`MAIN_PUBLIC_KEY`, publicKey);
    localStorage.setItem(`DID_KEY`, didKey);
    localStorage.setItem(
      "PUBKEY_EXPIRED_TIMESTAMP",
      String(pubkeyExpiredTimestamp)
    );
    setKeys({
      PrivateKey: tempPrivateKey,
      PublicKey: tempPublicKey,
      userid,
    });
  };

  const getGroupId = () => {
    return "group:ac696835d58f879e20f8cbdf2e00008184aa2d12";
    // return ''
  };
  const setGroupId = (groupId: string) => {
    localStorage.setItem("werewolf_group_id", groupId);
  };

  return {
    keys,
    fastestUrl,
    init,
    setKeys,
    connectWeb3MQNetwork,
    getGroupId,
    setGroupId,
  };
};

export default useLogin;
