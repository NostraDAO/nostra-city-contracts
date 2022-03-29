// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


interface INOSTRATOOLS {
    function sendToTreasury() external returns (bool);
}

contract Treasury is Initializable{
    
    INOSTRATOOLS private _scissors;
    INOSTRATOOLS private _coffees;
    INOSTRATOOLS private _tomatoes;
    address public _manager;
    address public _competition_helper;

    //Events
    event WithdrawFromContracts();
    event PrizeManaged( address _token, uint256 amount );
    event TreasuryManaged( address _token, uint256 amount );

    //Modifiers
    modifier onlyManagerOrHelper() {
        require( _manager == msg.sender || _competition_helper == msg.sender, "Caller is not the Manager or the Helper" );
        _;
    }
    modifier onlyManager() {
        require( _manager == msg.sender , "Caller is not the Manager" );
        _;
    }

    // Initialize function
    function initialize (address BarberShopNFT, 
                         address DinerNFT, 
                         address GroceriesNFT, 
                         address competition_helper, 
                         address manager)
                         public initializer {
        _scissors = INOSTRATOOLS(BarberShopNFT);
        _coffees = INOSTRATOOLS(DinerNFT);
        _tomatoes = INOSTRATOOLS(GroceriesNFT);
        _competition_helper = competition_helper;
        _manager = manager;
    }   
    
    /**
     * withdrawFromContracts
     * @notice             withdraws the DAI from the NFT contracts to the treasury
     */
    function withdrawFromContracts() public onlyManagerOrHelper() {

        _scissors.sendToTreasury();
        _coffees.sendToTreasury();
        _tomatoes.sendToTreasury();
        emit WithdrawFromContracts();

    }
    /**
     * managePrize
     * @notice             withdraws the prize from the Treasury to the Manager account
     */
    function managePrize( address _token ) external onlyManager() {

        uint256 amount = (getTotalTreasuryValue()*20)/100;
        IERC20( _token ).transferFrom(address(this), _manager, amount);
        emit PrizeManaged( _token, amount );
    }
    /**
     * manageAssets
     * @notice             moves assets from the Treasury to the Manager account
     */
    function manageAssets( address _token, uint256 _amount ) external onlyManager() {
        require(_amount <= getTotalTreasuryValue(), 'Not enough funds');
        IERC20( _token ).transferFrom(address(this), _manager, _amount);
        emit TreasuryManaged( _token, _amount );
    }
     /**
     * setCompetitionHelper
     * @notice                   sets the competitionHelper address
     * @param competition_helper the competitionHelper contract's address
     */
    function setCompetitionHelper(address competition_helper) public onlyManager(){
        _competition_helper = competition_helper;

    }
    /**
     * setManager
     * @notice                   sets the Manager address
     * @param manager            manager's address
     */
    function setManager(address manager) public onlyManager() {
        _manager = manager;

    }
     /**
     * getTotalTreasuryValue
     * @notice                   returns the total value of the treasury in Avax
     * @return balance           Avax balance
     */
    function getTotalTreasuryValue() public view returns (uint256){

        return address(this).balance;

    }



}