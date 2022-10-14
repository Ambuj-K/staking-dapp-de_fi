// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "../src/Staking.sol";

contract StakingTest is DSTest {
    Staking public st;
    function setUp() public {
        address addr = 0x1234567890123456789012345678901234567890;
        st = new Staking(addr, addr);
    }

    function testStake() public{
        st.stake(.4 ether);
    }

    function testWithDraw() public{
        st.withdraw(.2 ether);
    }

    function testclaimReward() public{
        
        st.claimReward();
    }

    fallback() external payable {}

    receive() external payable {}
}
