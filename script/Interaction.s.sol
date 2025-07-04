// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant FUND_AMOUNT = 0.1 ether;

    function fundFundMe(address mostRecentDeploy) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeploy)).fund{value: FUND_AMOUNT}();
        console.log(
            "Funded contract at address: %s with amount: %s",
            mostRecentDeploy,
            FUND_AMOUNT
        );
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeploy = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentlyDeploy);
    }
}

contract WithdrawFundMe is Script {
    uint256 constant FUND_AMOUNT = 0.1 ether;

    function withdrawFundMe(address mostRecentDeploy) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeploy)).cheaperWithdraw();
        console.log(
            "Funded contract at address: %s with amount: %s",
            mostRecentDeploy,
            FUND_AMOUNT
        );
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeploy = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeploy);
    }
}
