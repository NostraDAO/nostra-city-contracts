// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface INOSTRATOOLS {
    function pause() external;
    function getCurrentScore() external returns (uint256);
}

interface ITreasury {
    function withdrawFromContracts() external returns (bool);
    function getCurrentScore() external returns (uint256);
}

contract CompetitionHelper is Initializable{

    INOSTRATOOLS public _scissors;
    INOSTRATOOLS private _coffees;
    INOSTRATOOLS private _tomatoes;
    ITreasury _vault;
    address public _manager;

    modifier onlyManager() {
        require( _manager == msg.sender , "Caller is not the Manager" );
        _;
    }

	mapping(address => uint256) public businessToScore;
    mapping(address => bool) public businessIsWinner;

    function initialize (address BarberShop, 
                         address Diner, 
                         address GroceryStore) 
                         public initializer {
       _scissors = INOSTRATOOLS(BarberShop);
       _coffees =  INOSTRATOOLS(Diner);
       _tomatoes = INOSTRATOOLS(GroceryStore);
    }
    /**
     */
    function finishSeasonCleanUp() public onlyManager(){
        //Pause NFTs
        _scissors.pause();
        _coffees.pause();
        _tomatoes.pause();
        //Run the Treasury Function to retrieve the Balance fromm the NFTs
        _vault.withdrawFromContracts();
        //Calculate Winner
        calculateWinner();
        //TODO: Emit event.
    }
    /**
     */
    function calculateWinner() private  {
        businessToScore[address(_scissors)] = INOSTRATOOLS(_scissors).getCurrentScore();
        businessToScore[address(_coffees)] = INOSTRATOOLS(_coffees).getCurrentScore();
        businessToScore[address(_tomatoes)] = INOSTRATOOLS(_tomatoes).getCurrentScore();
        //Find if there are three way tie
        if (businessToScore[address(_scissors)] == businessToScore[address(_coffees)] &&
           businessToScore[address(_coffees)] ==  businessToScore[address(_tomatoes)] ){
            businessIsWinner[address(_scissors)] = true;
            businessIsWinner[address(_coffees)] = true;
            businessIsWinner[address(_tomatoes)] = true;
        }
        else{
        //Find the winner and ties
         if(businessToScore[address(_scissors)] > businessToScore[address(_coffees)] ) {
            if(businessToScore[address(_scissors)] > businessToScore[address(_tomatoes)]){
                businessIsWinner[address(_scissors)] = true;
            }
            else if (businessToScore[address(_scissors)] == businessToScore[address(_tomatoes)]){
                businessIsWinner[address(_scissors)] = true;
                businessIsWinner[address(_tomatoes)] = true;
            }
            else{
               businessIsWinner[address(_tomatoes)] = true;
               }
        } 
        else if (businessToScore[address(_scissors)] == businessToScore[address(_coffees)]
                && businessToScore[address(_scissors)] > businessToScore[address(_tomatoes)] ){
                    businessIsWinner[address(_scissors)] = true;
                    businessIsWinner[address(_coffees)] = true;
        }
        else {
            if(businessToScore[address(_coffees)] > businessToScore[address(_tomatoes)]){
                businessIsWinner[address(_coffees)] = true;
                }
            else if (businessToScore[address(_coffees)] == businessToScore[address(_tomatoes)]){
                    businessIsWinner[address(_coffees)] = true;
                    businessIsWinner[address(_tomatoes)] = true;
            }
            else{ 
                businessIsWinner[address(_tomatoes)]= true;
            }
               
        }
        }

    }

    
    /**
     */
    function isAddressWinner(address business) public view returns (bool){
        return businessIsWinner[business];
    }

      /**
     */
    function setVault(address vault) public onlyManager {
        //TODO: Emit EVENT
        _vault = ITreasury(vault);
    }
   
}