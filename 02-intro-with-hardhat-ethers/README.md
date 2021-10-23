# Introduction

After working through truffle and ganache in the first folder of this repo, and posting my experience, I was pointed to hardhat and ethers as an alternative by a veteran eth developer saying it is a much more enjoyable experience for developers. The website for hardhat lists some interesting features:

  * Ability to use typescript, a typed-language  
  * Ability to see stack traces when errors occur  
  * Ability to debug, and use console.log  
  * Greater customization w/ plugins  

The guides for hardhat look very good. I'm basically following along [here](https://hardhat.org/getting-started/) and logging my experience.

# Installation

Install is done via npm. Create a new directory and run:

```bash
$ npm init
$ npm install --save-dev hardhat
```
This will let us run `hardhat` which will be a barebones install with no plugins. Inside this environment, we will be able to run a test network and compile and test our solidity code.

To run hardhat type:

```bash
$ npx hardhat
```

This will give us a prompt with the option of creating a sample project.

```bash
> 888    888                      888 888               888
> 888    888                      888 888               888
> 888    888                      888 888               888
> 8888888888  8888b.  888d888 .d88888 88888b.   8888b.  888888
> 888    888     "88b 888P"  d88" 888 888 "88b     "88b 888
> 888    888 .d888888 888    888  888 888  888 .d888888 888
> 888    888 888  888 888    Y88b 888 888  888 888  888 Y88b.
> 888    888 "Y888888 888     "Y88888 888  888 "Y888888  "Y888
> 
> Welcome to Hardhat v2.6.7
> 
> ✔ What do you want to do? · Create a basic sample project
> ✔ Hardhat project root: · /home/pkmital/dev/ethereum-tutorials/02-intro-with-hardhat-ethers
> ✔ Do you want to add a .gitignore? (Y/n) · y
> ✔ Help us improve Hardhat with anonymous crash reports & basic usage data? (Y/n) · false
> ✔ Do you want to install this sample project's dependencies with npm (@nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers)? (Y/n) · y
```

When creating the sample project, it will also indicate that we should install some dependencies:

```bash
$ npm install --save-dev @nomiclabs/hardhat-waffle@^2.0.0 ethereum-waffle@^3.0.0 chai@^4.2.0 @nomiclabs/hardhat-ethers@^2.0.0 ethers@^5.0.0
```

The next time we run `npx hardhat` we will see the available tasks we can run:

```bash
>  accounts      Prints the list of accounts
>  check         Check whatever you need
>  clean         Clears the cache and deletes all artifacts
>  compile       Compiles the entire project, building all artifacts
>  console       Opens a hardhat console
>  flatten       Flattens and prints contracts and their dependencies
>  help          Prints this message
>  node          Starts a JSON-RPC server on top of Hardhat Network
>  run           Runs a user-defined script after compiling the project
>  test          Runs mocha tests
```

Apparently as we add new plugins, they'll also show up in this list.

# Sample Project

## Tasks

One of the sample tasks is `accounts` and is defined int he `hardhat.config.js` file. To run this task, we run:

```bash
$ npx hardhat accounts
```

This should run the sample task and print 10 account addresses. Apparently these are deterministic mainnet addresses which are the same for all hardhat users, with known private keys, and bots are likely monitoring them to withdraw funds sent to them. So it's advised to really never send any funds to these addresses.

## Contracts

Hardhat will also install a contract in `contracts/Greeter.sol`:

```javascript
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Greeter {
    string private greeting;

    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }
}
```

This can be compiled with:

```bash
$ npx hardhat compile
```

## Testing

The next step is to test this contract. Hardhat also provides a sample test in the `test/sample-test.js` file:

```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
```
This can be run with:

```bash
$ npx hardhat test
```

We should see the test pass like so:

```bash
>   Greeter
> Deploying a Greeter with greeting: Hello, world!
> Changing greeting from 'Hello, world!' to 'Hola, mundo!'
>     ✓ Should return the new greeting once it's changed (647ms)
> 
> 
>   1 passing (650ms)
```

## Deploying

Deploying contracts uses a script. In the `script/sample-script.js` file is the deployment process for the sample Greeter contract. This can be run with hardhat like so:

```bash
$ npx hardhat run scripts/sample-script.js
```

And this should deploy with the message:

```bash
> Deploying a Greeter with greeting: Hello, Hardhat!
> Greeter deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
```

## Hardhat Network

Under the hood, this is running the script on the [hardhat network](https://hardhat.org/hardhat-network/), similar to the ganache-cli that we used in 01, and is akin to using the command:

```bash
$ npx hardhat run --network hardhat scripts/sample-script.js
```

We may instead want to run a standalone node so that other clients, e.g. a metamask client, Dapp front-end, or script, can connect to it. We can do that like so:

```bash
$ npx hardhat node
```

and then we can tell our wallet or application to connect to http://localhost:8545 and hardhat to use `--network localhost`.
