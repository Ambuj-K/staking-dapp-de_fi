// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {
    constructor () ERC20("RewardToken","RT") {
        _mint(msg.sender, 1000000 * 1e18);
    }
}