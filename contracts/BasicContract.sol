// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// BasicContract contract, version 1
contract BasicContract {
  // state
  uint state;

  // transactional function to store a value on the blockchain
  function set(uint document) public {
    state = document;
  }

  // get the stored value on the blockchain
  function get() public view returns (uint) {
    return state;
  }
}
