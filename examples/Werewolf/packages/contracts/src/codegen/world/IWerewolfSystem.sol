// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

interface IWerewolfSystem {
  function initGameData() external returns (bool);

  function joinGame(string memory nick_name) external returns (bool);

  function startGame() external returns (bool);

  function leaveGame() external returns (bool);

  function setGroupChatID(string memory _groupChatID, bool isPrivate) external returns (bool);

  function getGroupChatID(bool isPrivate) external view returns (string memory);

  function getPlayerInfo(address player_address) external view returns (string memory);

  function setGameStatus(string memory _gamestatus) external returns (bool);

  function setDayStatus(string memory _daystatus) external returns (bool);

  function vote(address target_user) external returns (bool);

  function randMod(uint256 _modulus) external returns (uint256);

  function chooseVictim(address victim) external returns (bool);

  function endGame() external returns (bool);
}
