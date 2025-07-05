// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on the anvil chainlink
// 2. Keep track of contract address across different cchains like sepolia ETH/USD, Mainnet ETH/ USD

pragma solidity ^0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/MockV3Aggregator.sol";


contract HelperConfig is Script {

NetworkConfig public activeNetworkConfig;

uint8 public constant DECIMALS = 8;
int256 public constant INITIAL_PRICE = 2000e8;

struct NetworkConfig {
    address priceFeed; // ETH/USD price feed address
}

constructor(){
    if (block.chainid == 11155111) {
        activeNetworkConfig = getSepoliaEthConfig();
    } else {
        activeNetworkConfig = getAnvilEthConfig();
       }
    }


function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
     // price feed address
 NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
 return sepoliaConfig;
}

function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
    // price feed address
 NetworkConfig memory ethConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
 return ethConfig;
}

function getAnvilEthConfig() public returns (NetworkConfig memory) {
 
 if (activeNetworkConfig.priceFeed != address(0))
 return activeNetworkConfig;
 
 // 1. deploy the mocks.
 // 2. return the mock address.

 vm.startBroadcast();
  MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, 2000e8);
 vm.stopBroadcast();
 
 NetworkConfig memory anvilConfig = NetworkConfig ({
 priceFeed: address(mockPriceFeed)
 });

 return anvilConfig;
 }


}
