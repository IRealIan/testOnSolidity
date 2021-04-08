// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ImplData.sol";

contract MyToken is ImplData {

	/** Events **/
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

	/** Optional in ERC 721 */
  	modifier ownerOnly() {
      require(msg.sender == owner);
	  _;
	}
	function totalSupply() public view returns (uint256) {
    	return tokens.length;
  	}

	function balanceOf(address _owner) external view returns (uint){
		return tokensCount[_owner];
	}

	function safeTransferFrom(address from, address to, uint tokenId, bytes memory data) external payable {
		_safeTransferFrom(from,to,tokenId);
	}

	function safeTransferFrom(address from, address to, uint tokenId) external payable {
		_safeTransferFrom(from,to,tokenId);
	}

	function transferFrom(address from, address to, uint tokenId) external payable {
		_safeTransferFrom(from,to,tokenId);
	}

	function approve(address to, uint tokenId) external payable {
		address tokenOwner = MyToken.ownerOf(tokenId);
		require(msg.sender == tokenOwner || isApprovedForAll(owner, msg.sender));
		tokenApprovals[tokenId] = to;
		emit Approval(MyToken.ownerOf(tokenId), to, tokenId);
	}

	function setApprovalForAll(address operator, bool approved) external {
		require(operator != msg.sender);
		operatorApprovals[msg.sender][operator] = approved;
		emit ApprovalForAll(msg.sender, operator, approved);
	}

	function getApproved(uint tokenId) external view returns (address) {
		return tokenApprovals[tokenId];
	}

	function isApprovedForAll(address tokenOwner, address operator) public view returns (bool) {
		return operatorApprovals[tokenOwner][operator];
	}
	
    function mintToken(address to) external ownerOnly returns (uint tokenId) {
		Token memory token = Token({
			mintedBy: msg.sender,
			mintedAt: uint64(block.timestamp)
    	});
        // require(to != address(0), "ERC721: mint to the zero address");
        // require(!_exists(tokenId), "ERC721: token already minted");
		tokens.push(token);
		tokenId = tokens.length;
        tokensCount[to] += 1;
        owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

	/* helpers */
	function _safeTransfer(address from, address to, uint tokenId, bytes memory data) internal virtual {
		_safeTransferFrom(from, to, tokenId);
	}

	function _safeTransferFrom(address from, address to, uint tokenId) internal {
		require(owners[tokenId] == from,"ERC721: specified account can't transfer this token");
		require(msg.sender == from || msg.sender == tokenApprovals[tokenId] || operatorApprovals[from][msg.sender] == true, "ERC721: Not authorized");
		owners[tokenId] = to;
		tokensCount[from] -= 1;
		tokensCount[to] += 1;
		emit Transfer(from, to, tokenId);
	}
    function ownerOf(uint tokenId) public view virtual returns (address) {
        address tokenOwner = owners[tokenId];
        require(tokenOwner != address(0), "ERC721: owner query for nonexistent token");
        return tokenOwner;
    }
	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4) {
		
	}
}
