// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// A contract that receives ether and withdraws it from the his account
contract EtherWallet{
    address payable public owner;
    constructor(){
        owner = payable (msg.sender);
    }

    receive() external payable {

    }

    function withdraw(uint _amount) external payable {
         require(msg.sender==owner);
         require(_amount>0);
        //  owner.transfer(_amount);
         payable (msg.sender).transfer(_amount);  // More optimised
    }
}
