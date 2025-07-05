//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {PriceConverter} from "../src/PriceConverter.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
   FundMe fundMe;

   address alice =makeAddr("alice"); // Our fake user is alice. ThIS IS MADE POSSIBLE WITH THE CHEATCODE "makeAddr"
   uint256 constant SEND_VALUE = 0.1 ether; // To avoid magic numbers!!
   uint256 constant STARTING_BALANCE = 10 ether;
   uint256 constant GAS_PRICE = 1;

   function setUp() external {
    //fundMe = new FundMe();
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    vm.deal(alice, STARTING_BALANCE); // Giving alice 10 ether to start out (fake) so the TX can run!!!. hIS IS MADE POSSIBLE WITH THE CHEATCODE "vm.deal"
   
   }

   function testMinimumDollarIsFive() public   {
    assertEq(fundMe.minimumUSD(), 5e18);
   }

   function testOwnerIsMsgSender() public {
    console.log(fundMe.getOwner());
    console.log(msg.sender);
    assertEq(fundMe.getOwner(), msg.sender);
   }

   function testPriceFeedVersionIsAccurate() public {
    if (block.chainid == 11155111) {
      uint256 version = fundMe.getVersion();
      assertEq(version, 4);
    } else if (block.chainid  == 1) {
      uint256 version =fundMe.getVersion();
      assertEq(version, 6);
    }
   }

   function testFundFailsWithoutEnoughETH() public {
      vm.expectRevert();  // The next line after this one should revert! If not test fails.
      fundMe.fund(); // We send 0 value.
   }

   function testFundUpdatesFundedDataStructure () public {
      vm.prank(alice); // The next TX IS SENT BY alice.
     fundMe.fund{value: SEND_VALUE}(); // We are funding the contract 10 ether. 

      uint256 amountFunded = fundMe.getAddressToAmountFunded(alice);
      assertEq(amountFunded, SEND_VALUE);
   }

   function testAddsFunderToArrayOfFunders() public {
      vm.startPrank(alice);
      fundMe.fund{value: SEND_VALUE}();
      vm.stopPrank();

      address funder  = fundMe.getFunder(0);
      assertEq(funder, alice);
   }

   modifier funded() { // Modifier for funding our fake user, alice.
      vm.prank(alice);
      fundMe.fund{value: SEND_VALUE}();
      assert(address(fundMe).balance > 0);
      _;
   }

   function testOnlyOwnerCanWithdraw() public funded {
      vm.expectRevert();
      vm.prank(alice);
      fundMe.withdraw();

   }

   function testWithdrawWithASingleFunder() public funded { // Checking the owner can withdraw when the contract is funded by a single user.
      // Arrange
      uint256 startingFundMeBalance = address(fundMe).balance;   // Checking the initial ballance of the contract.
      uint256 startingOwnerBalance  = fundMe.getOwner().balance; // Checking the initial ballance of the owner.

      vm.txGasPrice(GAS_PRICE); // vm.txGasPrice sets up the tranaction gas price for the next transaction. GAS OPTIMIZATION
      uint256 gasStart = gasleft(); // gasLeft() is a built-in solidity function that returns the amount of gas remaining in the current Ethereum transaction.

      // Act
      vm.startPrank(fundMe.getOwner());
      fundMe.withdraw(); // The owner withdrawing all funds. 

      vm.stopPrank();

      uint256 gasEnd = gasleft(); // We are calculating the amount of gas used.
      uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
      console.log("Withdraw consumed: %d gas", gasUsed);

      // Assert
      uint256 endingFundMeBalance = address(fundMe).balance; // Finding out the new balance for the contract.
      uint256 endingOwnerBalance = fundMe.getOwner().balance;
      assertEq(endingFundMeBalance, 0); // Checking that endingFundMeBalance is 0 because we just withdrawed all funds out  of the contract.
      assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);

    }

   function testWithdrawFromMultipleFunders() public funded { // Checking the owner can withdraw when the contract is funded by a MULTIPLE user.
     // ARRANGE
     uint160 numberOfFunders = 10; // This is an total number of funders address. that is why we use uint160.
     uint160 startingFunderIndex = 1; // We start our index from 1 because it is not advised to use address(0) in this way.
     for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
      // we get hoax from stdcheats.
      // prank + deal = hoax.
      hoax (address(i), SEND_VALUE); // We prank + deal an address.
      fundMe.fund{value: SEND_VALUE}(); // We are calling FundMe.fund.
     }

     // ACT - here, we are pranking the owner and withdrawing.
     uint256 startingFundMeBalance = address(fundMe).balance;
     uint256 startingOwnerBalance = fundMe.getOwner().balance;

     vm.startPrank(fundMe.getOwner());
     fundMe.withdraw();
     vm.stopPrank();

     // ASSERT - here, we are comparing the final situation against what we expected.
     assert(address(fundMe).balance == 0); // After withdrawing, FundMe balance should be zero.
     assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
     assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance); // Checks that the total ETH sent by funders equals the amount the owner received after calling withdraw().

   }

   function testWithdrawFromMultipleFundersCheaper() public funded { // Cheaper Version

   // ARRANGE
      uint160 numberOfFunders = 10;
      uint160 startingFunderIndex = 1;
      for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
         // we get hoax from stdcheats
         // prank + deal = hoax
         hoax(address(i), SEND_VALUE);
         fundMe.fund{value: SEND_VALUE}();
         }

         // ACT

         uint256 startingFundMeBalance = address(fundMe).balance;
         uint256 startingOwnerBalance = fundMe.getOwner().balance;

         vm.startPrank(fundMe.getOwner());
         fundMe.cheaperWithdraw();
         vm.stopPrank();

         // ASSERT

         assert(address(fundMe).balance == 0);
         assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
         assert(((numberOfFunders + 1) * SEND_VALUE) == fundMe.getOwner().balance - startingOwnerBalance);
      }
}


// forge test --mt testPriceFeedVersionIsAccurate -vvv --fork-url https://eth-sepolia.g.alchemy.com/v2/pZ_ocYDeOlNrvTqMp2Fbg