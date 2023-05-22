// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";

// import { GameRounds, Victim, Player, GroupChatID, PlayersIDList, GameStatus } from "../codegen/Tables.sol";

contract Werewolf is System {
  GameStatus public game_status;
  DayStatus public day_status;
  address private creator; //used to finish current round
  uint256 public game_rounds;

  string public groupChatID;

  // mapping(address => string) msg_box;

  address[] private players_list;
  mapping(address => Player)[] private players_mapping;

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

  enum GameStatus {
    UNSTART,
    STARTED,
    GAMEOVER
  }

  enum DayStatus {
    DAY,
    NIGHT
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

  function initGameData() public returns (bool) {
    require(creator == address(0), "game was started.");
    game_status = GameStatus.UNSTART;
    creator = address(0);
    game_rounds = 0;
    groupChatID = "";

    delete players_mapping;

    do {
      players_list.pop();
    } while (players_list.length > 0);

    farmerCount = 0;
    wolfmanCount = 0;
    oracleCount = 0;
    randNonce = 0;

    return true;
  }

  function joinGame() public returns (bool) {
    require(players_mapping[0][msg.sender].players_id != msg.sender, "you are in this game already.");
    require(players_list.length < 6, "no empty postions.");

    Player memory player;
    player.players_id = msg.sender;
    player.isDead = false;

    if (farmerCount < 4) {
      player.actor = Actor.Farmer;
      player.camp = Camp.Good;
    } else if (wolfmanCount < 2) {
      player.actor = Actor.Wolfman;
      player.camp = Camp.Bad;
    }

    players_mapping[0][msg.sender] = player;
    players_list.push(msg.sender);

    return true;
  }

  function setGroupChatID(string memory _groupChatID) public returns (bool) {
    groupChatID = _groupChatID;
    return true;
  }

  function getGroupChatID() public view returns (string memory) {
    return groupChatID;
  }

  function getPlayerInfo(address player_address) public returns (Player memory) {
    return players_mapping[0][player_address];
  }

  function setGameStatus(GameStatus _gamestatus) public returns (bool) {
    game_status = _gamestatus;
    return true;
  }

  function getGameStatus() public view returns (GameStatus) {
    return game_status;
  }

  function setDayStatus(DayStatus _daystatus) public returns (bool) {
    day_status = _daystatus;
    return true;
  }

  function getDayStatus() public view returns (DayStatus) {
    return day_status;
  }

  // function increment() public returns (uint32) {
  //   uint32 counter = Counter.get();
  //   uint32 newValue = counter + 1;
  //   Counter.set(newValue);
  //   return newValue;
  // }

  function vote(address target_user) public returns (bool) {
    require(players_mapping[0][msg.sender].isDead == false, "a dead man could not do anything.");
    require(players_mapping[0][target_user].isDead == false, "you can not voting to a dead player.");
    return true;
  }

  // Defining a function to generate a random number
  function randMod(uint _modulus) external returns (uint) {
    // increase nonce
    randNonce++;
    return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
  }

  // function whispering(address target_user, string memory message) public returns (bool) {
  //   require(players_mapping[0][msg.sender].isDead == false, "a dead man could not do anything.");
  //   require(players_mapping[0][msg.sender].actor == Actor.Wolfman, "you are not a Wolfman.");
  //   require(players_mapping[0][target_user].actor == Actor.Wolfman, "target player is not a Wolfman.");
  //   msg_box[target_user] = message;
  //   return true;
  // }

  function kill(address target_user) public returns (bool) {
    require(Victim != address(0), "choose a Victim first.");
    require(players_mapping[0][msg.sender].isDead == false, "a dead man could not do anything.");
    // require(players_mapping[0][target_user].actor == Actor.Wolfman, "this player was dead, you can not kill him twice.");
    require(players_mapping[0][target_user].isDead == false, "this player was dead, you can not kill him twice.");
    players_mapping[0][target_user].isDead = true;
    Victim = address(0);
    if (day_status == DayStatus.DAY) {
      SYSTEM_MSG = "it is nighty now.";
    } else {
      SYSTEM_MSG = "it is day now.";
    }
    return true;
  }

  function chooseVictim(address victim) public returns (bool) {
    require(Victim == address(0), "you can not change the Victim before he was killed.");
    require(players_mapping[0][victim].players_id != address(0), "this player is not exists.");
    Victim = victim;
    return true;
  }

  function endGame() public returns (bool) {
    require(msg.sender == creator, "you are not the creator of this game");
    creator = address(0);
    initGameData();
    return true;
  }
}
