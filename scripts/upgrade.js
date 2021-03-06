/* global ethers */
// We require the Buidler Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
// When running the script with `buidler run <script>` you'll find the Buidler
// Runtime Environment's members available in the global scope.
// eslint-disable-next-line no-unused-vars
// const bre = require('@nomiclabs/buidler')
// const { ethers } = require('ethers')
// import { ethers } from 'ethers'

// const diamond = require('diamond-util')

const diamond = require("diamond-util");
// const { ethers } = require('ethers')
// const diamond = require('./diamond-util.js')

async function main() {
  // Buidler always runs the compile task when running scripts through it.
  // If this runs in a standalone fashion you may want to call compile manually
  // to make sure everything is compiled
  // await bre.run('compile');

  const accounts = await ethers.getSigners();
  const account = await accounts[0].getAddress();
  console.log("Account: " + account);
  console.log("---");

  // kovan
  const prtcleContractAddress = "0xeDaA788Ee96a0749a2De48738f5dF0AA88E99ab5";
  const uniV2PoolContractAddress = "0xed804550911e985c428537fbf8f8622e4dba4b5d";

  // mainnet
  // const prtcleContractAddress = '0x3F382DbD960E3a9bbCeaE22651E88158d2791550'

  // const ticketsFacet = await ethers.getContractAt('TicketsFacet', '0xFCBb322e272E047853Eb600Ea85aF8596690dEb2')

  // eslint-disable-next-line no-unused-vars
  await diamond.upgrade({
    diamondAddress: "0xA4fF399Aa1BB21aBdd3FC689f46CCE0729d58DEd",
    diamondCut: [
      [
        "StringsFacet",
        diamond.FacetCutAction.Replace,
        ["balanceOfAll(address)"],
      ],
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
