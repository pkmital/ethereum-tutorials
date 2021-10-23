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
Then start a basic contract for our new NFT called `contracts/UniqueAsset.sol`:

```javascript
pragma solidity ^0.8.0;

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
pragma solidity ^0.8.0;

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

  // Setting the state of our internal hashes mapping to indicate
  // this is now "minted"
  hashes[hash] = 1;

  // Update global increment state
  _tokenIds.increment();

  // get the new id of our NFT which is just a simple counter
  uint256 newItemId = _tokenIds.current();

  // some method to mint this address with the item's ID
  // where is this defined?
  _mint(recipient, newItemId);

  // And add the metadata to the ID (this results in compile error)
  //_setTokenURI(newItemId, metadata);

  // Return the new ID
  return newItemId;
}
```

Let's test this and deploy it!

```bash
$ npx hardhat compile
```

Now we'll write a function to deploy it and use hardhat to deploy:

```bash
$ npx hardhat run scripts/deploy.ts
```

This will say the contract has been deployed to an address, such as "UniqueAsset deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"

Let's check the hardhat console now:

```bash
$ npx hardhat console
```

Inside we can get our contract:

```bash
> const Token = await ethers.getContractFactory("UniqueAsset")
> Token
```

We'll attach this token to our deployed contract address printed out before:

```bash
> const token = await Token.attach("0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512")
```

We can mint something now using our `awardItem` method, like so:

```bash
> var recipient = '0x70997970C51812dc3A010C7d01b50e0d17dc79C8'
> var hash = "..."
> var metadata = "..."
> const result = await token.awardItem(recipient, hash, metadata)
> result
```
