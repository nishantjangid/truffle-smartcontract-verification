const Multi = artifacts.require("Multiple");
module.exports = function(deployer) {
    deployer.deploy(Multi);
    // Additional contracts can be deployed here
};