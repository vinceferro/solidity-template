// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Campaign.sol";
import "hardhat/console.sol";

/**
 * @title CampaignFactory
 * @author TheV
 * @notice Factory for Campaigns
 */
contract CampaignFactory {
    address[] public campaigns;
    address badgeAddress;
    mapping(address => uint256) public backers;

    constructor() {
        badgeAddress = address(new Badge());
    }

    /**
     * @notice Allows a founder to create a new campaign
     * @param _goal The goal of the campaign
     */
    function createCampaign(uint256 _goal) public {
        address newCampaign = address(new Campaign(msg.sender, _goal, badgeAddress));
        campaigns.push(newCampaign);
    }
}
