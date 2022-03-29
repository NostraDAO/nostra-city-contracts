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

    //Modifiers
    modifier onlyManager() {
        require( _manager == msg.sender , "Caller is not the Manager" );
        _;
    }

    //Mappings
	mapping(address => uint256) public businessToScore;
    mapping(address => bool) public businessIsWinner;

    //Events
    event SeasonEnded();

    function initialize (address BarberShop, 
                         address Diner, 
                         address GroceryStore, address manager) 
                         public initializer {
       _scissors = INOSTRATOOLS(BarberShop);
       _coffees =  INOSTRATOOLS(Diner);
       _tomatoes = INOSTRATOOLS(GroceryStore);
       _manager = manager;
    }
    /**
     * finishSeasonCleanUp
     * @notice                        when the season ends the NFT sales are paused, 
     *                                the DAI is sent to the treasury and the winner is calculated
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

        emit SeasonEnded();
    }
    /**
     * calculateWinner
     * @notice                        checks the scores of each business and assigns the winner of a season
     * TODO:                          improve the implementation of this method by allowing
                                      more players to enter the game and win
     */
    function calculateWinner() private  onlyManager() {
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
     * isAddressWinner
     * @notice                        returns true of the business contract address was a winner and false if it was not
     * @return businessIsWinner[business]          the status of the winning business
     */
    function isAddressWinner(address business) public view returns (bool){
        return businessIsWinner[business];
    }

   /**
     * setVault
     * @notice                        sets the Treasury address on the contract
     * @param vault                   The Treasury address
     */
    function setVault(address vault) public onlyManager {

        _vault = ITreasury(vault);
    }
   
}