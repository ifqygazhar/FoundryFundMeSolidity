// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();
error NotEnoughFunds();
error CallFailed();

contract FundMe {
    //using immutable to reduce the gass
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    using PriceConverter for uint256;

    //using const to reduce the gass
    uint256 public constant MINIMUM_USD = 5e18;

    address[] public listOfFunds;
    mapping(address funder => uint256 amountFunded) public addressToAmount;

    function fund() public payable {
        // uint256 currentConversion = PriceConverter.getConversionRate(msg.value);
        // require(msg.value.getConversionRate() >= MINIMUM_USD,"didn't send enough of funds"); // 1 ETH
        if (msg.value.getConversionRate() < MINIMUM_USD) {
            revert NotEnoughFunds();
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
            revert CallFailed();
        }
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Not the owner of this contract");
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
