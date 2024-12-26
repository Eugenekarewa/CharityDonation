import { Network, Alchemy } from "alchemy-sdk";
import { ethers } from "hardhat";

// Optional config object, but defaults to demo api-key and eth-mainnet.
const settings = {
  apiKey: "aEx40W6kIYWRHLLuYoEHzlhrBnXjJwyq", // Replace with your Alchemy API Key.
  network: Network.ETH_SEPOLIA, // Replace with your network.
};
const alchemy = new Alchemy(settings);

async function main() {
  const CharityDonation = await ethers.getContractFactory("CharityDonation");
  const charityDonation = await CharityDonation.deploy();
  await charityDonation.deployed();

  console.log("CharityDonation deployed to:", charityDonation.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
alchemy.core.getBlock(15221026).then(console.log);