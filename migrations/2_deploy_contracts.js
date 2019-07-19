
var MyContract = artifacts.require("Crowdsale");

module.exports = function(deployer) {
	var rate = 1 ; //new BigNumber(1);
	var walletaddress = "0xc74A05E48bd472BFd718b8B584A16af5c84B0Ed1";
  deployer.deploy(MyContract, walletaddress, rate);
};