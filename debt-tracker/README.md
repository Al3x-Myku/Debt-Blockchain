# Datorii Tracker - README

## Varianta casual, pe romaneste

Salut boss! 👋

Aici e proiectul tau de urmarit datorii pe blockchain. E facut cu Brownie, Solidity si un pic de magie. Daca vrei sa vezi cine are de dat si cine are de luat, aici e locul. 

### Cum rulezi treaba asta:

1. **Instaleaza dependintele**
   ```bash
   pip install -r requirements.txt  # daca ai requirements, sau pip install brownie
   ```
2. **Pune cheile tale in `.env` sau direct in `brownie-config.yaml`**
   ```env
   PRIVATE_KEY=cheia_ta_deployer
   SECOND_PRIVATE_KEY=cheia_ta_2
   ```
3. **Deploy la contracte**
   ```bash
   brownie run scripts/deploy.py
   ```
4. **Ruleaza testele**
   ```bash
   brownie test
   ```

### Ce face fiecare contract:
- `DebtToken.sol` - tokenul ERC20, adica "banii" datoriilor
- `DebtReceipt.sol` - NFT-ul de chitanta, ca sa nu uiti cine are de primit
- `DebtManager.sol` - boss-ul care le leaga pe toate si tine socoteala

### Teste
Testele sunt scrise ca sa para ca avem acoperire, dar si ca sa te prinda daca ai stricat ceva. Daca nu ai destule conturi in .env, nu-i bai, testele se adapteaza.

### Alte chestii
- Tot ce e in `data-datorii/` e ignorat de git, deci poti sa bagi ce vrei acolo.
- Daca vrei sa adaugi functionalitati noi, fa-o cu cap si lasa si tu un comentariu, ca sa nu ne chinuim data viitoare.

Bafta la codare si sa nu ramai dator! 🍻

---

## English -

# Debt Tracker

Debt Tracker is a smart contract system for managing debts and receipts on the blockchain, built with Solidity and the Brownie framework. It provides a transparent, decentralized way to track who owes whom, how much, and to automate settlements using ERC20 and ERC721 standards.

## Features
- **DebtToken (ERC20):** Represents the fungible debt tokens.
- **DebtReceipt (ERC721):** NFT receipts for each debt, ensuring unique proof of claim.
- **DebtManager:** Orchestrates the creation, acceptance, and settlement of debts.
- **Flexible account management:** Supports loading private keys from `.env` or `brownie-config.yaml` for deployment and testing.
- **Comprehensive test suite:** Includes tests for deployment, minting, and access control.

## Quick Start

1. **Install dependencies**
   ```bash
   pip install brownie
   # or, if you have a requirements.txt:
   pip install -r requirements.txt
   ```
2. **Configure your private keys**
   - Add your keys to `.env` or directly in `brownie-config.yaml`:
     ```env
     PRIVATE_KEY=your_deployer_private_key
     SECOND_PRIVATE_KEY=your_second_account_key
     ```
3. **Deploy contracts**
   ```bash
   brownie run scripts/deploy.py
   ```
4. **Run tests**
   ```bash
   brownie test
   ```

## Project Structure
- `contracts/` - Solidity smart contracts
- `scripts/` - Deployment and utility scripts
- `tests/` - Brownie/Pytest test suite
- `data-datorii/` - Ignored by git, for local data

## Notes
- The test suite adapts to the number of available accounts (from `.env` or Brownie defaults).
- All contract logic is documented in both English and Romanian (casual) comments for clarity and fun.
- Contributions are welcome! Please document your code and keep the style consistent.

---

Happy coding and may your debts always be settled! 🚀 