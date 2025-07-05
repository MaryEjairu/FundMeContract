// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    // Utility function not attached to any type
     function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256){ 
    // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
    // ABI - we imported the Aggregator interface from Chainlink.

   // AggregatorV3Interface dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    (, int256 answer, , , ) = priceFeed.latestRoundData(); //This line fetches the latest price data from the Chainlink oracle
    return uint256(answer * 1e10); // Convert from 8 decimals to 18 decimals
}

    // Utility function not attached to any type
    function getVersion() internal view returns (uint256){
       return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
       
    }
    // Attached to uint256, converts ETH amount to USD
    function GetConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount)/1e18;
        return ethAmountInUsd;
    }

  }