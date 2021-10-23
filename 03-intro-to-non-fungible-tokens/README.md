# Introduction

I'm following along [here](https://medium.com/pinata/how-to-build-erc-721-nfts-with-ipfs-e76a21d8f914), which uses truffle, but attempting to use hardhat instead. First get setup:

```bash
$ npm init
$ npm install --save-dev hardhat
```
I'm going to specify to use hardhat with typescript.

```bash
$ npx hardhat 
$ npm install --save-dev @nomiclabs/hardhat-waffle@^2.0.0 ethereum-waffle@^3.0.0 chai@^4.2.0 @nomiclabs/hardhat-ethers@^2.0.0 ethers@^5.0.0
```

NFTs are created using ERC-721 contracts on the ethereum blockchain. OpenZeppelin has some great guides and content for getting started.

```bash
$ npm install --save-dev @openzeppelin/contracts
```
Then start a basic contract for our new NFT called `contracts/MyNewNFT.sol`:

```javascript
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract UniqueAsset is ERC721{
  constructor() public ERC721("UniqueAsset", "UNA") {}
}
```

We'll want to add two basic ideas to this contract:

* Metadata linked to an IPFS hash
* Verifiable content hash from IPFS

OpenZeppeling provides some counter code for us which we'll use to indicate the token's ID:

```javascript
import "@openzeppelin/contracts/utils/Counters.sol"
using Counters for Counters.Counter;
Counters.Counter private _tokenIds;
```

We'll also keep track of all hashes and which token id they refer to:
```
mapping(string => uint8) hashes;
```
Putting it together, it should look like:

```javascript
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract UniqueAsset is ERC721 {
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIds;
  mapping(string => uint8) hashes;

  constructor() public ERC721("UniqueAsset", "UNA") {}
}
```

We'll now write a method to modify the state of our hashes and to write a new token ID for the given content:

```javascript
function awardItem(
    address recipient,      // the wallet address of the person minting the NFT
    string memory hash,     // the ipfs hash of the content we're minting
    string memory metadata  // a link including any JSON metadata for the NFT asset
)
  public                    // can be called outside the contract
  returns (uint256)         // returning the NFT's ID
{
  // reject using solidity's require method if the
  // hash exist, i.e. we've minted this content before
  require(hashes[hash] != 1);
  hashes[hash] = 1;
  _tokenIds.increment();
  uint256 newItemId = _tokenIds.current();
  _mint(recipient, newItemId);
  _setTokenURI(newItemId, metadata);
  return newItemId;
}
```
