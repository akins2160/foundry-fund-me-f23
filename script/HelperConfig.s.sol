//1. Deploy mocks when we are on a local anvil chain
//2. Keep tract of contract addresses for different chains


//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import{MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8; // 2000 with 8 decimals

    struct NetworkConfig{
        address priceFeed;
    }
    constructor(){
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();}
         else if (block.chainid ==1){
            activeNetworkConfig = getMainetEthConfig();
         }
        else{
            activeNetworkConfig =getAnvilEthConfig();
        }

           }
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){ 
        NetworkConfig memory sepoliaConfig= NetworkConfig({
            priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;


    }
     function getMainetEthConfig() public pure returns(NetworkConfig memory){ 
        NetworkConfig memory ethConfig= NetworkConfig({
            priceFeed:0x5424384B256154046E9667dDFaaa5e550145215e
        });
        return ethConfig;


    }
    function getAnvilEthConfig() public  returns (NetworkConfig memory){
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // price feed address

        //Deploy Mock Test
        //Return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_ANSWER);

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;




    }
    
    }
