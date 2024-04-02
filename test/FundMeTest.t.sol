// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
//importing our Fundme contract
import { FundMe } from "../src/FundMe.sol";
import { DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    // defining variable 'fundMe' of type FundMe
    FundMe fundMe;
    // This function sets up the test environment
    function setUp() external{
        // deploy an instance of the FundMe contract
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumUsdIsFive() public view{
        assertEq(fundMe.MINIMUM_USD(), 1e17);
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
}