// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Helper{

    mapping (address => uint256) internal s_balances;
    // mapping address to reward tokens already paid
    mapping (address => uint256) internal s_userRewardPerTokenPaid;
    // mapping address to reward tokens
    mapping (address => uint256) internal s_rewards;

    // reward rate per second is 100
    uint256 public constant REWARD_RATE = 100;

    // redundant token count in the contract, for calculating rewards
    uint256 internal s_totalSupply;

    // reward per token storage variable
    uint256 internal s_rewardPerTokenStored;

    // last updated timestamp for reward calculation logic
    uint256 internal s_lastUpdatedTimestamp;

    error Staking_AmountNotEnough();

    // modifier for reward per token and calculation of rewards every time stake/claim/withdraw is called 
    modifier updateReward (address account) {
        // reward per token at the moment
        s_rewardPerTokenStored = rewardPerToken();

        // current timestamp
        s_lastUpdatedTimestamp = block.timestamp;

        // rewards to be stored
        s_rewards[account] = earned(account);

        // store reward per token 
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    modifier checkZero (uint256 amount) {
        if (amount == 0) {
            revert Staking_AmountNotEnough();
        }
        _;
    }

    // helper function to calculate earned rewards 
    function earned(address account) public view returns (uint256){
        uint256 currentBalance = s_balances[account];
        // subtract paid already
        uint256 amountPaid = s_userRewardPerTokenPaid[account];
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = s_rewards[account]; 
        uint256 earned_bal = pastRewards + ((currentBalance * (currentRewardPerToken - amountPaid))/1e18);
        return earned_bal;
    }

    // helper function latest snapshot based calculation 
    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0){
            return s_rewardPerTokenStored;
        }
        return s_rewardPerTokenStored + (((block.timestamp - s_lastUpdatedTimestamp) * REWARD_RATE * 1e18) / s_totalSupply);
    }

}