// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";



contract FundFundMe is Script {
    uint256 constant SEND_VALUE =  0.1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded Fund with %s", SEND_VALUE);

    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");

    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}