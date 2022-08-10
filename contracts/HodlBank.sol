// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/**
 * @title This contract is a HODL bank where users can HODL thier tokens and cant withdraw before the HODL time is over
 * @author Devendra Yadav(devendra.yadav@gmail.com)
 * 
 */
contract HodlBank {

    address payable public owner;
    address payable public contractAddress;

    
    struct HodlData{
        address tokenContractAddress;
        uint startTime;
        uint amount;
        uint endTime;
    }

    //Contains userAddress mapping to array of HodlData[]
    mapping(address=>HodlData[]) public userHoldTokenMap;

    event HodlInitiated(address indexed requester, uint startDateTime, uint endDateTime, address tokenContractAddress, uint amount);

    event Withdraw(address indexed requester, uint timestamp, string tokenName, uint amount);

    event HoldRequestFailed(address indexed requester, uint startDateTime, uint endDateTime, address tokenContractAddress, uint amount);

    constructor() {
        owner=payable(msg.sender);
        contractAddress=payable(address(this));
    }

    /**
     * @dev : This function is to initial the hodl request by a user for a specific token for a given amount.
     *        it also emit the corresponding event for logging purpose.
     * @param requester  Requester address who want to HODL
     * @param tokenAddress  contract address of the token that the user want to hODL
     * @param amount  amount of tokens to HODL
     * @param hodlEndTime  end time of the HODL. Amount can be withdrawn on after this time.
     * @return result  it returns if the HODL request was successful or it failed.
     */
    function hodlRequest(address requester, address tokenAddress, uint amount, uint hodlEndTime) public payable returns (bool result) {

      
        if(userHoldTokenMap[requester].length == 0){
            
            userHoldTokenMap[requester]=[HodlData(tokenAddress, block.timestamp, amount, hodlEndTime)];
        }else{
            //push HodlData to the existing array for the requester
            userHoldTokenMap[requester].push(HodlData(tokenAddress, block.timestamp, amount, hodlEndTime));

        }     
    
        emit HodlInitiated(requester, block.timestamp, hodlEndTime, tokenAddress, amount );

       
        
        return true;
    }
}