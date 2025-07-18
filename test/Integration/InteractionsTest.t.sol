//SPDX-Liscense-Identifier:MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import{FundFundMe,WithdrawFundMe} from "../../script/interactions.s.sol";

contract InteractionsTest is Test{
    FundMe fundme;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE=0.1  ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE=1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        // We can use the vm object to interact with the blockchain
        vm.deal(USER,STARTING_BALANCE);
    }
    function testuserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundme));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundme));

       
        assert(address(fundme).balance==0);
        
    }
    
}