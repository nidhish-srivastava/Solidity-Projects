// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


// A contract where the owner can set the ownership to some other new address
contract Ownable{
    address public owner;
    constructor(){
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"You are not the owner");
        _;
    }
    function setOwnerShip(address _newOwner) external onlyOwner {
          // Checking that the address shud not be zero(which is invalid and inexistent)
          require(_newOwner!=address(0));
          owner = _newOwner;
    }
    function onlyOwnerCanCall() external onlyOwner {
          // Some code
    }

    function anyOneCanCall() external {
          // Some code
    }
}
