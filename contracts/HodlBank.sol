// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
     * @param tokenAddress  contract address of the token that the user want to hODL
     * @param amount  amount of tokens to HODL
     * @param hodlEndTime  end time of the HODL. Amount can be withdrawn on after this time.
     * @return result  it returns if the HODL request was successful or it failed.
     */
    function hodlRequestERC20Token(address tokenAddress, uint amount, uint hodlEndTime) public payable returns (bool result) {

        require(hodlEndTime>block.timestamp,"HODL end time should be in future");

        require(amount>0,"Amount should be greater than 0");
      
        userHoldTokenMap[msg.sender].push(HodlData(hodlId, tokenAddress, block.timestamp, amount, hodlEndTime));

        ((IERC20)(tokenAddress)).transferFrom(msg.sender, contractAddress, amount);
        
        emit HodlCreated(msg.sender, hodlId, block.timestamp, hodlEndTime, tokenAddress, amount );

        hodlId++;

        return true;
    }

    /**
     * @dev : This function is to initial the hodl request by a user for a specific token for a given amount.
     *        it also emit the corresponding event for logging purpose.
     * @param amount  amount of tokens to HODL
     * @param hodlEndTime  end time of the HODL. Amount can be withdrawn on after this time.
     * @return result  it returns if the HODL request was successful or it failed.
     */
    function hodlRequestNativeToken(uint amount, uint hodlEndTime) public payable returns (bool result) {

        require(hodlEndTime>block.timestamp,"HODL end time should be in future");

        require(amount>0,"Amount should be greater than 0");
      
        userHoldTokenMap[msg.sender].push(HodlData(hodlId, address(0), block.timestamp, amount, hodlEndTime));

        contractAddress.transfer(amount);
        
        emit HodlCreated(msg.sender, hodlId, block.timestamp, hodlEndTime, address(0), amount );

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
    function getContractNativeBalance() public view returns(uint balance){
        return contractAddress.balance;
    }

    /**
     * @dev THis function is to the the balance of a specific token in the contract
     * @param tokenAddress contract address of the token
     * @return balance token balance
     */
    function getContractERC20TokenBalance(address tokenAddress) public view returns(uint balance){
        
        return ((IERC20)(tokenAddress)).balanceOf(contractAddress);

    }

    /**
     * @dev this function is to withdraw a given HODL once the HODL time is over
     * @param hodlIdToWithdraw HODL id that needs to be withdrawn
     */
    function withdraw(uint hodlIdToWithdraw) public payable{

        require(hodlIdToWithdraw>0, "Invalid Hodl");

        HodlData[] memory allHodlsForUser = getHodlsForUser(msg.sender);

        require(allHodlsForUser.length >0 , "No HODL found");

        for(uint i=0;i<allHodlsForUser.length;i++){
            if(allHodlsForUser[i].id == hodlIdToWithdraw){
                require(allHodlsForUser[i].endTime < block.timestamp, "Cant withdraw. HODL time not over yet.");
                if(allHodlsForUser[i].tokenContractAddress == address(0)){
                    payable(msg.sender).transfer(allHodlsForUser[i].amount);
                }else{
                    ((IERC20)(allHodlsForUser[i].tokenContractAddress)).transferFrom(contractAddress, msg.sender, allHodlsForUser[i].amount);
                }
                
                emit Withdraw(msg.sender, hodlIdToWithdraw, block.timestamp, allHodlsForUser[i].tokenContractAddress, allHodlsForUser[i].amount);
                break;
            }
        }

    }

}