// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking is ReentrancyGuard {
    // Staking token used by the app
    IERC20 public s_stakingToken;
    // Reward token used by the app
    IERC20 public s_rewardsToken;
    // mapping address to tokens staked
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

    // Events
    event StakeSuccess(address, uint256);
    event WithdrawSuccess(address, uint256);

    // Errors
    error Staking__TransferFailed();
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

    // modifier to check for zero amounts staked/withdrawn
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
        // calculate earned balance
        uint256 earned_bal = pastRewards + ((currentBalance * (currentRewardPerToken - amountPaid))/1e18);
        return earned_bal;
    }

    // helper function latest snapshot based calculation of reward per token
    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0){
            return s_rewardPerTokenStored;
        }
        return s_rewardPerTokenStored + (((block.timestamp - s_lastUpdatedTimestamp) * REWARD_RATE * 1e18) / s_totalSupply);
    }

    // TODO: Intertoken feasible, chainlink
    constructor (address stakingToken, address rewardsToken){
        s_stakingToken = IERC20(stakingToken);
        s_rewardsToken = IERC20(rewardsToken);
    }

    // transfer token to contract 
    function stake(uint256 amount) external updateReward(msg.sender) checkZero(amount) {
        //updating the mapping for the tokens staked count addition
        s_balances[msg.sender] = s_balances[msg.sender] + amount;
        s_totalSupply = s_totalSupply + amount;

        // IERC transfer function to take staking amount from sender to this contract
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);

        // require string is gas expensive, so custom descriptive error
        if (!success){
            revert Staking__TransferFailed();
        }

        // event success emitted
        emit StakeSuccess(msg.sender, amount);

    }

    // withdraw token to contract
    function withdraw(uint256 amount) external updateReward(msg.sender) checkZero(amount) {        
        //updating the mapping for the tokens staked count reduction
        s_balances[msg.sender] = s_balances[msg.sender] - amount;
        s_totalSupply = s_totalSupply - amount;

        // IERC transfer function to take staking amount from sender to this contract
        bool success = s_stakingToken.transfer(msg.sender, amount);

        // require string is gas expensive, so custom descriptive error
        if (!success){
            revert Staking__TransferFailed();
        }

        // event success emitted
        emit WithdrawSuccess(msg.sender, amount);
         
    }

    // claim reward 
    function claimReward() external updateReward(msg.sender) {

        // get rewards from what is calculated by updateReward modifier
        uint256 reward = s_rewards[msg.sender];
        bool success = s_rewardsToken.transfer(msg.sender, reward);
        if (!success){
            revert Staking__TransferFailed();
        }
    }

}
