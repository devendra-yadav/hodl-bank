// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title This contract is a HODL bank where users can HODL their tokens and cant withdraw before the HODL time is over
 * @author Devendra Yadav(devendra.yadav@gmail.com)
 * 
 */
contract HodlBank {

    address payable public owner;
    address payable public contractAddress;
    uint hodlId=1;

    
    struct HodlData{
        uint id;
        address tokenContractAddress;
        uint startTime;
        uint amount;
        uint endTime;
    }

    //Contains userAddress mapping to array of HodlData[]
    mapping(address=>HodlData[]) public userHoldTokenMap;

    event HodlCreated(address indexed requester, uint hodlId, uint startDateTime, uint endDateTime, address tokenContractAddress, uint amount);

    event Withdraw(address indexed requester, uint hodlId, uint timestamp, address tokenContractAddress, uint amount);

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

        require(hodlEndTime>block.timestamp,"HODL end time should be in future");

        require(amount>0,"Amount should be greater than 0");
      
        userHoldTokenMap[requester].push(HodlData(hodlId, tokenAddress, block.timestamp, amount, hodlEndTime));

        ()=contractAddress.call{value : amount}("");
        
        emit HodlCreated(requester, hodlId, block.timestamp, hodlEndTime, tokenAddress, amount );

        hodlId++;

        return true;
    }

    /**
     * @dev this function is to get all the HODLs for a given user
     * @param user user address whose HODLs one want to see
     * @return allHodls this is an array of HodlData
     */
    function getHodlsForUser(address user) public view returns(HodlData[] memory allHodls){
        return userHoldTokenMap[user];
    }

    /**
     * @dev get balance of the contract
     * @return balance contract balance
     */
    function getContractNativeBalance() public returns(uint memory balance){
        contractAddress.balance;
    }


    function getContractERC20TokenBalance(address tokenAddress) public returns(uint memory balance){
        ((IERC20)tokenAddress).balanceOf(contractAddress);
    }

    function withdraw(address requester, uint hodlId) public{

        require(hodlId>0, "Invalid Hodl");

        HodlData[] allHodlsForUser = getHodlsForUser(requester);

        require(allHodlsForUser.length >0 , "No HODL found");

        for(int i=0;i<allHodlsForUser.length;i++){
            if(allHodlsForUser[i].id == hodlId){
                require(allHodlsForUser[i].endTime < block.timestamp, "Cant withdraw. HODL time not over yet.");
                ((IERC20)allHodlsForUser[i].tokenContractAddress).transferTo(requester, contractAddress, allHodlsForUser[i].amount);
                emit Withdraw(requester, hodlId, block.timestamp, allHodlsForUser[i].tokenContractAddress, amount);
                break;
            }
        }

    }

}