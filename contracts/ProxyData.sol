// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyData {
	address contractImplementation;
	address owner = msg.sender;

    string public constant name = "ERC721-UPG";
    string public constant symbol = "ERCI";
}
