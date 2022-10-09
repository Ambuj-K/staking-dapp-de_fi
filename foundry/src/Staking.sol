// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {
    // Staking token used by the app
    IERC20 public s_stakingToken;
    // mapping address to tokens staked
    mapping (address => uint256) internal s_balances;
    // mapping address to reward tokens already paid
    mapping (address => uint256) internal s_userRewardAmountPaid;

    // reward rate per second is 100
    uint256 public constant REWARD_RATE = 100;

    // redundant token count in the contract, for calculating rewards
    uint256 internal s_totalSupply;

    // reward per token storage variable
    uint256 internal s_rewardPerTokenStored;

    // last updated timestamp for reward calculation logic
    uint256 internal s_lastUpdatedTimestamp;

    // modifier for reward per token and associated calculation
    modifier updateReward (address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdatedTimestamp = block.timestamp;
    }

    // latest snapshot based calculation 
    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0){
            return s_rewardPerTokenStored;
        }
        returm s_rewardPerTokenStored + (((block.timestamp - s_lastUpdatedTimestamp) * REWARD_RATE * 1e18) / s_totalSupply);
    }

    function earned(address account) public view returns (uint256){
        uint256 currentBalance = s_balances[account];
        // paid already
    }

    // TODO: Intertoken feasible, chainlink
    constructor (address stakingToken){
        s_stakingToken = IERC20(stakingToken);
    }

    // Events
    event StakeSuccess(address, uint256);
    event WithdrawSuccess(address, uint256);

    // Errors
    error Staking__TransferFailed();

    // transfer token to contract 
    function stake(uint256 amount) external {
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

    function withdraw(uint256 amount) external {
        
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

    function claimReward() external {

    }

}
