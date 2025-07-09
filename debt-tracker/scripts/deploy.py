from brownie import accounts, DebtToken, DebtReceipt, DebtManager, network, config

def main():
    """
    Implementează întregul sistem de 3 contracte și configurează proprietarii.
    """
    print(f"Folosind rețeaua: {network.show_active()}")
    
    # contul din .env
    deployer = accounts.add(config["wallets"]["from_key"])
    print(f"Contul de implementare: {deployer.address}")

    # 1. Deploy contractele de token
    print("Implementare DebtToken...")
    debt_token = DebtToken.deploy({'from': deployer})
    print(f"-> DebtToken implementat la: {debt_token.address}")

    print("Implementare DebtReceipt...")
    debt_receipt = DebtReceipt.deploy({'from': deployer})
    print(f"-> DebtReceipt implementat la: {debt_receipt.address}")

    # 2. Deploy contractul DebtManager
    print("Implementare DebtManager...")
    debt_manager = DebtManager.deploy(
        debt_token.address,
        debt_receipt.address,
        {'from': deployer}
    )
    print(f"-> DebtManager implementat la: {debt_manager.address}")

    # 3. Transfer proprietatea contractelor catre DebtManager
    print("Transfer proprietate DebtToken către DebtManager...")
    tx1 = debt_token.transferOwnership(debt_manager.address, {'from': deployer})
    tx1.wait(1)
    
    print("Transfer proprietate DebtReceipt către DebtManager...")
    tx2 = debt_receipt.transferOwnership(debt_manager.address, {'from': deployer})
    tx2.wait(1)

    print("\n=== IMPLEMENTARE COMPLETĂ ===")
    print(f"Adresa DebtManager: {debt_manager.address}")
    print(f"Adresa DebtToken: {debt_token.address}")
    print(f"Adresa DebtReceipt: {debt_receipt.address}")
    print("\nCOPIAZĂ ACESTE ADRESE în fișierul index.html!")
