// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
//importing our Fundme contract
import { FundMe } from "../src/FundMe.sol";
import { DeployFundMe} from "../script/DeployFundMe.s.sol";

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
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        console.log(address(this));
        assertEq(fundMe.i_owner(), msg.sender);
        // assertEq(fundMe.i_owner(), address(this));
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
}