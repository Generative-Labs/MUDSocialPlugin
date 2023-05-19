export type KeyPairsType = {
  PrivateKey: string;
  PublicKey: string;
  userid: string;
};

export interface SocialClientBridgeOptions {
  privateKey: string;
  contractAddress: string;
  env?: "dev" | "test";
  keys?: KeyPairsType;
}