//SPDX-Liscense-Identifier:MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundme;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE=0.1  ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE=1;
    function setUp() external{
        // fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        // We can use the vm object to interact with the blockchain
        vm.deal(USER,STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundme.MINIMUM_USD(), 5 * 10 ** 18, "Minimum USD should be 5");


    }
    function testOwnerIsMsgSender() public {
        
        assertEq(fundme.i_owner(), msg.sender, "Owner should be the message sender");
    }
    function testPriceFeedVersionIsAccurate() public{
        uint256 version= fundme.getVersion();
        assertEq(version, 4, "Price feed version should be 4");


    }
    function testFundFailsWithoutEnougheth() public{
        vm.expectRevert();
        fundme.fund();
      
        // fundme.fund{value: 1e18}(); // Sending 1 ETH, which is less than the minimum of 5 USD

    }
    function testEnough() public{
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}(); // Sending 5 ETH, which is more than the minimum of 5 USD
        uint256 amountFunded = fundme.getAddressToamountFunded(USER);
        assertEq(amountFunded, SEND_VALUE, "Amount funded should be 10 ETH");
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}(); // Sending 5 ETH, which is more than the minimum of 5 USD
        _;

    }
    function testAddrFunderToArrayOfFunder() public funded{
       

        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded{
      
        vm.expectRevert();
        vm.prank(USER);
        fundme.withdraw();
    }
    function testWithDrawWithASingleFunder() public funded{
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        //testPriceFeedVersionIsAccurate
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed= (gasStart-gasEnd) * tx.gasprice;
        console.log(gasUsed);

        //assert
        uint256 endingOwnerBalance= fundme.getOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance+startingOwnerBalance,endingOwnerBalance);

    }
    function teststMultipleUsers() public funded {
        //since i'm dealing with address i have to change the data type to uint169
        uint160 numbersOfFunders=10;
        uint160 startingNumbers=1;
        for(uint160 i=startingNumbers;i<numbersOfFunders;i++){
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        //testPriceFeedVersionIsAccurate
        vm.prank(fundme.getOwner());
        fundme.withdraw();

        //assert
        assert(address(fundme).balance == 0 );
        assert(startingFundMeBalance + startingOwnerBalance == fundme.getOwner().balance);



    }
}
