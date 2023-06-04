// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract MultiSigWallet{
    event Deposit(address indexed sender,uint amount);
    event Submit(uint indexed txId);
    event Approve(address indexed owner,uint indexed txId);
    event Revoke(address indexed owner,uint indexed txId);
    event Execute(uint indexed txId);

    address[] public owners;
    mapping(address=>bool) public isOwner; // we need a quick way to check wether the sender is owner or not
    uint public required;  // Number of approvals that we need for the transaction
    struct Transaction{
        address to;
        uint value;
        bytes data; // data that will be sent to the address
        bool executed;
    }
    Transaction[] public transactions;

    // Each transaction can be executed when the number of approvals is >= required
    mapping(uint => mapping (address=>bool)) public approved;  // uint is the index of the owner(which owner),ex : 2,then takes address,gives true or false which is the approval 

    // address of the owner and required
    constructor(address[] memory _owners,uint _required){
       require(_owners.length>0,"owners required");
       require(_required>0 && _required<= owners.length,"Invalid required number of owners");
       // Now we will save the owners in the array using for loop
       for(uint i;i<owners.length;i++){
           address owner = _owners[i];
           require(owner != address(0),"Invalid address");
           require(!isOwner[owner],"Owner is not unique"); // Checking if owner is not in inside the array
           isOwner[owner] = true;
           owners.push(owner);
       }
       required = _required;
    } 

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    modifier onlyOwner(){
        require(isOwner[msg.sender],"Not authorized");
        _;
    }

    function submit(address _to,uint _value,bytes calldata _data) external onlyOwner{
        transactions.push(Transaction(_to,_value,_data,false));
        emit Submit(transactions.length-1);
    }

// FROM HERE,shits gets crazy as hell
// _txID : index of the transaction to approve

    modifier txExists(uint _txId){
        // ixId is the index of the transaction array,this means index shud be the less than the length
        require(_txId<transactions.length,"tx doesnt exist");
        _;
    }

    modifier notApproved(uint _txId){
        // Now we wil use the mapping called approved
        require(!approved[_txId][msg.sender],"tx already exists");
        _;
    }

    modifier notExecuted(uint _txId){
        require(!transactions[_txId].executed,"tx already executed");
        _;
    }

    function approve(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
       approved[_txId][msg.sender] = true; // First we will approve the tx using the mapping approve
       emit Approve(msg.sender, _txId);
    }

    function _getApprovalCount(uint _txId) private view returns(uint count){
         for(uint i;i<owners.length;i++){  // Just checking wether tx is approved or not,then increasing the count
             if(approved[_txId][owners[i]]){  // now we wont use msg.sender(coz we already have the owners array,we will iterate through it)
                 count++;
             }
         }
    }

    function executed(uint _txId) external txExists(_txId) notExecuted(_txId) {
        require(_getApprovalCount(_txId) >= _txId,"approvals is less than required");
        // check wether the the number of approvals is >= required
         Transaction storage transaction = transactions[_txId];
         transaction.executed = true; 

// below line is not clear
         (bool success,) = transaction.to.call{value : transaction.value}(
             transaction.data
         );
         require(success,"tx failed");

         emit Execute(_txId);
    }

    function revoke(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId){
        require(approved[_txId][msg.sender],"tx is not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);

    }
}