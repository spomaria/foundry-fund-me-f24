// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// --- TASK ---
// Get funds from users
// Withraw the funds
// Set a Minimum funding value in USD

// This named import enables us use the functionalities of the 
// PriceConverter library
import { PriceConverter } from "./PriceConverter.sol";
import { AggregatorV3Interface } from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// create custom errors for gas optimization
error FundMe_NotOwner();

contract FundMe {

    // This command will enable all variables of type uint256 to access the 
    // methods in the PriceConverter library
    using PriceConverter for uint256;

    AggregatorV3Interface private s_priceFeed;
    // Since ETH is equivalent to 1e18, we give our minimumUSD 18 zeros as well
    // since this value is set once and outside a function declaration,
    // We set it as constant to optimize gas
    uint256 public MINIMUM_USD = 5; //5e18

    // A list of addresses to keep track of funders
    // Make the contract gas efficient by changing the varibles from
    // public to private
    address[] private s_funders;
    mapping (address funders => uint256 amountFunded) private s_addressToAmountFunded;

    // Since the value of i_owner variable is set once during deployment and does not change,
    // We set it as immutable to optimize gas
    address private immutable i_owner;

    constructor(address priceFeed){
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function _onlyOwner() internal view {
        // require(msg.sender == i_owner, "Must be owner!");
        if (msg.sender != i_owner){
            revert FundMe_NotOwner();
        }
    }

    modifier onlyOwner(){
        _onlyOwner();
        _;
    }

    function fund() public payable {
        // allow users to send $
        // set a minimum amount a user can send
        // 1. How do we send ETH to this contract?
        //  We make the function payable so that is can send ETH
        require(msg.value.getConversionRate(s_priceFeed) > MINIMUM_USD, "didn't send enough ETH"); // 1e18 = 1ETH
        // require(msg.value > MINIMUM_USD, "didn't send enough ETH"); // 1e18 = 1ETH
        // Include this address in the list of funders
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    
    function withdraw() public onlyOwner {
        // Reset all contributions to zero using a for loop
        for(
            uint256 indexFunder; 
            indexFunder < s_funders.length; 
            indexFunder ++
        ){
            address funder = s_funders[indexFunder];
            s_addressToAmountFunded[funder] = 0;
            
        }

        // Reset the funders array
        s_funders = new address[](0);

        // There are three ways to withdraw the funds to the caller of the function
        // 1. transfer
        // We make the msg.sender address payable so as to recieve ether
        // Note that the transfer function reverts automatically when an error is encountered
        // payable(msg.sender).transfer(address(this).balance);

        // 2. send
        // Note that the send function does not revert automatically when an error is encountered
        // So, we use a require keyword to ensure it reverts in the event of any error
        // bool success = payable(msg.sender).send(address(this).balance);
        // require(success, "Send Failed");

        // 3. call
        // Note that the call function returns two variables, a bool and bytes.
        // However, we are only interested in the bool variable
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    function cheaperWithdraw() public onlyOwner {
        // Reset all contributions to zero using a for loop

        // creating this variable implies we are making 1 SLOAD
        // instead of n SLOAD - gas optimization
        uint256 fundersLength = s_funders.length;
        for(uint256 indexFunder; indexFunder < fundersLength;){
            address funder = s_funders[indexFunder];
            s_addressToAmountFunded[funder] = 0;
            // We use unchecked for gas optimization since we know
            // that our variable cannot overflow
            unchecked{
                indexFunder ++;
            }
        }

        // Reset the funders array
        s_funders = new address[](0);

        // There are three ways to withdraw the funds to the caller of the function
        // 1. transfer
        // We make the msg.sender address payable so as to recieve ether
        // Note that the transfer function reverts automatically when an error is encountered
        // payable(msg.sender).transfer(address(this).balance);

        // 2. send
        // Note that the send function does not revert automatically when an error is encountered
        // So, we use a require keyword to ensure it reverts in the event of any error
        // bool success = payable(msg.sender).send(address(this).balance);
        // require(success, "Send Failed");

        // 3. call
        // Note that the call function returns two variables, a bool and bytes.
        // However, we are only interested in the bool variable
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    // add the receive function to enable the contract take note of those who try 
    // to send ether without using the fund function
    receive() external payable { 
        // This function will route any user who tries to send some ether to the fund function
        // Thereby, adding such user to the list of funders
        fund();
    }

    fallback() external payable { 
        // This function will route any user who tries to send some ether to the fund function
        // In this way, any user that tries to send less than the minimum amount allowed 
        // and did not call the fund function will equally have their transaction reverted
        fund();
    }

    function getVersion() public view returns (uint256){
        return s_priceFeed.version();
    }

    /**
    * section for our View / Pure functions
     */

    function getAddressToAmountFunded(address fundinAddress) public view returns(
        uint256
    ){
        return s_addressToAmountFunded[fundinAddress];
    }

    function getFunder(uint256 index) public view returns(address){
        return s_funders[index];
    }

    function getOwner() public view returns(address){
        return i_owner;
    }
}