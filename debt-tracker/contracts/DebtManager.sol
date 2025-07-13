// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DebtToken.sol";
import "./DebtReceipt.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DebtManager {
    using Counters for Counters.Counter;
    Counters.Counter private _debtIds;

    DebtToken public immutable debtToken;
    DebtReceipt public immutable debtReceipt;

    enum DebtStatus { Proposed, Active, Settled }

    struct Debt {
        uint256 id;
        address debtor;
        address creditor;
        uint256 amount;
        string tokenURI;
        DebtStatus status;
        uint256 nftTokenId;
    }

    mapping(uint256 => Debt) public debts;

    event DebtProposed(uint256 indexed debtId, address indexed creditor, address indexed debtor, uint256 amount);
    event DebtAccepted(uint256 indexed debtId, uint256 indexed nftTokenId);
    event DebtSettled(uint256 indexed debtId);

    constructor(address _debtTokenAddress, address _debtReceiptAddress) {
        debtToken = DebtToken(_debtTokenAddress);
        debtReceipt = DebtReceipt(_debtReceiptAddress);
        
        // Note: Authorization will be done by deployer in deployment script
        // since DebtManager doesn't own DebtReceipt during construction
    }

    function proposeDebt(address debtor, uint256 amount, string memory tokenURI) public {
        require(amount > 0, "Amount must be > 0");
        require(debtor != msg.sender, "Cannot propose debt to yourself");
        
        uint256 debtId = _debtIds.current();
        _debtIds.increment();
        
        debts[debtId] = Debt(debtId, debtor, msg.sender, amount, tokenURI, DebtStatus.Proposed, 0);

        emit DebtProposed(debtId, msg.sender, debtor, amount);
    }

    function acceptDebt(uint256 debtId) public {
        Debt storage debt = debts[debtId];
        require(debt.status == DebtStatus.Proposed, "Debt not in proposed state");
        require(msg.sender == debt.debtor, "Only debtor can accept");

        debt.status = DebtStatus.Active;
        
        // Emite tokenii de datorie către datornic
        debtToken.mint(debt.debtor, debt.amount);
        
        // Emite chitanța NFT către creditor
        uint256 nftId = debtReceipt.safeMint(debt.creditor, debt.tokenURI);
        debt.nftTokenId = nftId;

        emit DebtAccepted(debtId, nftId);
    }

    function settleDebt(uint256 debtId) public {
        Debt storage debt = debts[debtId];
        require(debt.status == DebtStatus.Active, "Debt is not active");
        require(msg.sender == debt.debtor, "Only debtor can settle");

        // Datornicul trebuie să fi aprobat în prealabil transferul din interfață
        // Managerul arde tokenii din contul datornicului
        debtToken.burnFrom(debt.debtor, debt.amount);
        
        // Managerul arde NFT-ul din contul creditorului
        debtReceipt.burnByManager(debt.nftTokenId);
        
        debt.status = DebtStatus.Settled;
        emit DebtSettled(debtId);
    }

    // Function to manually authorize this contract as a burner (in case constructor fails)
    function authorizeSelfAsBurner() public {
        debtReceipt.authorizeBurner(address(this));
    }
}