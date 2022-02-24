// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Badge.sol";

/**
 * @title Campaign
 * @author TheV
 * @notice This contract represent a Campaign that can be funded by the community,
 * having a time limit of 30 days and a specific target.
 */
contract Campaign {
    address public owner;
    address private badgeAddress;
    uint256 public goal;
    uint256 public totalRaised;
    uint256 public deadline;
    mapping(address => uint256) public contributorAmounts;

    /**
     * @author TheV
     * @notice Constructor of the campaign
     * @dev totalRaised is 0 by default, deadline is set to block.timestamp + 30 days by default
     * @param _owner The address of the owner of the campaign
     * @param _goal The goal of the campaign. Must be over 0.01 ETH as that's the minumum amount
     * @param _badgeAddress The address of the badge contract
     * of ETH that can be raised
     */
    constructor(
        address _owner,
        uint256 _goal,
        address _badgeAddress
    ) {
        require(_owner != address(0), "Campaign owner address cannot be 0");
        require(_goal > 0.01 ether, "The goal must be greater than 0.01 ether");
        require(_badgeAddress != address(0), "Badge contract is required");
        console.log("Creating a new campaign for owner:", _owner, " and goal:", _goal);
        owner = _owner;
        goal = _goal;
        badgeAddress = _badgeAddress;
        deadline = block.timestamp + 30 days;
    }

    /**
     * @notice Allows the user to contribute to the campaign
     * @dev The contribution must be at least 0.01 ETH
     */
    function contribute() public payable {
        require(block.timestamp < deadline, "The deadline has passed");
        require(msg.value >= 0.01 ether, "The contribution must be greater than 0.01 ether");
        require(address(this).balance < goal, "The goal has been reached");
        console.log("Baking a contribution of:", msg.value);
        totalRaised += msg.value;
        uint256 oldAmount = contributorAmounts[msg.sender];
        contributorAmounts[msg.sender] += msg.value;
        if (oldAmount < 1 ether && contributorAmounts[msg.sender] >= 1 ether) {
            console.log("Contributor", msg.sender, "has reached 1 ether");
            Badge(badgeAddress).awardContributorBadge(msg.sender);
        }
    }

    /**
     * @notice Allows the owner to withdraw the funds
     * @dev The owner can only withdraw the funds if the goal is reached
     */
    function withdraw(uint256 _amount) public {
        require(msg.sender == owner, "Only the owner can withdraw");
        require(totalRaised >= goal, "The goal has not been reached");
        require(_amount <= address(this).balance, "The amount to withdraw is greater than the balance");
        console.log("Withdrawing the funds");
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * @notice Allows the contributor to withdraw the funds
     * @dev The contributor can only withdraw the funds if the project is terminated
     */
    function contributorWithdraw() public {
        require(block.timestamp > deadline, "The project is still running");
        require(totalRaised < goal, "The project is fully funded");
        uint256 userContribution = contributorAmounts[msg.sender];
        require(userContribution > 0, "You have not contributed to this project");
        console.log("Withdrawing the contributor funds");
        contributorAmounts[msg.sender] = 0;
        payable(msg.sender).transfer(userContribution);
    }

    /**
     * @notice Allows the owner to terminate the campaign
     * @dev The campaing is terminated by overriding the deadline with the current timestamp
     */
    function terminate() public {
        require(msg.sender == owner, "Only the owner can terminate the project");
        require(totalRaised < goal, "Can't terminate a project that is fully funded");
        require(block.timestamp < deadline, "Project is already terminated");
        console.log("Terminating the project");
        deadline = block.timestamp;
    }
}
