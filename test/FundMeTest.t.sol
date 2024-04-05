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
        vm.expectRevert(); //expect the next lines of code to revert
        // assert(This tx fails/reverts)
        // uint256 cat = 1;
        fundMe.fund(); // send 0 ETH
    }

    function testFundUpdatesFundDataStructures() public{
        vm.prank(USER); // Next tx will be sent by USER

        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
}