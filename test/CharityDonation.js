const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CharityDonation Contract", function () {
    let CharityDonation, charityDonation, owner, addr1;

    beforeEach(async function () {
        CharityDonation = await ethers.getContractFactory("CharityDonation");
        charityDonation = await CharityDonation.deploy();
        await charityDonation.deployed();
        [owner, addr1] = await ethers.getSigners();
    });

    it("Should create a campaign", async function () {
        const tx = await charityDonation.createCampaign("Test Campaign", "Description", ethers.utils.parseEther("10"));
        await tx.wait();

        const campaign = await charityDonation.campaigns(1);
        expect(campaign.title).to.equal("Test Campaign");
    });

    it("Should allow donations", async function () {
        await charityDonation.createCampaign("Test Campaign", "Description", ethers.utils.parseEther("10"));

        const tx = await charityDonation.connect(addr1).donateToCampaign(1, { value: ethers.utils.parseEther("1") });
        await tx.wait();

        const campaign = await charityDonation.campaigns(1);
        expect(campaign.raisedAmount).to.equal(ethers.utils.parseEther("1"));
    });
});
