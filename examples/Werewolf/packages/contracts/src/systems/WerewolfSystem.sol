// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";

// import { GameRounds, Victim, Player, GroupChatID, PlayersIDList, GameStatus } from "../codegen/Tables.sol";

contract WerewolfSystem is System {
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

  bytes32 private DAY = keccak256("DAY");
  bytes32 private NIGHT = keccak256("NIGHT");

  enum Actor {
    Farmer,
    Wolfman
  }

  enum Camp {
    Good,
    Bad
  }

  string private game_status;
  string private day_status;

  address private creator; //used to finish current round
  uint256 public game_rounds;

  string private groupChatID;

  // mapping(address => string) msg_box;

  address[] private players_list;
  mapping(address => Player)[] private players_mapping;

  uint256 private farmerCount = 0;
  uint256 private wolfmanCount = 0;
  uint256 private oracleCount = 0;

  string public SYSTEM_MSG;

  // Initializing the state variable
  uint256 randNonce = 0;

  address private Victim;

  function initGameData() public returns (bool) {
    require(creator == address(0), "game was started.");
    game_status = "";
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

  function getPlayerInfo(address player_address) public view returns (string memory) {
    Player memory player = players_mapping[0][player_address];
    string memory actor = "";
    string memory camp = "";
    string memory isDead = "";
    if (player.actor == Actor.Farmer) {
      actor = "Farmer";
    } else {
      actor = "Wolfman";
    }

    if (player.camp == Camp.Good) {
      camp = "Good";
    } else {
      camp = "Bad";
    }

    if (player.isDead) {
      isDead = "true";
    } else {
      isDead = "false";
    }

    return strConcat(strConcat(strConcat(actor, ","), camp), isDead);
  }

  function setGameStatus(string memory _gamestatus) public returns (bool) {
    game_status = _gamestatus;
    return true;
  }

  function getGameStatus() public view returns (string memory) {
    return game_status;
  }

  function setDayStatus(string memory _daystatus) public returns (bool) {
    day_status = _daystatus;
    return true;
  }

  function getDayStatus() public view returns (string memory) {
    return day_status;
  }

  function vote(address target_user) public returns (bool) {
    require(players_mapping[0][msg.sender].isDead == false, "a dead man could not do anything.");
    require(players_mapping[0][target_user].isDead == false, "you can not voting to a dead player.");
    return true;
  }

  // Defining a function to generate a random number
  function randMod(uint256 _modulus) external returns (uint256) {
    // increase nonce
    randNonce++;
    return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
  }

  function kill(address target_user) public returns (bool) {
    require(Victim != address(0), "choose a Victim first.");
    require(players_mapping[0][msg.sender].isDead == false, "a dead man could not do anything.");
    // require(players_mapping[0][target_user].actor == Actor.Wolfman, "this player was dead, you can not kill him twice.");
    require(players_mapping[0][target_user].isDead == false, "this player was dead, you can not kill him twice.");
    players_mapping[0][target_user].isDead = true;
    Victim = address(0);
    if (keccak256(abi.encodePacked(day_status)) == DAY) {
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

  function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    string memory ret = new string(_ba.length + _bb.length);
    bytes memory bret = bytes(ret);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) bret[k++] = _ba[i];
    for (uint i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
    return string(ret);
  }
}
