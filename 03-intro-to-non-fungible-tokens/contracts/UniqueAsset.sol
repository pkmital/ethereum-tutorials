pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract UniqueAsset is ERC721 {
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIds;
  mapping(string => uint8) hashes;

  constructor() public ERC721("UniqueAsset", "UNA") {

  }

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
    _mint(recipient, newItemId);

    // And add the metadata to the ID
    // _setTokenURI(newItemId, metadata);

    // Return the new ID
    return newItemId;
  }
}
