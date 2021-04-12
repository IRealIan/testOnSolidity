// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogicData {
	/** Structures */
	struct Token {
    	address mintedBy;
    	uint64 mintedAt;
  	}

	Token[] tokens;
	// Token count
	mapping(address => uint) tokensCount;	
	// Mapping from token ID to owner address
	mapping(uint => address) owners;
	// Mapping from owner to operator approvals
	mapping (address => mapping (address => bool)) operatorApprovals;
	// Mapping from token ID to approved address
	mapping (uint => address) tokenApprovals;
}
