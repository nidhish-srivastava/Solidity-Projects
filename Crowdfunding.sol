// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract CrowdFunding{
    // First we will define the variables that we need like minimalContribution,target,deadline
    mapping (address=>uint) public contributors; // kisi se kitna diya paisa(check krenge uske address se),address => ether
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    // Now after making the basic requirement variables,we need 2 more imp variables
    uint public raisedAmount; 
    uint public totalContributors;


    //*Code for Manager
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping (address => bool) voters;
    }
    mapping (uint => Request) public request;
    uint public numRequests; // For iterating inside the mapping 



// The deployer will already set the target and the deadline
    constructor(uint _target,uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline;  // when block is created + time we want it to run for
        manager = msg.sender;
        minimumContribution = 100 wei;
    }

    function sendEth() public payable{
        // 1. When someone contributes,first is,the deadline shudnt be passed,otherwise person cant contribute
        require(block.timestamp < deadline,"Deadline has passed");
        // 2. Minimum contribution shud be 100wei
        require(msg.value >= minimumContribution,"Minimum contribution is not met");

        // Now after these two conditions are met,we come to more imp stuff
        if(contributors[msg.sender] == 0){ // Since default value is 0 for uint,and address 0X00,This means that there is no contribution
           totalContributors++; // Jb bhi koi aaega pehli baar,tb toh 0 hoga,fir woh contribute krega,so contributors badh jaenge
        } 
        contributors[msg.sender] += msg.value; // IF the same contributor,contributes more,then,we wont increase the totalContributors,we will increase its value only
        raisedAmount += msg.value;
    }                                             

    function getContractBalance() public view returns(uint){
        return address(this).balance;
    } 

    // What if the deadline is over,we are not able to achieve our target,then contributor can ask for refund otherwise not
    function refund() public {
        require(block.timestamp > deadline && raisedAmount < target,"You are not eligible for refund");
        require(contributors[msg.sender] > 0,"You havent contributed");  // Checking wether he has contributed or not
        // These 2 lines below are lil confusing
        address payable user = payable (msg.sender); // Making this address payable,coz mujhe iss address ko pay krna hai
        user.transfer(contributors[msg.sender]); // This is similar to => user.transfer(100)
        contributors[msg.sender] = 0; // Now the amount given by contributor is refunded,then its amount donated will be 0
    }






    // On the behalf of the contributor,all the things are done,now comes the behalf of the manager
    // Manager cant directly access balance from the smart contract(he need to request)

    modifier onlyManager(){
        require(msg.sender == manager,"Only Manager can call this function");
        _;
    }
    function createRequests(string memory _description,address payable _recipient,uint _value) public onlyManager{
        // rhs ka return type is Struct,so we will use Request(which is a struct),At numRequest = 0(default value of uint)
        Request storage newRequest = request[numRequests]; // mapping inside structure,and u wanna use it inside function,dont use memory
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    // Now we need to conduct voting
      // kaun si request ki voting kraani hai,woh hm pass kr rhe in argument
    function voteRequest(uint _requestNo)  public{
        require(contributors[msg.sender]>0,"You havent contributed"); // Checking wether contributed or not
        Request storage thisRequest = request[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted"); // Now checking wether he has already voted or not
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    } 

    // Now comes the last function,this is for payment
    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>= target);  // If we have reached our target,then only we can make the payment
        Request storage thisRequest = request[_requestNo];
        require(thisRequest.completed==false,"The request has already been completed");
        require(thisRequest.noOfVoters > totalContributors/2,"Majority doesnt support");// We want that 50% se zyaada log vote kre to make the payment complete
        thisRequest.completed = true; // Since this request is true,if manager tries ki fir se isse paisa dilwa du,nhi hoga aisa possible
    }
}