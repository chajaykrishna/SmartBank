// SPDX-License-Identifier:MIT
pragma solidity >=0.7.0 <0.9.0;

contract MySmartBank {

    uint totalContractBalance = 0;

    function getContractBalance() public view returns(uint){
        return totalContractBalance;
    }
    
    // mapps addresses to their balances.
    mapping(address => uint) balances;
    mapping(address => uint) fixedDepositBalances;
    mapping(address => uint) depositTimeStamps;
    mapping(address => uint) fixedDepositTimeStamps;
    
    function addBalance() public payable {
        require(msg.value > 0, "invalid amount");
        addIntrest(msg.sender);
        balances[msg.sender] += msg.value;
        totalContractBalance = totalContractBalance + msg.value;
        depositTimeStamps[msg.sender] = block.timestamp;
    }
    
    function getInduvidualBalance(address userAddress) public view returns (uint) {
        return balances[userAddress];
    }

    /// @dev this function lets user to withdraw a certain amount/ total amount of their balance.
    function withdraw(uint amount) external returns (bool) {
        addIntrest(msg.sender);
        require(balances[msg.sender] >= amount, "user doesn't have enough money to withdraw.");
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "transfer failed");
        balances[msg.sender] -= amount;
        totalContractBalance -= amount;
        return success;
    }

    // transfer money to another bank account 
    function transferToAnotherBankAccount(address payable senderAddress, uint amount) public {
        addIntrest(msg.sender);
        addIntrest(senderAddress);
        require(balances[msg.sender] >= amount, "user don't have enough money to transfer.");
        // (bool success, ) = payable(senderAddress).call{value: amount}("");
        balances[msg.sender] -= amount;
        balances[senderAddress] += amount;
        
    }

    ///@dev this function if called will add intrest amount to the user account.
    function addIntrest(address _user) private {
        uint _totalTime = block.timestamp - depositTimeStamps[_user];
        uint _intrest = balances[_user] * uint(_totalTime /(24*60*60*365*100)) * 7;  //  7% intrest per year, intrest formula = ptr /100
        balances[_user] += _intrest;
        totalContractBalance += _intrest;
        depositTimeStamps[_user] = block.timestamp;
    }

    /// @notice any user can deposit their eth for certain period of time for extra intrest(10%). during this period the user cannot withdraw the funds.
    // user can only transfer money from existing account to fixed deposit account
    function fixedDeposit(uint amount) public {
        addIntrest(msg.sender);
        require(balances[msg.sender] >= amount, "user don't have enough money to deposit.");
        fixedDepositIntrest(msg.sender);
        fixedDepositBalances[msg.sender] += amount;
        balances[msg.sender] -= amount;
        fixedDepositTimeStamps[msg.sender] = block.timestamp;
    }

     function withdrawFixedDeposit(uint amount) external  {
         addIntrest(msg.sender);
         fixedDepositIntrest(msg.sender);
        require(fixedDepositBalances[msg.sender] >= amount, "user don't have enough money to withdraw from fixed deposit.");
        require(fixedDepositTimeStamps[msg.sender] - block.timestamp >= (365 days), "cannot withdraw fixed deposit amount within a year");
        // (bool success, ) = payable(msg.sender).call{value: amount}("");
        // require(success, "transfer failed");
        balances[msg.sender] += amount;
        fixedDepositBalances[msg.sender] -= amount;
     }

     function fixedDepositIntrest( address _user) private {
        uint _totalTime = block.timestamp - fixedDepositTimeStamps[_user];
        uint _intrest = fixedDepositBalances[_user] * uint(_totalTime /(24*60*60*365*100)) * 12;  //  12% intrest per year, intrest formula = ptr /100
        fixedDepositBalances[_user] += _intrest;
        totalContractBalance += _intrest;
        fixedDepositTimeStamps[_user] = block.timestamp;
     }

    function getInduvidualFixedDepositBalance(address userAddress) public view returns (uint) {
        return fixedDepositBalances[userAddress];
    }

}
