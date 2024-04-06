// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
//importing our Fundme contract
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    // defining variable 'fundMe' of type FundMe
    FundMe fundMe;

    // create a fake user
    address USER = makeAddr("Spo");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    // This function sets up the test environment
    function setUp() external{
        // deploy an instance of the FundMe contract
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // use a cheatcode to allocate some ETH to USER
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserHasEthDeposited() public view{
        assertEq(USER.balance, STARTING_BALANCE);
    }

    function testMinimumUsdIsFive() public view{
        assertEq(fundMe.MINIMUM_USD(), 5);
    }

    function testOwnerIsMsgSender() public view{
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        console.log(address(this));
        assertEq(fundMe.getOwner(), msg.sender);
        // assertEq(fundMe.getOwner(), address(this));
    }

    function testPriceFeedVersionIsActive() public view{
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public{
        vm.prank(USER);
        vm.expectRevert(); //expect the next lines of code to revert
        // assert(This tx fails/reverts)
        // uint256 cat = 1;
        fundMe.fund(); // send 0 ETH
    }

    // since we will need to fund the contract for quite a number of 
    // tests to be carried out, we create a modifier to make our test functions
    // more concise and easy to read
    modifier funded(){
        vm.prank(USER); // Next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
    function testFundUpdatesFundedDataStructures() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        console.log(amountFunded);
        console.log(SEND_VALUE);
        console.log(USER.balance);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // USER should send some funds to the contract
        // Sending funds to the contract is important so that when the test fails
        // as expected, it is not due to lack of funds in the contract
        
        vm.prank(USER);
        vm.expectRevert(); // we expect test to fail since USER is not the owner
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange

        // get the balance of the owner before the withdrawal
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        // balance of the contract before withdrawal
        uint256 fundMeStartingBalance = address(fundMe).balance;

        // Act
        // withdraw the funds to owner address
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert

        // check if owner balance has increased
        uint256 ownerEndingBalance = fundMe.getOwner().balance;
        uint256 fundMeEndingBalance = address(fundMe).balance;
        console.log(fundMeStartingBalance);
        console.log(ownerStartingBalance);
        console.log(fundMeEndingBalance);
        console.log(ownerEndingBalance);
        assertEq(fundMeEndingBalance, 0);
        assertEq(ownerEndingBalance, ownerStartingBalance + fundMeStartingBalance);
        
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange


        // We use a for loop to create other fake users
        // and have them send ETH to the contract
        // We shall use uint160 so that we can use it to
        // generate addresses for our fake users instead of a 
        // name as in makeAddr("Spo")
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(
            uint160 i = startingFunderIndex; i < numberOfFunders; i++
        ){
            // vm.prank and vm.deal are all carried out
            // in hoax
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        // get the balance of the owner before the withdrawal
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        // balance of the contract before withdrawal
        uint256 fundMeStartingBalance = address(fundMe).balance;

        // Act
        // withdraw the funds to owner address
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert

        // check if owner balance has increased
        uint256 ownerEndingBalance = fundMe.getOwner().balance;
        uint256 fundMeEndingBalance = address(fundMe).balance;
        console.log(fundMeStartingBalance);
        console.log(ownerStartingBalance);
        console.log(fundMeEndingBalance);
        console.log(ownerEndingBalance);
        assertEq(fundMeEndingBalance, 0);
        assertEq(ownerEndingBalance, ownerStartingBalance + fundMeStartingBalance);
        
    }

    function testCheaperWithdrawFromMultipleFunders() public funded {
        // Arrange


        // We use a for loop to create other fake users
        // and have them send ETH to the contract
        // We shall use uint160 so that we can use it to
        // generate addresses for our fake users instead of a 
        // name as in makeAddr("Spo")
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(
            uint160 i = startingFunderIndex; i < numberOfFunders; i++
        ){
            // makeAddr, vm.deal and vm.prank are all carried out
            // in hoax
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        // get the balance of the owner before the withdrawal
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        // balance of the contract before withdrawal
        uint256 fundMeStartingBalance = address(fundMe).balance;

        // Act
        // withdraw the funds to owner address using cheaperWithdraw
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        // Assert

        // check if owner balance has increased
        uint256 ownerEndingBalance = fundMe.getOwner().balance;
        uint256 fundMeEndingBalance = address(fundMe).balance;
        console.log(fundMeStartingBalance);
        console.log(ownerStartingBalance);
        console.log(fundMeEndingBalance);
        console.log(ownerEndingBalance);
        assertEq(fundMeEndingBalance, 0);
        assertEq(ownerEndingBalance, ownerStartingBalance + fundMeStartingBalance);
        
    }
}