from brownie import accounts, DebtToken, DebtReceipt, DebtManager, network, config

def main():
    print(f"Using network: {network.show_active()}")
    
    # Use account from .env
    deployer = accounts.add(config["wallets"]["from_key"])
    print(f"Deployer account: {deployer.address}")

    # 1. Deploy token contracts
    print("Deploying DebtToken...")
    debt_token = DebtToken.deploy({'from': deployer})
    print(f"-> DebtToken deployed at: {debt_token.address}")

    print("Deploying DebtReceipt...")
    debt_receipt = DebtReceipt.deploy({'from': deployer})
    print(f"-> DebtReceipt deployed at: {debt_receipt.address}")

    # 2. Deploy DebtManager
    print("Deploying DebtManager...")
    debt_manager = DebtManager.deploy(
        debt_token.address,
        debt_receipt.address,
        {'from': deployer}
    )
    print(f"-> DebtManager deployed at: {debt_manager.address}")

    # 3. Transfer ownership to DebtManager
    print("Transferring DebtToken ownership to DebtManager...")
    tx1 = debt_token.transferOwnership(debt_manager.address, {'from': deployer})
    tx1.wait(1)
    
    print("Transferring DebtReceipt ownership to DebtManager...")
    tx2 = debt_receipt.transferOwnership(debt_manager.address, {'from': deployer})
    tx2.wait(1)

    print("\n=== DEPLOYMENT COMPLETE ===")
    print(f"DebtManager address: {debt_manager.address}")
    print(f"DebtToken address: {debt_token.address}")
    print(f"DebtReceipt address: {debt_receipt.address}")
    print("\nCOPY THESE ADDRESSES to your frontend file!")