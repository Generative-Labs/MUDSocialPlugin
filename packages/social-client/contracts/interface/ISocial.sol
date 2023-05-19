// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
interface ISocial {
    event user_register(address indexed user,string pubkey);
    event user_blocked(address indexed operator,address indexed user);
    event user_add_friend(address indexed operator,address indexed user);
    event user_removed_from_friends(address indexed operator,address indexed user);
    event user_removed_from_blocked(address indexed operator,address indexed user);

    function Register(string memory pubkey)external returns (bool);
    function GetPubKey(address user)external view returns (string memory);
    function AddFriend(address user)external returns (bool);
    function RemoveFriend(address user)external returns (bool);
    function ViewFriends()external view returns (address[] memory);
    function BlockUser(address user)external returns (bool);
    function RemoveBlockedUser(address user)external returns (bool);
    function ViewBlockedUsers()external view returns (address[] memory);
}