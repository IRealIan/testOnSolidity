// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    Proxy : this is the main contract calling an implementation of a proxy (calling the main contract).
    We are able to update our main contract but also proxy features
    In order to avoid storage collisions, MyToken extends ImplData : a special contract made for state variable declarations 
    Proxy --> ProxyImpl --> MyToken (extends ImplData)
 */
contract Proxy {
	address proxyImplementation;
	address owner = msg.sender;

	// Upgrade logic contract
    function upgradeProxyContract(address newContractAddress) public {
        require(msg.sender == owner);
        proxyImplementation = newContractAddress;
    }

	// Get current implementation address
	function implementationProxyAddress() public view returns(address impl) {
		impl = proxyImplementation;
	}

    fallback() external payable {
        address proxyImpl = proxyImplementation;
        assembly {
            let _target := proxyImpl // sload(0)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
    }

    receive() virtual external payable{
       require(false, "Impossible to send ethereum to this address");
    }
}
