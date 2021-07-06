const Token = artifacts.require("BRZ");
const TokenMinterApprover = artifacts.require("TokenMinterApprover");

const AMOUNT = 1000;

module.exports = async (deployer, network, accounts)=> {

  console.log("network", network);
  const [tokenOwner, tokenMinterOwner, minter, approver, toAddress] = accounts;

  //id 5777
  if (network == 'develop') {
    await deployer.deploy(Token, {from: tokenOwner});
    token = await Token.deployed();
  }
  console.log("token.address", token.address);
  const ADMIN_ROLE = await token.ADMIN_ROLE();

  // Minter
  tokenMinter = await deployer.deploy(TokenMinterApprover, token.address, {from: tokenMinterOwner});
  console.log("tokenMinter.address", tokenMinter.address);
  
  result = await tokenMinter.token();
  console.log("token.address in tokenMinter", result);

  const MINTER_ROLE = await tokenMinter.MINTER_ROLE();
  const APPROVER_ROLE = await tokenMinter.APPROVER_ROLE();

  //Add tokenMinter in MinterRole on token
  console.log("token.grantRole ADMIN_ROLE to", tokenMinter.address);
  await token.grantRole (ADMIN_ROLE, tokenMinter.address, {from: tokenOwner});

  result = await token.hasRole(ADMIN_ROLE, tokenMinter.address);
  console.log("tokenMinter.address admin in token", result);

  //Add minter on tokenMinter
  console.log("tokenMinter.grantRole MINTER_ROLE to", minter);
  await tokenMinter.grantRole (MINTER_ROLE, minter, {from: tokenMinterOwner});

  //Add approver on tokenMinter
  console.log("tokenMinter.grantRole APPROVER_ROLE to", approver);
  await tokenMinter.grantRole (APPROVER_ROLE, approver, {from: tokenMinterOwner});

  result = await tokenMinter.mintAllowances(toAddress);
  console.log("\ntokenMinter.mintAllowances before", result);

  //Minter request to mint
  result = await tokenMinter.requestMint(toAddress, AMOUNT, {from: minter});
  console.log("tokenMinter.requestMint", result);

  result = await tokenMinter.mintAllowances(toAddress);
  console.log("\ntokenMinter.mintAllowances after requestMint", result);

  //Approver approve mint
  result = await tokenMinter.approveMint(toAddress, AMOUNT, {from: approver});
  console.log("tokenMinter.approveMint", result);

  //Mint ok - check balance
  result = (await token.balanceOf(toAddress)).toString();
  console.log("\n\ntoken.balanceOf", result);

  //Mint ok - check mintAllowances
  result = await tokenMinter.mintAllowances(toAddress);
  console.log("\ntokenMinter.mintAllowances at end", result);

  //Fluxo2: primeiro approve, depois request mint

  //Approver approve mint
  result = await tokenMinter.approveMint(toAddress, AMOUNT, {from: approver});
  console.log("tokenMinter.approveMint", result);

  //Minter request to mint
  result = await tokenMinter.requestMint(toAddress, AMOUNT, {from: minter});
  console.log("tokenMinter.requestMint", result);
  
  //Mint ok - check balance
  result = (await token.balanceOf(toAddress)).toString();
  console.log("\n\ntoken.balanceOf", result);

  //Mint ok - check mintAllowances
  result = await tokenMinter.mintAllowances(toAddress);
  console.log("\ntokenMinter.mintAllowances at end", result);

/*

*/

};
