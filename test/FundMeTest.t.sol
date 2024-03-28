// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
//importing our Fundme contract
import { FundMe } from "../src/FundMe.sol";

contract FundMeTest is Test{
    FundMe fundMe;
    // This function sets up the test environment
    function setUp() external{
        // deploy an instance of the FundMe contract
        fundMe = new FundMe();
    }

    function testMinimumUsdIsFive() public view{
        assertEq(fundMe.MINIMUM_USD(), 1e17);
    }

    function testOwnerIsMsgSender() public view{
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        console.log(address(this));
        // assertEq(fundMe.i_owner(), msg.sender);
        assertEq(fundMe.i_owner(), address(this));
    }
}