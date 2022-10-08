// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "../src/Staking.sol";

contract StakingTest is DSTest {
    Staking public st;
    function setUp() public {
        address addr = 0x1234567890123456789012345678901234567890;
        st = new Staking(addr);
    }

    function testStaking() public{
        st.staking(2 ether);
    }

    function testWithDraw() public{
        st.withdraw();
    }

    function testReward() public{

    }

    fallback() external payable {}

    receive() external payable {}
}
