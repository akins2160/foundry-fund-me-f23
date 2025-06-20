//SPDX-Listener-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // We can use the vm object to interact with the blockchain
        HelperConfig helperConfig= new HelperConfig();
        address ethUsdpriceFeed= helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        // Deploy the FundMe contract
        FundMe fundMe = new FundMe(ethUsdpriceFeed);
        // Stop broadcasting transactions
        vm.stopBroadcast();
        return fundMe;
    }
}
