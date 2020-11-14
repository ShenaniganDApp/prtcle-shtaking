// SPDX-License-Identifier: MIT
pragma solidity 0.7.3;

struct Account {
    uint96 prtcle;
    uint96 uniV2PoolTokens;
    uint40 lastUpdate;
    uint104 shweatPrtcles;
}

struct String {
    // user address => balance
    mapping(address => uint256) accountBalances;
    uint96 totalSupply;
    uint96 maxSupply;
}

struct AppStorage {
    mapping(address => mapping(address => bool)) approved;
    mapping(address => Account) accounts;
    mapping(uint256 => String) strings;
    string[] stringHashes;
    address prtcleContract;
    address uniV2PoolContract;
    string stringBaseUri;
}
