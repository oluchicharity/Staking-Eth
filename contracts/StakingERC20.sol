// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingERC20 {

    IERC20 public stakingToken;

    uint256 public constant rewardRate = 5; 

    uint256 public constant stakingDuration = 30 days;

    struct Stake {
        uint256 amount;

        uint256 startTime;
    }

    mapping(address => Stake) public stakes;

    constructor(IERC20 _stakingToken) {
      
        stakingToken = _stakingToken;
    }

  function stakeTokens(uint256 _amount) external  {

    require(_amount > 0, "You need to stake more than 0 tokens");

    require(stakes[msg.sender].amount == 0, "Already staked");

    // Check if the contract is allowed to spend the user's tokens
    require(stakingToken.allowance(msg.sender, address(this)) >= _amount, "Token allowance too low");

    // Transfer the staking tokens from the user to the contract
    stakingToken.transferFrom(msg.sender, address(this), _amount);

    // Record the amount staked and the timestamp
    stakes[msg.sender] = Stake(_amount, block.timestamp);
}


    function withdrawTokens() external {

        Stake memory userStake = stakes[msg.sender];

        require(userStake.amount > 0, "You have not staked any tokens");

        require(block.timestamp >= userStake.startTime + stakingDuration, "Staking period not finished");

        // Calculate the reward
        uint256 reward = (userStake.amount * rewardRate) / 100;

        // Send back the staked amount plus the reward
        stakingToken.transfer(msg.sender, userStake.amount + reward);

        // Remove the stake record
        delete stakes[msg.sender];
    }

    function emergencyWithdraw() external  {

        Stake memory userStake = stakes[msg.sender];

        require(userStake.amount > 0, "You have not staked any tokens");

        // Send back only the staked amount (no reward)
        stakingToken.transfer(msg.sender, userStake.amount);

        // Remove the stake record
        delete stakes[msg.sender];
    }
}
