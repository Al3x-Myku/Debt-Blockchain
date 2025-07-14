// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DebtToken.sol";
import "./DebtReceipt.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// contractul principal care tine socoteala la datorii
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
        // autorizarea se face din scriptul de deploy, ca aici nu are ownership
    }

    // propui o datorie, creditorul zice ca vrea sa-i dea bani cuiva
    function proposeDebt(address debtor, uint256 amount, string memory tokenURI) public {
        require(amount > 0, "Trebuie sa fie ceva suma");
        require(debtor != msg.sender, "Nu poti sa-ti propui tie datorie");
        
        uint256 debtId = _debtIds.current();
        _debtIds.increment();
        
        debts[debtId] = Debt(debtId, debtor, msg.sender, amount, tokenURI, DebtStatus.Proposed, 0);

        emit DebtProposed(debtId, msg.sender, debtor, amount);
    }

    // debitorul accepta datoria, se emit tokenii si NFT-ul
    function acceptDebt(uint256 debtId) public {
        Debt storage debt = debts[debtId];
        require(debt.status == DebtStatus.Proposed, "Datoria nu e propusa");
        require(msg.sender == debt.debtor, "Doar debitorul poate accepta");

        debt.status = DebtStatus.Active;
        
        // dam tokenii de datorie la debitor
        debtToken.mint(debt.debtor, debt.amount);
        
        // dam NFT-ul de chitanta la creditor
        uint256 nftId = debtReceipt.safeMint(debt.creditor, debt.tokenURI);
        debt.nftTokenId = nftId;

        emit DebtAccepted(debtId, nftId);
    }

    // debitorul plateste datoria, se ard tokenii si NFT-ul
    function settleDebt(uint256 debtId) public {
        Debt storage debt = debts[debtId];
        require(debt.status == DebtStatus.Active, "Datoria nu e activa");
        require(msg.sender == debt.debtor, "Doar debitorul poate plati");

        // debitorul trebuie sa fi aprobat transferul inainte
        debtToken.burnFrom(debt.debtor, debt.amount);
        
        // ardem NFT-ul de la creditor
        debtReceipt.burnByManager(debt.nftTokenId);
        
        debt.status = DebtStatus.Settled;
        emit DebtSettled(debtId);
    }

    // daca vrei sa autorizezi manual contractul ca burner (daca nu merge la deploy)
    function authorizeSelfAsBurner() public {
        debtReceipt.authorizeBurner(address(this));
    }
}