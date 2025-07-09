// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DebtToken.sol";
import "./DebtReceipt.sol";

contract DebtManager {
    DebtToken public immutable debtToken;
    DebtReceipt public immutable debtReceipt;

    struct DebtInfo {
        address debtor;
        address creditor;
        uint256 amount;
        bool settled;
    }

    mapping(uint256 => DebtInfo) public debts;

    event DebtCreated(
        uint256 indexed tokenId,
        address indexed debtor,
        address indexed creditor,
        uint256 amount
    );
    event DebtSettled(uint256 indexed tokenId);

    constructor(address _debtTokenAddress, address _debtReceiptAddress) {
        debtToken = DebtToken(_debtTokenAddress);
        debtReceipt = DebtReceipt(_debtReceiptAddress);
    }

    function createDebt(
        address debtor,
        uint256 amount,
        string memory tokenURI
    ) public {
        require(amount > 0, "Amount must be > 0");
        // Creditorul este cel care apelează funcția (msg.sender)
        address creditor = msg.sender;

        debtToken.mint(debtor, amount);
        uint256 tokenId = debtReceipt.safeMint(creditor, tokenURI);

        debts[tokenId] = DebtInfo(debtor, creditor, amount, false);

        emit DebtCreated(tokenId, debtor, creditor, amount);
    }

    function settleDebt(uint256 tokenId) public {
        DebtInfo storage debt = debts[tokenId];
        
        require(debt.amount > 0, "Debt not found");
        require(!debt.settled, "Debt already settled");
        
        // Debtorul (datornicul) este cel care trebuie sa achite
        require(msg.sender == debt.debtor, "Only debtor can settle");

        // Debtorul trebuie sa aprobe mai intai transferul de tokenuri
        // catre acest contract (DebtManager)
        debtToken.transferFrom(debt.debtor, debt.creditor, debt.amount);
        debtReceipt.burn(tokenId);

        debt.settled = true;
        emit DebtSettled(tokenId);
    }
}
