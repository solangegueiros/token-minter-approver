require('dotenv').config();
const fs = require('fs');
const path = require('path');
const HDWalletProvider = require('@truffle/hdwallet-provider');

const mnemonic = process.env.MNEMONIC

module.exports = {

  networks: {
    develop: {
      port: 8545
    },
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
      //gas: 8000000,
    },      
       
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },
  
  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.4",
    }
  }
}