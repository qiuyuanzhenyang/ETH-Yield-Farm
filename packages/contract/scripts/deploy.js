const hre = require("hardhat");
const web3 = require("web3");

async function main() {
  //コントラクトをdeployしているアドレスを取得
  const [deployer] = await hre.ethers.getSigners();

  //コントラクトのdeploy
  const daitokenContractFactory = await hre.ethers.getContractFactory(
    "DaiToken",
  );
  const dapptokenContractFactory = await hre.ethers.getContractFactory(
    "DappToken",
  );
  const tokenfarmContractFactory = await hre.ethers.getContractFactory(
    "TokenFarm",
  );
  const daiToken = await daitokenContractFactory.deploy();
  const dappToken = await dapptokenContractFactory.deploy();
  const tokenFarm = await tokenfarmContractFactory.deploy(
    dappToken.address,
    daiToken.address,
  );

  //全てのDappトークンをファームに移動する（1million）
  await dappToken.transfer(
    tokenFarm.address,
    web3.utils.toWei("1000000", "ether"),
  );

  console.log("Deploying contracts with account: ", deployer.address);
  console.log("Dai Token Contract has been deployed to: ", daiToken.address);
  console.log("Dapp Token Contract has been deployed to: ", dappToken.address);
  console.log("TokenFarm Contract has been deployed to:", tokenFarm.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

//Deploying contracts with account:  0x04CD057E4bAD766361348F26E847B546cBBc7946
//Dai Token Contract has been deployed to:  0x899277E309A644554da3977d5C509Feb93D3A627
//Dapp Token Contract has been deployed to:  0xe2c10c09d9F0DCaab07678054B13a8837B99f612
//TokenFarm Contract has been deployed to:  0x3f8237063F68F034BF25Cf096B164486eCD043ad