// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// --- Purpose of this script ---
// 1. To deploy mocks on our local anvil chain
// 2. Keep track of contract addresses across different chains

import { Script } from "forge-std/Script.sol";
import { MockV3Aggregator } from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    // If we are on local anvil, deploy mocks otherwise
    // grab the existing address from the live network

    // set the active network configuration
    NetworkConfig public activeNetworkConfig;

    // create a variable type that defines the return type for
    // each of the configurations
    struct NetworkConfig{
        address priceFeed; //ETHUSD price feed address
    }

    // set the constructor function the selects the active network
    // configuration on deployment
    constructor(){
        // we use the chainid to determine the network of choice
        // and thereafter set the active network configuration
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        } else if(block.chainid == 1){
            activeNetworkConfig = getMainnetEthConfig();
        } else{
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        // returns sepolia price feed address
        // could return a bunch of other desired info too
        // which is why we use 'Struct' to create the return type
        // so that the Struct can be modified as desired
        NetworkConfig memory sepoliaNetworkConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaNetworkConfig;
    }

    function getMainnetEthConfig() public pure returns(NetworkConfig memory){
        // returns sepolia price feed address
        // could return a bunch of other desired info too
        // which is why we use 'Struct' to create the return type
        // so that the Struct can be modified as desired
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getAnvilEthConfig() public returns(NetworkConfig memory){
        // returns anvil price feed address

        // 1. Deploy the mocks
        // 2. return the mock contract address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }

}