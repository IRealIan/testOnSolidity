// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyImpl {
	address proxyImplementation;
	address owner = msg.sender;
	address contractImplementation;

    string public constant name = "ERC721-UPG";
    string public constant symbol = "ERCI";

	// Upgrade logic contract
    function upgradeContract(address newContractAddress) public {
        require(msg.sender == owner);
        contractImplementation = newContractAddress;
    }

	// Get current implementation address
	function implementationContractAddress() public view returns(address impl) {
		impl = contractImplementation;
	}

    fallback() external payable {
        address impl = contractImplementation;
        assembly {
            let _target := impl // sload(0)
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
