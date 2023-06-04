// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract AccessControl {
// This contract will manage roles to the account,depending on the role(account will be able to call the function or disallowed)

    event GrantRole(bytes32 indexed roles,address indexed account);
    event RevokeRole(bytes32 indexed roles,address indexed account);
    
    mapping (bytes32=> mapping (address=>bool)) public roles;
// use public(to get the hash of admin and user),then again making it private
    bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    bytes32 private constant USER = keccak256(abi.encodePacked("USER")); 


    function _grantRoles(bytes32 _role,address _account) internal {
        roles[_role][_account] = true;
    }

    constructor() {
       _grantRoles(ADMIN, msg.sender);
    }

    modifier onlyOwner(bytes32  _role){
        require(roles[_role][msg.sender],"Not authorized");  // Maoping shud be true
        _;
    }

    function grantRole(bytes32 _role,address _account) external onlyOwner(ADMIN){
        _grantRoles(_role,_account);
        emit GrantRole(_role, _account);
    }

    function revokeRole(bytes32 _role,address _account) external onlyOwner(ADMIN){
        roles[_role][_account] = false;
        emit RevokeRole(_role, _account);
    }
    
    // Testing instruction in REMIx ide 
    // address of the deployer
    // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

    // Now paste admin hash and deployers address in roles

    // Now paste the user hash in grant role,address shud be of this contract only,not of other(since only admin can grant role)

}
