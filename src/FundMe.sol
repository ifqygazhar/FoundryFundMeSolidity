// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();
error FundMe__NotEnoughFunds();
error FundMe__CallFailed();

contract FundMe {
    //using immutable to reduce the gass
    address public immutable i_owner;
    AggregatorV3Interface private immutable i_priceFeed;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    using PriceConverter for uint256;

    //using const to reduce the gass
    uint256 public constant MINIMUM_USD = 5e18;

    address[] public listOfFunds;
    mapping(address funder => uint256 amountFunded) public addressToAmount;

    function fund() public payable {
        // uint256 currentConversion = PriceConverter.getConversionRate(msg.value);
        // require(msg.value.getConversionRate() >= MINIMUM_USD,"didn't send enough of funds"); // 1 ETH
        if (msg.value.getConversionRate(i_priceFeed) < MINIMUM_USD) {
            revert FundMe__NotEnoughFunds();
        }
        listOfFunds.push(msg.sender);
        addressToAmount[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 fundIndex = 0;
            fundIndex < listOfFunds.length;
            fundIndex++
        ) {
            address funder = listOfFunds[fundIndex];
            addressToAmount[funder] = 0;
        }
        listOfFunds = new address[](0);

        //transfer
        // payable(msg.sender).transfer(address(this).balance);
        // //send
        // bool status = payable(msg.sender).send(address(this).balance);
        // require(status,"Send failed");
        //call
        //recommended
        (bool statusCall, ) = payable(i_owner).call{
            value: address(this).balance
        }("");
        if (!statusCall) {
            revert FundMe__CallFailed();
        }
    }

    function getVersion() public view returns (uint256) {
        return i_priceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Not the owner of this contract");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
