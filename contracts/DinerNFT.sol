// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NostraCityDiner is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public constant MAX_SUPPLY = 20000;
    uint256 public constant MAX_PUBLIC_MINT = 40;
    uint256 MINT_PRICE = 50;//DAI
    address private _vault;
    IERC20 private _DAI;
    //EVENTS
    //TODO: ADD EVENTS
    /** Mappings */
	mapping(address => bool) public presaleWhitelistTier1;
    mapping(address => bool) public presaleWhitelistTier2;

    modifier onlyVault() {
    require( _vault == msg.sender, "Caller is not the Vault" );
    _;
  }

    constructor(IERC20 DAI) ERC721("NostraCityDiner", "NCBS") {
        _DAI = DAI;
    }


    function _baseURI() internal pure override returns (string memory) {
        //TODO: Set baseURI
        return "https://...";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri, uint8 numberOfTokens) public onlyOwner payable {
        uint256 ts= totalSupply();
        uint256 mintingPrice = getMintingPrice();
        require(!mintingPaused, 'Minting is paused');
		require(numberOfTokens > 0, 'Mint at least 1 Diner Coffee');
        require(presaleWhitelist1[msg.sender] || presaleWhitelist1[msg.sender] , 'Wallet not whitelisted');
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        safeTransferFrom(address(_DAI), msg.sender, address(this), mintingPrice * numberOfTokens);
   
        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        }
        
    }
    /**
     */
    function getMintingPrice(){

        if (presaleWhitelist1[msg.sender]){
           return (MINT_PRICE*20)/100;
        } 
        else if (presaleWhitelist2[msg.sender]) {
            return (MINT_PRICE*40)/100;
        } 
        else {
            return MINT_PRICE;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    /**
	 * 
	 */
	function whitelistTier1(address wallet, bool status) public onlyOwner {
		presaleWhitelistTier1[wallet] = status;
	}
    /**
	 * 
     *
	 */
    function whitelistTier2(address wallet, bool status) public onlyOwner {
		presaleWhitelistTier2[wallet] = status;
	}
    function sendToTreasury() public onlyVault() {
		//
	}
    function getCurrentId() public  {
		return  _tokenIdCounter.current();
	}
    

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}