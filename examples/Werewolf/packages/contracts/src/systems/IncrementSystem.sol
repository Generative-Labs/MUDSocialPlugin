// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Counter } from "../codegen/Tables.sol";

contract IncrementSystem is System {
  bool private game_status;
  address private creator;
  uint256 private day;
  mapping(address => string) msg_box;

  address[] private players_list;
  mapping(address => Player) private players_mapping;

  uint private farmerCount = 0;
  uint private wolfmanCount = 0;
  uint private oracleCount = 0;

  string public SYSTEM_MSG;

  // Initializing the state variable
  uint randNonce = 0;

  address private Victim;

  struct Player {
    address players_id;
    Actor actor;
    Camp camp;
    bool isDead;
  }

  enum Actor {
    Farmer, //3
    Wolfman, //2
    Oracle //1
  }

  enum Camp {
    Good,
    Bad
  }

  function joinGame() public returns (bool) {
    require(players_mapping[msg.sender].players_id != msg.sender, "you are in this game already.");
    require(players_list.length < 6, "no empty postions.");

    Player memory player;
    player.players_id = msg.sender;
    player.isDead = false;

    if (farmerCount < 3) {
      player.actor = Actor.Farmer;
      player.camp = Camp.Good;
    } else if (wolfmanCount < 2) {
      player.actor = Actor.Wolfman;
      player.camp = Camp.Bad;
    } else if (oracleCount == 0) {
      player.actor = Actor.Oracle;
      player.camp = Camp.Good;
    }

    players_mapping[msg.sender] = player;
    players_list.push(msg.sender);

    return true;
  }

  function increment() public returns (uint32) {
    uint32 counter = Counter.get();
    uint32 newValue = counter + 1;
    Counter.set(newValue);
    return newValue;
  }

  // Defining a function to generate a random number
  function randMod(uint _modulus) external returns (uint) {
    // increase nonce
    randNonce++;
    return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
  }

  function whispering(address target_user, string memory message) public returns (bool) {
    require(players_mapping[msg.sender].isDead == false, "a dead man could not do anything.");
    require(players_mapping[msg.sender].actor == Actor.Wolfman, "you are not a Wolfman.");
    require(players_mapping[target_user].actor == Actor.Wolfman, "target player is not a Wolfman.");
    msg_box[target_user] = message;
    return true;
  }

  function kill(address target_user) public returns (bool) {
    require(Victim != address(0), "choose a Victim first.");
    require(players_mapping[msg.sender].isDead == false, "a dead man could not do anything.");
    require(players_mapping[target_user].actor == Actor.Wolfman, "this player was dead, you can not kill him twice.");
    require(players_mapping[target_user].isDead == false, "this player was dead, you can not kill him twice.");
    players_mapping[target_user].isDead = true;
    Victim = address(0);
    SYSTEM_MSG = "it is day now.";
    return true;
  }

  function chooseVictim(address victim) public returns (bool) {
    require(Victim == address(0), "you can not change the Victim before he was killed.");
    require(players_mapping[victim].players_id != address(0), "this player is not exists.");
    Victim = victim;
    return true;
  }
}
