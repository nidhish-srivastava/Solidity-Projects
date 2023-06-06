// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract SimpleRealEstateEscrow {
    address public buyer;
    address public seller;
    address public agent;
    uint256 public price;
    bool public isContractActive;
    bool public isSellerApproved;
    bool public isBuyerApproved;

    event ContractInitialized(
        address buyer,
        address seller,
        address agent,
        uint256 price
    );
    event BuyerApproved();
    event SellerApproved();
    event FundsReleased(address recipient, uint256 amount);

    constructor(
        address _buyer,
        address _seller,
        uint256 _price,
        address _agent
    ) {
        buyer = _buyer;
        seller = _seller;
        agent = _agent;
        price = _price;
        isContractActive = true;
        isSellerApproved = false;
        isBuyerApproved = false;
         emit ContractInitialized(_buyer, _seller, _agent, _price);
    }

    modifier onlySeller() {
        require(msg.sender == seller);
        _;
    }
    modifier onlyBuyer() {
        require(msg.sender == buyer);
        _;
    }
    modifier onlyAgent() {
        require(msg.sender == agent);
        _;
    }
    modifier ContractActive() {
        require(isContractActive);
        _;
    }

    function approvedBySeller() external onlySeller {
        isSellerApproved = true;
          emit SellerApproved();
    }

    function approvedByBuyer() external onlyBuyer {
        isBuyerApproved = true;
         emit BuyerApproved();
    }

    function releaseFundsToSeller() external onlyAgent ContractActive {
        require(isBuyerApproved && isSellerApproved, "Aint approved");
        payable(seller).transfer(price);
        isContractActive = false;
           emit FundsReleased(seller, price);
    }

    function refundToBuyer() external ContractActive onlyAgent {
        require(!isBuyerApproved || !isSellerApproved, "Aint approved");
        payable(buyer).transfer(price);
        isContractActive = false;
           emit FundsReleased(seller, price);
    }
}
