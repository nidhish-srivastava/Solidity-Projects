// A contract where the user can transfer ether to the owner of the contract(which is buying a chai for owner) and see all the transactions as well
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract BuyChai{
    address payable public owner;
    constructor(){
        owner = payable(msg.sender);
    }
    struct Memo{
        string name;
        string message;
        uint timestamp;
        address from;
    }
    Memo[] memos;

    function buyChai(string memory _name,string memory _message) external payable  {
        require(msg.value>0,"please send something");
        owner.transfer(msg.value);
        memos.push(Memo(_name,_message,block.timestamp,msg.sender));
    }

    function getMemos() external view returns(Memo[] memory) {
      return memos;
    }
}