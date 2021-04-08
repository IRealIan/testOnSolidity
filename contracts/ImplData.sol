// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ImplData {
    // Le mot clé internal peut être omis
	address proxyImplementation;
	address owner = msg.sender;
	address contractImplementation;

	/** Structures */
	struct Token {
    	address mintedBy;
    	uint64 mintedAt;
  	}

	Token[] tokens;
	// Token count
	mapping(address => uint) private tokensCount;	
	// Mapping from token ID to owner address
	mapping(uint => address) private owners;
	// Mapping from owner to operator approvals
	mapping (address => mapping (address => bool)) private operatorApprovals;
	// Mapping from token ID to approved address
	mapping (uint => address) private tokenApprovals;
}
