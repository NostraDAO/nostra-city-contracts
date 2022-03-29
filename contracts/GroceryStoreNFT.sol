// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract NostraCityGroceryStore is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 public constant MAX_SUPPLY = 1500;
    uint256 public constant MAX_TIER1_MINT = 50;
    uint256 public constant MAX_TIER2_MINT = 25;
    uint256 public constant MINT_PRICE = 200*1000000000000000000;//DAI
    IERC20 private _DAI;
    address private _vault;
    uint public _score = 0;

    //Events
    event sentToTreasury();

    //Mappings
	mapping(address => bool) public presaleWhitelistTier1;
    mapping(address => bool) public presaleWhitelistTier2;
    mapping(address => uint256) public addressToTokensMinted;

    //Modifiers
    modifier onlyVault() {
    require( _vault == msg.sender, "Caller is not the Vault" );
    _;
  }

    constructor(address DAI) ERC721("Tomato", "NCGS") {
        _DAI = IERC20(DAI);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
     /**
     * SafeMint
     * @notice                        mints the number of tokens requested if all the conditions are met
     * @param numberOfTokens          number of tokens to be minted
     */
    function safeMint(uint8 numberOfTokens) public  {
        uint256 ts= totalSupply();
        uint256 mintingPrice = getMintingPrice(msg.sender);
        uint256 totalMintAmountInDAI = mintingPrice * numberOfTokens;
        uint256 mintLimit = getMintingLimit(msg.sender);
        require(_DAI.balanceOf(msg.sender) >= totalMintAmountInDAI, 'Your Wallet does not have enough DAI');
		require(numberOfTokens > 0, 'Mint at least 1 tomato');
        require(numberOfTokens + addressToTokensMinted[msg.sender] <= mintLimit, 'You have reached your limit of tokens');
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        
        _DAI.transferFrom(msg.sender , address(this), totalMintAmountInDAI);
        _score = _score + totalMintAmountInDAI;
        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, "https://gateway.pinata.cloud/ipfs/QmTrTBEc1LDSHsuqoaNRMr66aXsZabKQgQf9sa77DDiquH");
        }

        addressToTokensMinted[msg.sender] = addressToTokensMinted[msg.sender] + numberOfTokens;

    }
  /**
     * GetMintingLimit
     * @notice                   returns the limit of the tokens an address can mint
     * @param  wallet            the address to be checked
     * returns                  the number of tokens the address can mint
     */
    function getMintingLimit(address wallet) public view returns (uint256) {

        if (presaleWhitelistTier1[wallet]){
           return MAX_TIER1_MINT;
        } 
        else if (presaleWhitelistTier2[wallet]) {
            return MAX_TIER2_MINT;
        } 
        else {
            return MAX_SUPPLY;
        }
    }

     /**
     * GetMintingPrice
     * @notice             returns the minting price from an specific address
     * @param wallet       the address that will be requested to view the price
     * @return MINT_PRICE  returns the mint price depending on the whitelist tier
     */
     function getMintingPrice(address wallet) public view returns (uint256) {

        if (presaleWhitelistTier1[wallet]){
           return (MINT_PRICE*20)/100;
        } 
        else if (presaleWhitelistTier2[wallet]) {
            return (MINT_PRICE*40)/100;
        } 
        else {
            return MINT_PRICE;
        }
    }
    /**
     * WalletOfOwner
     * @notice             returns the list of all owned tokens from an specific address
     * @param  wallet      the address to be checked
     * @return tokenIds    the list of tokens owned by the address
     */
    function walletOfOwner(address wallet) public view returns (uint256[] memory){
        uint256 ownerTokenCount = balanceOf(wallet);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
        tokenIds[i] = tokenOfOwnerByIndex(wallet, i);
        }
        return tokenIds;
    }
    /**
	 * BeforeTokenTransfer
     * @notice     from Open Zeppelin wizard contract
     * @param from address from the token is transferred
     * @param to   address to the token is sent
	 */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    /**
     * WhitelistTier1
     * @notice             adds or removes an address whitelist tier 1 status
     * @param wallet       the address to be whitelisted
     * @param status       the status of the current address
     */
	function whitelistTier1(address wallet, bool status) public onlyOwner {
		presaleWhitelistTier1[wallet] = status;
	}
    /**
     * WhitelistTier2
     * @notice             adds or removes an address whitelist tier 2 status
     * @param wallet       the address to be whitelisted
     * @param status       the status of the current address
     */
    function whitelistTier2(address wallet, bool status) public onlyOwner {
		presaleWhitelistTier2[wallet] = status;
	}
    /**
     * SendToTreasury
     * @notice             sends DAI from the NFT contract to the treasury
     */
    function sendToTreasury() public onlyVault() returns (bool) {
        emit sentToTreasury();
		return _DAI.transferFrom(address(this), _vault, _DAI.balanceOf(address(this)));
	}

  /**
     * getCurrentScore
     * @notice             returns the current score the business has in the competition
     * @return _score    the score number for the business
     */
    function getCurrentScore() public view returns (uint256)  {
		return  _score;
	}
    
    /**
     * setVault
     * @notice           sets the Treasury address
     * @param vault     Treasury address
     */
    function setVault(address vault) public  onlyOwner  {
		_vault = vault;
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