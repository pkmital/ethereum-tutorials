# Introduction

I'm following along [here](https://dev.to/dabit3/building-scalable-full-stack-apps-on-ethereum-with-polygon-2cfb) and logging my progress. The guide says that we'll be building an NFT marketplace that can handle minting and collecting using [Polygon](https://docs.polygon.technology) (MATIC).

# Setup

## Next.js

We'll be using next.js for the skeleton of our application

```bash
$ npx create-next-app digital-marketplace
```

You should see the output:

```bash
Success! Created digital-marketplace at ethereum-tutorials/digital-marketplace
Inside that directory, you can run several commands:

  npm run dev
    Starts the development server.

  npm run build
    Builds the app for production.

  npm start
    Runs the built app in production mode.

We suggest that you begin by typing:

  cd digital-marketplace
  npm run dev
```

We'll be installing a few more dependencies inside the project directory:

```bash
$ cd digital-marketplace
$ npm install ethers hardhat @nomiclabs/hardhat-waffle \
    ethereum-waffle chai @nomiclabs/hardhat-ethers \
    web3modal @openzeppelin/contracts ipfs-http-client@50.1.2 \
    axios
```

## TailwindCSS

And also setting up [TailwindCSS](https://tailwindcss.com/). The guide mentions that this is a popular utility for setting up good looking websites without too much effort. I believe it's a common pairing to Next.js websites too.

```bash
$ npm install -D tailwindcss@latest postcss@latest autoprefixer@latest
```

And then initialize TailwindCSS files:

```bash
$ npx tailwindcss init -p
```

which should say that two files have been created:

```bash
Created Tailwind CSS config file: tailwind.config.js
Created PostCSS config file: postcss.config.js
```

Lastly, the guide says to delete the contents of `styles/globals.css` and replace it with:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## Hardhat

Like before, we'll be using hardhat to initialize our project files for sample contracts, test scripts, and deployments. This guide isn't using typescript so I'll stick w/ the normal javascript project template:

```bash
$ npx hardhat
```

```bash
888    888                      888 888               888
888    888                      888 888               888
888    888                      888 888               888
8888888888  8888b.  888d888 .d88888 88888b.   8888b.  888888
888    888     "88b 888P"  d88" 888 888 "88b     "88b 888
888    888 .d888888 888    888  888 888  888 .d888888 888
888    888 888  888 888    Y88b 888 888  888 888  888 Y88b.
888    888 "Y888888 888     "Y88888 888  888 "Y888888  "Y888

Welcome to Hardhat v2.6.7

✔ What do you want to do? · Create a basic sample project
✔ Hardhat project root: · ethereum-tutorials/digital-marketplace
✔ Do you want to add a .gitignore? (Y/n) · y
```

## Polygon Test Network

The last bit of our barebones setup is to connect it to the Polygon test network. The guide says to update the `hardhat.config.js` with information about the Polygon test network, Mumbai:

```javascript
/* hardhat.config.js */
require("@nomiclabs/hardhat-waffle")
const fs = require('fs')
const privateKey = fs.readFileSync(".secret").toString().trim() || "01234567890123456789"

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337
    },
    mumbai: {
      url: "https://rpc-mumbai.matic.today",
      accounts: [privateKey]
    }
  },
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
}
```

They also mention to create an empty file `.secret` which is also part of the `.gitignore` so that it is not added to the repo. This file will be updated later with information about test wallets private keys from the test network.

```bash
$ touch .secret
$ echo .secret >> .gitignore
```

# Smart Contracts

Finally the skeleton of the project is setup. The next step in the guide is to develop the smart contracts. This is an NFT martketplace, so we'll be developing an ERC-721 contract first, which will be the NFT contract for keeping track of unique digital assets. Create a file `contracts/NFT.sol` with the following:

```javascript
// contracts/NFT.sol
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    constructor(address marketplaceAddress) ERC721("Metaverse Tokens", "METT") {
        contractAddress = marketplaceAddress;
    }

    function createToken(string memory tokenURI) public returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }
}
```

Like in the last tutorial, this contract extends the ERC721 contract. It uses a slightly different language / token, "ERC721URIStorage", which seems to extend the ERC721 token with some extra logic on the tokenURI function that I'm not sure about. The constructor sets the description and token name: "Metaverse Tokens" and "METT". The state variables `_tokenIds` keeps track of the number of unique digital assets managed by this contract, and the `createToken` method assigns a new address, `tokenURI` to the sender's wallet with a new tokenId as a result of executing this contract's `createToken` method. My understanding is that when a sender executes this contract, it will require this address, and it will receive some token that ties the unique digital asset's address to the sender's wallet address. The openzeppelin base contract, ERC721, defines a `_mint` method that already handles some uniqueness constraints. This code is inside the ERC721.sol code inside the openzeppelin node_modules folder ("node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol") in case it's not clear what else this contract defines.

# Next.js README

This is a [Next.js](https://nextjs.org/) project bootstrapped with [`create-next-app`](https://github.com/vercel/next.js/tree/canary/packages/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `pages/index.js`. The page auto-updates as you edit the file.

[API routes](https://nextjs.org/docs/api-routes/introduction) can be accessed on [http://localhost:3000/api/hello](http://localhost:3000/api/hello). This endpoint can be edited in `pages/api/hello.js`.

The `pages/api` directory is mapped to `/api/*`. Files in this directory are treated as [API routes](https://nextjs.org/docs/api-routes/introduction) instead of React pages.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js/) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/deployment) for more details.
