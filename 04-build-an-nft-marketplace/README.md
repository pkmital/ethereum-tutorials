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

Finally the skeleton of the project is setup. The next step in the guide is to develop the smart contracts. 

## NFT Contract

This is an NFT martketplace, so we'll be developing an ERC-721 contract first, which will be the NFT contract for keeping track of unique digital assets. Create a file `contracts/NFT.sol` with the following:

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

## Marketplace Contract

### Source Code

The next contract is the market itself, which enables listing items and collecting them. Create a file `contracts/NFTMarket.sol` with the contents:

```javascript
// contracts/NFTMarket.sol
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarket is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

  address payable owner;
  uint256 listingPrice = 0.025 ether;

  constructor() {
    owner = payable(msg.sender);
  }

  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
  }

  mapping(uint256 => MarketItem) private idToMarketItem;

  event MarketItemCreated (
    uint indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    bool sold
  );

  /* Returns the listing price of the contract */
  function getListingPrice() public view returns (uint256) {
    return listingPrice;
  }

  /* Places an item for sale on the marketplace */
  function createMarketItem(
    address nftContract,
    uint256 tokenId,
    uint256 price
  ) public payable nonReentrant {
    require(price > 0, "Price must be at least 1 wei");
    require(msg.value == listingPrice, "Price must be equal to listing price");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();

    idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      price,
      false
    );

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit MarketItemCreated(
      itemId,
      nftContract,
      tokenId,
      msg.sender,
      address(0),
      price,
      false
    );
  }

  /* Creates the sale of a marketplace item */
  /* Transfers ownership of the item, as well as funds between parties */
  function createMarketSale(
    address nftContract,
    uint256 itemId
    ) public payable nonReentrant {
    uint price = idToMarketItem[itemId].price;
    uint tokenId = idToMarketItem[itemId].tokenId;
    require(msg.value == price, "Please submit the asking price in order to complete the purchase");

    idToMarketItem[itemId].seller.transfer(msg.value);
    IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
    idToMarketItem[itemId].owner = payable(msg.sender);
    idToMarketItem[itemId].sold = true;
    _itemsSold.increment();
    payable(owner).transfer(listingPrice);
  }

  /* Returns all unsold market items */
  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current();
    uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
    uint currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    for (uint i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].owner == address(0)) {
        uint currentId =  i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns only items that a user has purchased */
  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint currentId =  i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns only items a user has created */
  function fetchItemsCreated() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }
}
```

### State Variables

This is super long so I'm just describing my understanding of it as I read it. The `ReentrancyGuard` contract describes a simple contract that provides atomic operations to its functions through the use of a simple enumerated state variable with two values: "_ENTERED" and "_NOT_ENTERED". Any functions with the modifier `nonReentrant` will require the state to be `_NOT_ENTERED`.

There are a few state variables that are simple `Counters`, `_itemIds` and `_itemsSold`, which likely keep track of all items on the market place, and how many have been sold. Why these are `Counters` and not something like a mapping with UUIDs, I'm not sure. But it seems to be a common practice so far from what I've seen to keep token IDs as simple counters? Or perhaps it's just simpler to show with the tutotials I'm following.

There is also an `address` as `payable`, called `owner`. Finally, there is a value `listingPrice` initialized to `0.025 ether`. 

### Methods

The constructor initializes the owner address with the sender's address. So I suppose this market contract is going to be executed per owner of digital assets, rather than as some wholistic view of all addresses and holdings.

There is a struct defined within the contract called `MarketItem`. This defines a few things:

```javascript
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
```

Pretty self explanatory, but this is a single item in the market and all the associated metadata that will be tracked with each market item. There's:

* the `itemId` which I guess will be an enumerated value, representing the ID of the item in the marketplace;
* the `nftContract` address (the contract we created before) of the minted digital asset as an address field;
* the `tokenId`, which is the address of the minted digital asset, i.e. the executed NFT contract of a single digital asset;
* the address of the `seller`, the `owner`, the `price` in wei; and whether or not the item has been `sold`.

There is another state variable called `idToMarketItem` which is a mapping from an `itemId` to an instance of a `MarketItem`.

A method called, `getListingPrice` which is a simple getter method that returns the fixed `listingPrice` variable of the `NFTMarket` contract.

Two `nonReentrant` methods handle creating and selling an item:

1. The `createMarketItem` method requires the `nftContract` address, the `tokenId`, and the `price` required to sell the item. This method looks a little different than I'd expect at the moment, as it seems like it requires the digital asset to already be minted via the NFT contract, and this marketplace is just handling the listing of the already minted asset. I suppose the UI will handle tying the execution of minting a digital asset, and the created `tokenId`, with this other `NFTMarket`'s `createMarketItem` method. Internally, this method is transfering the `nftContract`'s `tokenId` from the `msg.sender` to the address of the `NFTMarket` contract. This also seems a little strange to me, as it seems like by listing an item, the seller no longer owns the NFT, and it becomes the property of the marketplace. I suppose it's possible to de-list an item in a marketplace, but it seems like it is really up to the execution of that contract code to get back the ownership of the NFT.  

2. The `createMarketSale` method similarly requires the `nftContract` address, and the `itemId` being sold in order to transfer ownership of it. That will then transfer the `nftContract`'s `itemId`, as held by the `NFTMarket`'s address, to the `msg.sender`'s address.  

Finally, there are a few `fetch` methods that act as getter methods for different lists of `MarketItems`. There's one for all market items, `fetchMarketItems`, one for only items that the owner has purchased, `fetchMyNFTs`, and one for all listed items of the owner, `fetchItemsCreated`.

### Testing the Contracts

Since we're using hardhat, we can test our contract by creating a javascript function in the `test` folder. Create a file `test/sample-test.js` with the following:

```javascript
/* test/sample-test.js */
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarket", function() {
  it("Should create and execute market sales", async function() {
    /* deploy the marketplace */
    const Market = await ethers.getContractFactory("NFTMarket")
    const market = await Market.deploy()
    await market.deployed()
    const marketAddress = market.address

    /* deploy the NFT contract */
    const NFT = await ethers.getContractFactory("NFT")
    const nft = await NFT.deploy(marketAddress)
    await nft.deployed()
    const nftContractAddress = nft.address

    let listingPrice = await market.getListingPrice()
    listingPrice = listingPrice.toString()

    const auctionPrice = ethers.utils.parseUnits('1', 'ether')

    /* create two tokens */
    await nft.createToken("https://www.mytokenlocation.com")
    await nft.createToken("https://www.mytokenlocation2.com")

    /* put both tokens for sale */
    await market.createMarketItem(nftContractAddress, 1, auctionPrice, { value: listingPrice })
    await market.createMarketItem(nftContractAddress, 2, auctionPrice, { value: listingPrice })

    const [_, buyerAddress] = await ethers.getSigners()

    /* execute sale of token to another user */
    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, { value: auctionPrice})

    /* query for and return the unsold items */
    items = await market.fetchMarketItems()
    items = await Promise.all(items.map(async i => {
      const tokenUri = await nft.tokenURI(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      }
      return item
    }))
    console.log('items: ', items)
  })
})
```

The code is well documented already. The idea is to deploy both the marketplace contract and the NFT contract. Create 2 NFTs. Then list both NFTs. And get another address of someone that will then buy one of the tokens. Finally, we log all market items and since we've sold one item, we should only see the unsold item.

Open up two new terminal consoles, and navigate to the project directory. In one, we'll spin up a local test node:

```bash
$ npx hardhat node
```

In the other, we'll test our contracts:

```bash
$ npx hardhat test --network localhost
```

We should see in the node window the transactions of deploying and executing our contracts, and in the test output, the second item still being listed for sale:

```bash
Compiling 14 files with 0.8.4
Compilation finished successfully


  NFTMarket
items:  [
  {
    price: '1000000000000000000',
    tokenId: '2',
    seller: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    owner: '0x0000000000000000000000000000000000000000',
    tokenUri: 'https://www.mytokenlocation2.com'
  }
]
    ✓ Should create and execute market sales (3714ms)


  1 passing (4s)
  ```

