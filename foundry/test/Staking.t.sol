// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "../src/Staking.sol";
import "../src/RewardToken.sol";

interface CheatCodes {
    // Warp time
    function warp(uint256) external;
    // Set block.number
    function roll(uint256) external;
}

contract StakingTest is DSTest {

    CheatCodes constant cheats = CheatCodes(HEVM_ADDRESS);

    Staking public st;
    RewardToken public token;
    uint256 public constant staking_amt = 1 ether;

    // setup/deploy staking & rewardtoken
    function setUp() public {
        token =new RewardToken();
        st = new Staking(address(token), address(token));
    }

    // testing staking function
    function testStake() public{
        emit log_uint(staking_amt);
        token.approve(address(st), staking_amt);
        st.stake(staking_amt);
        uint256 start_earned = st.earned(address(this));
        emit log_uint(start_earned);
        cheats.warp(1 days);
        cheats.roll(block.number+1);
        uint256 end_earned = st.earned(address(this));
        emit log_uint(end_earned);
        assertEq(end_earned,8639900);
    }

    // test withdraw function
    function testWithDraw() public{
        emit log_uint(staking_amt);
        token.approve(address(st), staking_amt);
        st.stake(staking_amt);
        cheats.warp(1 days);
        cheats.roll(block.number+1);
        uint256 start_balance = token.balanceOf(address(this));
        st.withdraw(staking_amt);
        uint256 end_balance = token.balanceOf(address(this));
        uint256 earned = st.earned(address(this));
        emit log_uint(end_balance);
        assertEq(earned,8639900);
        assertEq(start_balance+staking_amt,end_balance);
    }

    // test claim function
    function testclaimReward() public{    
        emit log_uint(staking_amt);
        token.approve(address(st), staking_amt);
        st.stake(staking_amt);
        cheats.warp(1 days);
        cheats.roll(block.number+1);
        uint256 earned = st.earned(address(this));
        uint256 start_balance = token.balanceOf(address(this));    
        st.claimReward();
        uint256 end_balance = token.balanceOf(address(this));
        assertEq(start_balance+earned,end_balance);
    }

    fallback() external payable {}

    receive() external payable {}
}
