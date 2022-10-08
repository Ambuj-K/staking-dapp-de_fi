// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {
    // Staking token used by the app
    IERC20 public s_stakingToken;

    // mapping address to tokens staked
    mapping (address => uint256) public s_balances;

    // redundant token count in the contract, for calculating rewards
    uint256 internal s_totalSupply;

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

}
