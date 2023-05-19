// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interface/ISocial.sol";

contract Social is ISocial {
    struct User {
        address user_address;
        uint256 created_at;
    }
    bytes32 private EMPTYSTRING = keccak256(abi.encodePacked(""));

    mapping(address => string) private Pubkeys;
    mapping(address => mapping(address => User)) private FriendsMapping;
    mapping(address => address[]) private FriendsList;

    mapping(address => mapping(address => User)) private BlockedUserMapping;
    mapping(address => address[]) private BlockList;

    // constructor() {
    //     EMPTYSTRING = keccak256(abi.encodePacked(""));
    // }

    function Register(string memory pubkey) public returns (bool) {
        Pubkeys[msg.sender] = pubkey;
        emit user_register(msg.sender, pubkey);
        return true;
    }

    function GetPubKey(address user) public view returns (string memory) {
        return Pubkeys[user];
    }

    function AddFriend(address user) public returns (bool) {
        require(user != msg.sender, "you can not add yourself as a friend");
        require(
            keccak256(abi.encodePacked(Pubkeys[user])) != EMPTYSTRING,
            "you can not add a user that has no pubkey"
        );
        require(
            FriendsMapping[msg.sender][user].created_at == 0,
            "he/she is your friend already"
        );
        if (BlockedUserMapping[msg.sender][user].created_at != 0) {
            RemoveBlockedUser(user);
        }
        User memory friend = User({
            user_address: user,
            created_at: block.timestamp
        });

        FriendsMapping[msg.sender][user] = friend;
        FriendsList[msg.sender].push(user);
        emit user_add_friend(msg.sender, user);
        return true;
    }

    function RemoveFriend(address user) public returns (bool) {
        require(
            FriendsMapping[msg.sender][user].created_at != 0,
            "he/she is not your friend"
        );
        delete FriendsMapping[msg.sender][user];

        for (uint256 i = 0; i < FriendsList[msg.sender].length; i++) {
            if (FriendsList[msg.sender][i] == user) {
                FriendsList[msg.sender][i] = FriendsList[msg.sender][
                    FriendsList[msg.sender].length - 1
                ];
                FriendsList[msg.sender].pop();
                emit user_removed_from_friends(msg.sender,user);
                return true;
            }
        }

        return false;
    }

    function ViewFriends() public view returns (address[] memory) {
        return FriendsList[msg.sender];
    }

    function BlockUser(address user) public returns (bool) {
        require(user != msg.sender, "you can not block yourself");
        require(
            keccak256(abi.encodePacked(Pubkeys[user])) != EMPTYSTRING,
            "you can not block a user that not exists"
        );
        if (FriendsMapping[msg.sender][user].created_at != 0) {
            RemoveFriend(user);
        }
        User memory blockedUser = User({
            user_address: user,
            created_at: block.timestamp
        });

        BlockedUserMapping[msg.sender][user] = blockedUser;
        BlockList[msg.sender].push(user);
        emit user_blocked(msg.sender,user);
        return true;
    }

    function RemoveBlockedUser(address user) public returns (bool) {
        require(
            BlockedUserMapping[msg.sender][user].created_at != 0,
            "he/she is not your block list"
        );
        delete BlockedUserMapping[msg.sender][user];

        for (uint256 i = 0; i < BlockList[msg.sender].length; i++) {
            if (BlockList[msg.sender][i] == user) {
                BlockList[msg.sender][i] = BlockList[msg.sender][
                    BlockList[msg.sender].length - 1
                ];
                BlockList[msg.sender].pop();
                emit user_removed_from_blocked(msg.sender,user);
                return true;
            }
        }

        return false;
    }

    function ViewBlockedUsers() public view returns (address[] memory) {
        return BlockList[msg.sender];
    }
}
