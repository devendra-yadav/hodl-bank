// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract HodlBank {

    address payable public owner;
    address payable public contractAddress;

    //Contains userAddress mapping to array of tokenContractAddress HODLed
    private mapping(address=>address[]) userHoldTokenMap;

    private struct HodlData{
        uint startTime,
        uint amount,
        uint endTime
    }

    //Mapping of user address =>  Array of mapping of token contract address/HODL data struct
    private mapping (address => mapping(address=> HodlData[])) userHodlTokenDetails;


    event HodlInitiated(address indexed requester, uint startDateTime, uint endDateTime, address tokenContractAddress, uint amount);

    event Withdraw(address indexed requester, uint timestamp, string tokenName, uint amount);

    constructor() {
        owner=msg.sender;
        contractAddress=payable(address(this));
    }

    function hodlRequest(address requester, address tokenAddress, uint amount, uint hodlEndTime) public payable returns (boolean result) {
        
        //Get all Hodled tokens of the requester
        address[] holdTokens = userHoldTokenMap.get(requester);

        //Checking if requester is already HOLDing this token. if no then add it to the user=>token[] map (userHoldTokenMap)
        boolean tokenAlreadyHodled=false;
        for(int i=0;i<holdTokens.length;i++){
            address hodledTokenAddress=holdTokens.get(i);
            if(hodledTokenAddress == tokenAddress){
                tokenAlreadyHodled=true;
                userHoldTokenMap[requester].push(tokenAddress);
                break;
            }
        }

        if(!tokenAlreadyHodled){
            address[] tokenAddresses;
            hodlDtokenAddressesata.push(tokenAddress);
            userHoldTokenMap[requester]=tokenAddresses;
        }

        //Create a HodlData struct
        HodlData hodlData=HodlData(block.timestamp, amount, hodlEndTime);
        mapping(address=>HodlData[]) hodlDataMap=userHodlTokenDetails.get(requester);

        

        emit HodlInitiated(requester, block.timestamp, hodlEndTime, tokenAddress, amount );
    }
}