// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;



contract CompetitionHelper {

    INOSTRATOOLS _scissors;
    INOSTRATOOLS _coffees;
    INOSTRATOOLS _tomatoes;
    ITreasury _vault;
    address public _winner;

    constructor (address BarberShop, address Diner, address GroceryStore, address treasury){
        BarberShop
        Diner
        GroceryStore
    }
    /**
     */
    function finishSeasonCleanUp(){
        //Pause NFTs
        _scissors.pause();
        _coffees.pause();
        _tomatoes.pause();
        //Run the Treasury Function to retrieve the Balance fromm the NFTs
        _vault.withdrawFromContracts();
        //Calculate Winner
        _winner = calculateWinner();

    }
    /**
     */
    function calculateWinner(){
        uint256 barberShopScore = _scissors.getCurrentScore();
        uint256 dinerScore = _coffees.getCurrentScore();
        uint256 groceryStoreScore = _tomatoes.getCurrentScore();
        //Find if there are ties
        //
        if (){

        }

        //Find the winner
        if (barberShopScore > dinerScore){
            if (barberShopScore > groceryStoreScore){
                return barberShopScore;
            }
            else if (groceryStoreScore > dinerScore){
                return groceryStoreScore;
            }
        else if (dinerScore > barberShopScore)

        }

    }
    /**
     */
    function getWinnerFromSeason() returns (address){
        return _winner:
    }
}