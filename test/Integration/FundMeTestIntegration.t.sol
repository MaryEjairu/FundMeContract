//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract InteractionsTest is Test {
   FundMe public fundMe;
   //DeployFundMe deployFundMe;

   address alice =makeAddr("alice"); // Our fake user is alice. ThIS IS MADE POSSIBLE WITH THE CHEATCODE "makeAddr"
   uint256 public constant SEND_VALUE = 0.1 ether; // To avoid magic numbers!!
   uint256 public constant STARTING_BALANCE = 10 ether;

   function setUp() external {
    //fundMe = new FundMe();
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    vm.deal(alice, STARTING_BALANCE); // Giving alice 10 ether to start out (fake) so the TX can run!!!. ThIS IS MADE POSSIBLE WITH THE CHEATCODE "vm.deal"
   
   }

   function testUserCanFundAndOwnerWithdraw() public {
    uint256 preUserBalance = address(alice).balance; // We record the starting balances for both user and owner.
     uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

     // Using vm.prank to simulate funding from the user address
     vm.prank(alice);
     fundMe.fund{value: SEND_VALUE}();

     WithdrawFundMe withdrawFundMe = new WithdrawFundMe(); // we withdraw.
     withdrawFundMe.withdrawFundMe(address(fundMe));

    uint256 afterUserBalance = address(alice).balance; // We record the ending balances,
    uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

    assert(address(fundMe).balance == 0); // Checking that endingFundMeBalance is 0 because we just withdrawed all funds out  of the contract.
    assertEq(afterUserBalance + SEND_VALUE, preUserBalance);  // Finding out the new user balance for the contract.
    assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);  // Finding out the new owner balance for the contract.

   }
}
