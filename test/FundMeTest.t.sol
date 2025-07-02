// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18, "Should be 5e18");
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), address(this), "Owner should be msg.sender");
    }
}
