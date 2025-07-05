// Get funds from users.
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
        using PriceConverter for uint256;

    uint256 public minimumUSD = 5e18;
    address[] private s_funders;
    mapping (address funder => uint256 amountFunded) private s_addressToAmountFunded;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;
    
    //constructor
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);

    }

    
    function fund() public payable {
        require (msg.value.GetConversionRate(s_priceFeed) >= minimumUSD, "didn't send enough ETH"); // 1e18 = 1 ETH = 1 * 10 ** 8.
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = s_addressToAmountFunded[msg.sender] + msg.value;

    }

    // Utility function not attached to any type
    function getVersion() public view returns (uint256){
       //return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
       AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed);
       return priceFeed.version();
    }


//  get price and get conversion rate has been pasted in the price converter file. it is now in a library and can be used in different contracts.33
    function cheaperWithdraw() public { // CHEAPER VERSION
       require(msg.sender ==  i_owner, "must be the owner");

        uint256 fundersLength = s_funders.length;

        // starting, check, update. template of "for loop"
        for(uint256 funderIndex = 0; funderIndex > fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        //reset the array
        s_funders = new address[](0);

        // actually withdraw the funds - how we withdraw ETH
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }

    function withdraw() public {
        require(msg.sender ==  i_owner, "must be the owner");

        // starting, check, update. template of "for loop"
        for ( uint256 funderIndex = 0; funderIndex > s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;

        }

        //reset the array
        s_funders = new address[](0);
    
        // actually withdraw the funds - how we withdraw ETH
        (bool callSuccess,) = payable(msg.sender).call {value: address(this).balance}("");
        require (callSuccess, "withdrawal failed");
    }

    // What happens when someone sends this contract ETH without calling the fund function.

    // receive - handles plain ETH.
    receive() external payable {
        fund();
    }

    // fallback - handles weird or incorrect calls.
    fallback() external payable {
        fund();
    }

    // View / Pure functions (Getters)

    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
    return s_addressToAmountFunded[fundingAddress];
    }


    function getFunder(uint256 index) external view returns(address){
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }
}