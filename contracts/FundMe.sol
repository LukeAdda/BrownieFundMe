// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;
//anything less than 0.8 requires safemath

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
//Open Zeppelin is an open source library!
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    //we can use the constructor to initialize the contract
    // we should only allow the owner of the contract to withdraw the funds.
    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable {
        // payable means this function can be used to pay for things
        //wei smallest denominator of Ether

        //lets say funding requires $50 USD
        // we will want to set a minimum funding
        uint256 minimumUsd = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimumUsd,
            "insufficient value"
        );
        funders.push(msg.sender);

        addressToAmountFunded[msg.sender] += msg.value;
        //msg.sender and msg.value are always in contract call
        //msg.sender - address of contract caller
        //msg.value - value sent
    }

    //modifiers can be used to change the behaviour of a function
    //used in conjunction with a function, it can run the specific code prior to entering the function
    modifier onlyOwner() {
        require(msg.sender == owner, "only the owner can withdraw");
        _; // the _ represents to continue running the function of the code after modifier was checked.
    }

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getDescription() public view returns (string memory) {
        return priceFeed.description();
    }

    function getPrice() public view returns (uint256) {
        //the data is a tuple, so only specific data can be grabbed if needed.
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer) * 10000000000;
        //uint256(answer) is typecasting the variable
        //Eth was 3378.71473297 at time of writing wow
    }

    function getDecimals() public view returns (uint8) {
        return priceFeed.decimals();
    }
}
