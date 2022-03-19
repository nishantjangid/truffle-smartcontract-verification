# truffle-smartcontract-verification
Deploy and verify smart contract using truffle

# initiate a truffle file using this command
truffle init
 
# After creating a contract files with migration file run this command for compile
truffle compile

# For deploy smart contract run this command
truffle migrate
truffle migrate -network testnet    


# For test smart contract locally
Go to truffle config and change to this

    development: {
      host: "localhost",     // Localhost (default: none)
      port: 8545,            // Standard BSC port (default: none)
      network_id: "*",       // Any network (default: none)
    },

# Write command
truffle develop
truffle(develop)>truffle test

# For deploy smart contract


# For verify smart contract Write
truffle run verify Multiple --network testnet

