// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CharityDonation {
    struct Campaign {
        uint256 id;
        string title;
        string description;
        uint256 targetAmount;
        uint256 raisedAmount;
        address owner;
        bool isCompleted;
        bool isCancelled;
    }

    struct Donor {
        address donorAddress;
        uint256 amount;
    }

    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => Donor[]) public donors;

    // Events
    event CampaignCreated(uint256 campaignId, address indexed owner);
    event DonationReceived(uint256 campaignId, address indexed donor, uint256 amount);
    event FundsWithdrawn(uint256 campaignId, uint256 amount);
    event CampaignCancelled(uint256 campaignId);

    // Create a new campaign
    function createCampaign(
        string memory title,
        string memory description,
        uint256 targetAmount
    ) public {
        require(targetAmount > 0, "Target amount must be greater than zero");

        campaignCount++;
        campaigns[campaignCount] = Campaign({
            id: campaignCount,
            title: title,
            description: description,
            targetAmount: targetAmount,
            raisedAmount: 0,
            owner: msg.sender,
            isCompleted: false,
            isCancelled: false
        });

        emit CampaignCreated(campaignCount, msg.sender);
    }

    // Donate to a campaign
    function donateToCampaign(uint256 campaignId) public payable {
        require(msg.value > 0, "Donation amount must be greater than zero");
        require(campaigns[campaignId].id != 0, "Campaign does not exist");
        require(!campaigns[campaignId].isCompleted, "Campaign is already completed");
        require(!campaigns[campaignId].isCancelled, "Campaign is cancelled");

        Campaign storage campaign = campaigns[campaignId];
        campaign.raisedAmount += msg.value;

        donors[campaignId].push(Donor({
            donorAddress: msg.sender,
            amount: msg.value
        }));

        emit DonationReceived(campaignId, msg.sender, msg.value);

        if (campaign.raisedAmount >= campaign.targetAmount) {
            campaign.isCompleted = true;
        }
    }

    // Withdraw funds from a campaign
    function withdrawFunds(uint256 campaignId) public {
        Campaign storage campaign = campaigns[campaignId];

        require(campaign.id != 0, "Campaign does not exist");
        require(campaign.owner == msg.sender, "Only the campaign owner can withdraw funds");
        require(campaign.raisedAmount > 0, "No funds to withdraw");
        require(campaign.isCompleted, "Campaign is not completed yet");

        uint256 amount = campaign.raisedAmount;
        campaign.raisedAmount = 0;

        (bool success, ) = campaign.owner.call{value: amount}("");
        require(success, "Withdrawal failed");

        emit FundsWithdrawn(campaignId, amount);
    }

    // Cancel a campaign
    function cancelCampaign(uint256 campaignId) public {
        Campaign storage campaign = campaigns[campaignId];

        require(campaign.id != 0, "Campaign does not exist");
        require(campaign.owner == msg.sender, "Only the campaign owner can cancel the campaign");
        require(!campaign.isCompleted, "Completed campaigns cannot be cancelled");

        campaign.isCancelled = true;

        emit CampaignCancelled(campaignId);
    }

    // Get donors for a specific campaign
    function getDonors(uint256 campaignId) public view returns (Donor[] memory) {
        return donors[campaignId];
    }

    // Refund donors if a campaign is cancelled
    function refundDonors(uint256 campaignId) public {
        Campaign storage campaign = campaigns[campaignId];

        require(campaign.id != 0, "Campaign does not exist");
        require(campaign.isCancelled, "Campaign is not cancelled");
        require(msg.sender == campaign.owner, "Only the campaign owner can refund");

        Donor[] storage campaignDonors = donors[campaignId];
        for (uint256 i = 0; i < campaignDonors.length; i++) {
            Donor storage donor = campaignDonors[i];
            (bool success, ) = donor.donorAddress.call{value: donor.amount}("");
            require(success, "Refund failed for a donor");
        }

        delete donors[campaignId];
        campaign.raisedAmount = 0;
    }
}
