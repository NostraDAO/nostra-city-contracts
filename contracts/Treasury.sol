// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


interface INOSTRATOOLS {
    function sendToTreasury();
}

contract Treasury {
    
    INOSTRATOOLS private _scissors;
    INOSTRATOOLS private _coffees;
    INOSTRATOOLS private _tomatoes;
    address public _manager;
    address public _competition_helper;

    //TODO: Add Events

    modifier onlyManagerOrHelper() {
        require( _manager == msg.sender || _helper = msg.sender, "Caller is not the Manager or the Helper" );
        _;
    }

    constructor(address BarberShopNFT, address DinerNFT, address GroceriesNFT, address competition_helper, address manager){
        _scissors = INOSTRATOOLS(BarberShopNFT);
        _coffees = INOSTRATOOLS(DinerNFT);
        _tomatoes = INOSTRATOOLS(GroceriesNFT);
        _competition_helper = competition_helper;
        _manager = manager;
    }   

    function withdrawFromContracts() onlyManagerOrHelper() {
        // EMIT EVENT
        _scissors.sendToTreasury();
        _coffees.sendToTreasury();
        _tomatoes.sendToTreasury();

    }

    function managePrize( address _token ) external onlyManager() {

        uint256 amount = (getTotalTreasuryValue()*20)/100;
        IERC20( _token ).safeTransfer( msg.sender, amount );
        emit PrizeManaged( _token, amount );
    }

    function manageAssets( address _token, uint256 _amount ) external onlyManager() {
        require(_amount <= getTotalTreasuryValue(), 'Not enough funds');
        IERC20( _token ).safeTransfer( msg.sender, _amount );
        emit TreasuryManaged( _token, _amount );
    }

    function setCompetitionHelper(address competition_helper){
        _competition_helper = competition_helper;

    }

    function setManager(address manager) public {
        manager = _manager;

    }

    function getTotalTreasuryValue() public view returns (uint256){

        return address(this).balance;

    }

    

}