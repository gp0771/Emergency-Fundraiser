// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EmergencyFundraiser {

    address public fundraiserOwner;
    uint256 public goalAmount;
    uint256 public totalRaised;
    uint256 public deadline;
    bool public goalMet;
    bool public fundsWithdrawn;

    mapping(address => uint256) public contributions;

    // Modifier to restrict access to the fundraiser owner
    modifier onlyOwner() {
        require(msg.sender == fundraiserOwner, "Only owner can perform this action");
        _;
    }

    // Modifier to check if the funding goal is met
    modifier goalAchieved() {
        require(goalMet, "Funding goal not met yet");
        _;
    }

    // Modifier to ensure the fundraiser has ended
    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Fundraiser is still ongoing");
        _;
    }

    // Constructor to initialize the fundraiser
    constructor(uint256 _goalAmount, uint256 _durationInDays) {
        fundraiserOwner = msg.sender;
        goalAmount = _goalAmount;
        totalRaised = 0;
        deadline = block.timestamp + _durationInDays * 1 days;
        goalMet = false;
        fundsWithdrawn = false;
    }

    // 1. Function to donate to the emergency fundraiser
    function donate() external payable {
        require(block.timestamp < deadline, "Fundraiser has ended");
        require(msg.value > 0, "Donation must be greater than zero");

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;

        // Check if the goal is met after this donation
        if (totalRaised >= goalAmount && !goalMet) {
            goalMet = true;
        }
    }

    // 2. Function to withdraw funds after the goal is met
    function withdrawFunds() external onlyOwner goalAchieved afterDeadline {
        require(!fundsWithdrawn, "Funds have already been withdrawn");

        uint256 amount = totalRaised;
        fundsWithdrawn = true;

        // Transfer the raised funds to the owner
        payable(fundraiserOwner).transfer(amount);
    }
}
