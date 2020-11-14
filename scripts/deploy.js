/* global ethers */
// We require the Buidler Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
// When running the script with `buidler run <script>` you'll find the Buidler
// Runtime Environment's members available in the global scope.
// eslint-disable-next-line no-unused-vars
const bre = require("@nomiclabs/buidler");
// const { ethers } = require('ethers')
// import { ethers } from 'ethers'

const local = require("../.local.config.js");

const diamond = require("diamond-util");
// const diamond = require('./diamond-util.js')

async function main() {
  // Buidler always runs the compile task when running scripts through it.
  // If this runs in a standalone fashion you may want to call compile manually
  // to make sure everything is compiled
  // await bre.run('compile');
  let account = await new ethers.Wallet(local.secret).getAddress();
  console.log("Account: " + account);
  console.log("---");
  // xdai
  const prtcleContractAddress = "0xb5d592f85ab2d955c25720ebe6ff8d4d1e1be300";
  const uniV2PoolContractAddress = "0xa527dbc7cdb07dd5fdc2d837c7a2054e6d66daf4";

  // mainnet
  // const ghstContractAddress = '0x3F382DbD960E3a9bbCeaE22651E88158d2791550'

  // eslint-disable-next-line no-unused-vars
  const deployedDiamond = await diamond.deploy({
    diamondName: "PRTCLEShtakingDiamond",
    facets: [
      "DiamondCutFacet",
      "DiamondLoupeFacet",
      "OwnershipFacet",
      "StakingFacet",
      "StringsFacet",
    ],
    owner: account,
    otherArgs: [
      {
        prtcleContract: prtcleContractAddress,
        uniV2PoolContract: uniV2PoolContractAddress,
        stringHashes: ["QmXXnubM1aj3s1rtKL5LXJ2gQSWbapyRtAvPQYK3bFmfea"],
        maxSupplies: [100],
      },
    ],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
