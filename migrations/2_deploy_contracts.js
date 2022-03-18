const NFTsingle = artifacts.require("Single");
module.exports = function(deployer) {
    deployer.deploy(NFTsingle);
    // Additional contracts can be deployed here
};