// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const fs = require('fs');
async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
async function main() {
  
  const ARtoken = await hre.ethers.deployContract("ARtoken", []);
  await ARtoken.waitForDeployment();
  console.log("ARtoken Contract Address:", ARtoken.target);


  const NFTmarketplace = await hre.ethers.deployContract("NFTMarketplace", []);
  await NFTmarketplace.waitForDeployment();
  console.log("NFTmarketplace Contract Address:", NFTmarketplace.target);

  const DaoToken = await hre.ethers.deployContract("DAOToken", []);
  await DaoToken.waitForDeployment();
  console.log("DaoToken Contract Address:", DaoToken.target);

  const Dao = await hre.ethers.deployContract("DAO", [ARtoken.target,NFTmarketplace.target,DaoToken.target]);
  await Dao.waitForDeployment();
  console.log("Dao Contract Address:", Dao.target);

 

  
  await sleep(5 * 1000);





  await hre.run("verify:verify", {
    address: ARtoken.target,
    constructorArguments: [],
  });

  await hre.run("verify:verify", {
    address: NFTmarketplace.target,
    constructorArguments: [],
  });

  await hre.run("verify:verify", {
    address: DaoToken.target,
    constructorArguments: [],
  });

  await hre.run("verify:verify", {
    address: Dao.target,
    constructorArguments: [ARtoken.target,NFTmarketplace.target,DaoToken.target],
  });

 

  const constantsFileContent = `
  import ARtoken from '../backend/artifacts/contracts/ARtoken.sol/ARtoken.json'
import NFTMarketplace from '../backend/artifacts/contracts/NFTmarketplace.sol/NFTMarketplace.json'

import Dao from '../backend/artifacts/contracts/Dao.sol/DAO.json'
import DaoToken from '../backend/artifacts/contracts/Daotoken.sol/DAOToken.json'
export const ARTokenAddress = "${ARtoken.target}";
export const NFTMarketplaceAddress = "${NFTmarketplace.target}";
export const DAOAddress = "${Dao.target}";
export const DAOTokenAddress = "${DaoToken.target}";




export const ARTokenABI = ARtoken; // REPLACE THIS WITH THE NFT CONTRACT ABI
export const NFTMarketplaceABI = NFTMarketplace; // REPLACE THIS WITH THE FAKE MARKETPLACE ABI
export const DAOABI = Dao;
export const DAOTokenABI = DaoToken;
`;

  fs.writeFileSync('../frontend/constants.js', constantsFileContent);






}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
