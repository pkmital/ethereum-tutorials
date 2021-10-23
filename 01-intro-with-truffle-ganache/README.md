# Development Setup

We'll be using an "ethereum simulator" called [ganache](https://github.com/trufflesuite/ganache). Each time you run `ganache-cli`, it will generate 10 new addresses with simulated test funds for you to use. This is not real money and you’re safe to try anything with no risk of losing funds. Alternatives out there seem to be geth, parity, and ethereum-testrpc. We'll also be using a library called web3 to interact with our simulator, and truffle to deploy and manage contracts to our fake chain.

```bash
$ npm install -g ganache-cli web3 truffle
```

Run `ganache-cli` and note the server address and port are localhost:8545; we'll use this in our truffle config later:

```bash
$ ganache-cli
```

One feature of `ganache-cli` is the ability to fork an existing chain, without even having to download it. You can do this like so:

```bash
$ ganache-cli -f https://mainnet.infura.io
```

You can also fork a chain at a specific block, e.g.:

```bash
$ ganache-cli -f https://mainnet.infura.io@100
````

Now let's setup our project

```bash
$ mkdir dev
$ cd dev/
$ truffle init
````

That will output some helpful text about the scaffolding available:

```bash
> Starting init...
> ================
> 
> > Copying project files to ./dev
> 
> Init successful, sweet!
> 
> Try our scaffold commands to get started:
>   $ truffle create contract YourContractName # scaffold a contract
>   $ truffle create test YourTestName         # scaffold a test
> 
> http://trufflesuite.com/docs
```

This next command will compile the contract:

```bash
$ truffle compile
```

```bash
> Compiling your contracts...
> ===========================
> > Compiling ./contracts/Migrations.sol
> > Artifacts written to ./dev/build/contracts
> > Compiled successfully using:
>    - solc: 0.5.16+commit.9c3226ce.Emscripten.clang
```

Make a [config](https://trufflesuite.com/docs/truffle/reference/configuration) file called `truffle-config.js` with the contents:

```javascript
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    }
  },
  compilers: {
    solc: {
      version: "^0.8.0"
    }
  }
};
```

And this will deploy the contract to the network:

```bash
$ truffle migrate --config truffle-config.js --network development
```

That should show some helpful output about the migration deployment to the simulated chain, with block number 1:

```bash
> Compiling your contracts...
> ===========================
> ✔ Fetching solc version list from solc-bin. Attempt #1
> > Everything is up to date, there is nothing to compile.
> 
> 
> 
> Starting migrations...
> ======================
> > Network name:    'development'
> > Network id:      1634761421448
> > Block gas limit: 6721975 (0x6691b7)
> 
> 
> 1_initial_migration.js
> ======================
> 
>    Deploying 'Migrations'
>    ----------------------
>    > transaction hash:    0xfe3ad671b05ec9504b5aea9262f1cf3b30a31ca7b4e9680fbfbc34f3d7ad2b3a
>    > Blocks: 0            Seconds: 0
>    > contract address:    0x0B5A2aFbf2Ec962B4d1021108c45365D569bA97F
>    > block number:        1
>    > block timestamp:     1634761509
>    > account:             0x5C5E5E0d8e9A268a8609D186364f38631333A9DC
>    > balance:             99.99616114
>    > gas used:            191943 (0x2edc7)
>    > gas price:           20 gwei
>    > value sent:          0 ETH
>    > total cost:          0.00383886 ETH
> 
> 
>    > Saving migration to chain.
>    > Saving artifacts
>    -------------------------------------
>    > Total cost:          0.00383886 ETH
> 
> 
> Summary
> =======
> > Total deployments:   1
> > Final cost:          0.00383886 ETH
```

Meanwhile, in the `ganache-cli`, we should also see two transactions being logged:

```bash
>   Transaction: 0xfe3ad671b05ec9504b5aea9262f1cf3b30a31ca7b4e9680fbfbc34f3d7ad2b3a
>   Contract created: 0x0b5a2afbf2ec962b4d1021108c45365d569ba97f
>   Gas usage: 191943
>   Block Number: 1
>   Block Time: Wed Oct 20 2021 13:25:09 GMT-0700 (Pacific Daylight Time)
> 
>   Transaction: 0x947232568401e017d7906a48eaacd551f2a479b54eadde01c4742c745b923392
>   Gas usage: 42338
>   Block Number: 2
>   Block Time: Wed Oct 20 2021 13:25:09 GMT-0700 (Pacific Daylight Time)
```

# Writing a Smart Contract

Let's step into our first [smart contract](https://docs.soliditylang.org/en/v0.8.9/introduction-to-smart-contracts.html#simple-smart-contract); we'll create a new file called `contracts/BasicContract.sol` - this will be written in the language of Ethereum smart contracts, [Solidity](https://docs.soliditylang.org). Paste these contents into the file:

```javascript
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// BasicContract contract, version 1
contract BasicContract {
  // state
  uint state;

  // transactional function to store a value on the blockchain (costs gas)
  function set(uint document) public {
    state = document;
  }

  // get the stored value on the blockchain (free to compute)
  function get() public view returns (uint) {
    return state;
  }
}
```

We're declaring on the first line, the contract's license. This will be written to the blockchain as well so we're telling the world what the contract's public source code's license is. Next, we're saying what version of solidity we require. Finally, the contract itself is simply a class definition. We have a state variable which we're managing with two operations: `get` and `set`. The `set` method incurs a [transcation](https://trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts#transactions) cost as it is written to the blockchain. The `get` method on the other hand is a free to compute [call](https://trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts#calls).

Next, let's deploy this to the blockchain. Write a migration called `migrations/2_deploy_contracts.js`:

```javascript
var BasicContract = artifacts.require("./BasicContract.sol");

module.exports = function(deployer) {
  deployer.deploy(BasicContract);
};
````

And now we'll run the mgiration on the network with the new flag `--reset`:

```bash
$ truffle migrate --config truffle-config.js --network development --reset
```

# Interacting with a Smart Contract

Next, we can interact with the deployed contract on chain. We'll use the truffle console for this:

```bash
$ truffle console --network development
```

This will put us in an interpreter. We can ask for our contract and all the information available about it:

```bash
> let instance = await BasicContract.deployed()
> instance
```

We can also query accounts available to us:

```bash
> let accounts = await web3.eth.getAccounts()
> accounts
```

Let's try storing one of the accounts values on the chain now:

```bash
> instance.set(accounts[0], {from: accounts[1]})
```

Note that the `set` method in our contract only takes one parameter, but we're passing a second parameter to indicate whose wallet is transacting the smart contract. This includes the special field `from`. Additionally, we could specify:

* from
* to
* gas
* gasPrice
* value
* data
* nonce

Let's see if we in fact did anything by checking the stored value.

```bash
> let result = await instance.get()
```

We use another promise here and get the result in our variable `result`. We can inspect what's going on with:

```bash
> result.toLocaleString()
```

# Future Directions

Check for [vulnerabilities](https://medium.com/consensys-diligence/how-to-exploit-ethereum-in-a-virtual-environment-cffd0be6223c) in your contract code with [karl](https://github.com/cleanunicorn/karl).
