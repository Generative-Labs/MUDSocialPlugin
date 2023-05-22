// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";

import { GameRounds, Players, PlayersData, GameStatus, DayStatus, Victim, GroupChatID, PlayersIDList, Creator, FarmerCount, WolfmanCount, SYSTEM_MSG } from "../codegen/Tables.sol";
import { Actor, Camp, GameStatusEnum, DayStatusEnum } from "../codegen/Types.sol";

contract WerewolfSystem is System {
  struct Player {
    address players_id;
    Actor actor;
    Camp camp;
    bool isDead;
  }

  bytes32 private DAYSTATUS_DAY = keccak256("DAY");
  bytes32 private DAYSTATUS_NIGHT = keccak256("NIGHT");

  bytes32 private GAMESTATUS_UNSTART = keccak256("UNSTART");
  bytes32 private GAMESTATUS_STARTED = keccak256("STARTED");
  bytes32 private GAMESTATUS_GAMEOVER = keccak256("GAMEOVER");

  // Initializing the state variable
  uint256 randNonce = 0;

  function initGameData() public returns (bool) {
    require(Creator.get(keccak256("Creator")) == address(0), "game was started.");
    GameStatus.set(keccak256("GameStatus"), GameStatusEnum.UNSTART);
    Creator.set(keccak256("Creator"), address(0));
    Victim.set(keccak256("Creator"), address(0));
    GameRounds.set(keccak256("GameRounds"), 0);
    GroupChatID.set(keccak256("GroupChatID"), "");
    FarmerCount.set(keccak256("FarmerCount"), 0);
    WolfmanCount.set(keccak256("WolfmanCount"), 0);

    address[] memory players_address_list = PlayersIDList.get(keccak256("PlayersIDList"));

    for (uint i = 0; i < players_address_list.length; i++) {
      Players.deleteRecord(addressToEntityKey(players_address_list[i]));
      PlayersIDList.deleteRecord(keccak256("PlayersIDList"));
    }

    randNonce = 0;

    return true;
  }

  function joinGame() public returns (bool) {
    require(Players.get(addressToEntityKey(msg.sender)).players_id != msg.sender, "you are in this game already.");
    require(PlayersIDList.get(keccak256("PlayersIDList")).length < 6, "no empty postions.");

    if (FarmerCount.get(keccak256("FarmerCount")) < 4) {
      Players.set(addressToEntityKey(msg.sender), msg.sender, Actor.Farmer, Camp.Good, false);
      FarmerCount.set(keccak256("FarmerCount"), FarmerCount.get(keccak256("FarmerCount")) + 1);
    } else if (WolfmanCount.get(keccak256("WolfmanCount")) < 2) {
      Players.set(addressToEntityKey(msg.sender), msg.sender, Actor.Wolfman, Camp.Bad, false);
      WolfmanCount.set(keccak256("WolfmanCount"), WolfmanCount.get(keccak256("WolfmanCount")) + 1);
    }

    PlayersIDList.push(keccak256("PlayersIDList"), msg.sender);

    return true;
  }

  function setGroupChatID(string memory _groupChatID) public returns (bool) {
    GroupChatID.set(keccak256("GroupChatID"), _groupChatID);
    return true;
  }

  function getGroupChatID() public view returns (string memory) {
    return GroupChatID.get(keccak256("GroupChatID"));
  }

  function getPlayerInfo(address player_address) public view returns (string memory) {
    PlayersData memory player = Players.get(addressToEntityKey(player_address));
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
    bytes32 game_status = keccak256(abi.encodePacked(_gamestatus));
    if (GAMESTATUS_UNSTART == game_status) {
      GameStatus.set(keccak256("GameStatus"), GameStatusEnum.UNSTART);
      return true;
    } else if (GAMESTATUS_STARTED == game_status) {
      GameStatus.set(keccak256("GameStatus"), GameStatusEnum.STARTED);
      return true;
    } else if (GAMESTATUS_GAMEOVER == game_status) {
      GameStatus.set(keccak256("GameStatus"), GameStatusEnum.GAMEOVER);
      return true;
    }
    return false;
  }

  function setDayStatus(string memory _daystatus) public returns (bool) {
    bytes32 day_status = keccak256(abi.encodePacked(_daystatus));
    if (DAYSTATUS_DAY == day_status) {
      DayStatus.set(keccak256("DayStatus"), DayStatusEnum.DAY);
      return true;
    } else if (DAYSTATUS_DAY == day_status) {
      DayStatus.set(keccak256("DayStatus"), DayStatusEnum.NIGHT);
      return true;
    }
    return false;
  }

  function vote(address target_user) public returns (bool) {
    require(Players.get(addressToEntityKey(msg.sender)).isDead == false, "a dead man could not do anything.");
    require(Players.get(addressToEntityKey(target_user)).isDead == false, "you can not voting to a dead player.");
    return true;
  }

  // Defining a function to generate a random number
  function randMod(uint256 _modulus) external returns (uint256) {
    // increase nonce
    randNonce++;
    return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
  }

  function kill(address target_user) public returns (bool) {
    string memory system_msg;
    require(Victim.get(keccak256("Victim")) != address(0), "choose a Victim first.");
    require(Players.get(addressToEntityKey(msg.sender)).isDead == false, "a dead man could not do anything.");
    require(
      Players.get(addressToEntityKey(target_user)).isDead == false,
      "this player was dead, you can not kill him twice."
    );

    Players.setIsDead(addressToEntityKey(target_user), true);

    Victim.set(keccak256("Victim"), address(0));
    if (DayStatus.get(keccak256("DayStatus")) == DayStatusEnum.DAY) {
      system_msg = "it is nighty now.";
      DayStatus.set(keccak256("DayStatus"), DayStatusEnum.NIGHT);
    } else {
      system_msg = "it is day now.";
      DayStatus.set(keccak256("DayStatus"), DayStatusEnum.DAY);
    }
    SYSTEM_MSG.set(keccak256("SYSTEM_MSG"), system_msg);

    return true;
  }

  function chooseVictim(address victim) public returns (bool) {
    require(Victim.get(keccak256("Victim")) == address(0), "you can not change the Victim before he was killed.");
    require(Players.get(addressToEntityKey(victim)).players_id != address(0), "this player is not exists.");
    Victim.set(keccak256("Victim"), victim);
    return true;
  }

  function endGame() public returns (bool) {
    require(msg.sender == Creator.get(keccak256("Creator")), "you are not the creator of this game");
    Creator.set(keccak256("Creator"), address(0));
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

  function addressToEntityKey(address addr) internal pure returns (bytes32) {
    return bytes32(uint256(uint160(addr)));
  }
}
