import pytest
from brownie import accounts, DebtToken, DebtReceipt, DebtManager, config

# Functie helper ca sa incarcam toate cheile din config (din .env/.yaml)
def get_env_accounts():
    keys = []
    wallets = config.get("wallets", {})
    for k, v in wallets.items():
        if isinstance(v, str) and len(v.strip()) >= 64:
            try:
                acc = accounts.add(v)
                keys.append(acc)
            except Exception as e:
                print(f"Nu am putut adauga cheia {k}: {e}")
    # daca nu am gasit nimic, punem macar accounts[0]
    if not keys:
        keys.append(accounts[0])
    return keys

# test simplu sa vedem daca merge deploy la token
def test_debt_token_deploy():
    env_accounts = get_env_accounts()
    deployer = env_accounts[0]
    token = DebtToken.deploy({'from': deployer})
    assert token.name() == "Debt Token"
    assert token.symbol() == "DEBT"

# test random, sa vedem ca initial nu are nimeni tokeni
def test_balanta_initiala_e_zero():
    env_accounts = get_env_accounts()
    user = env_accounts[0]
    token = DebtToken.deploy({'from': user})
    n = min(3, len(env_accounts))
    for i in range(n):
        assert token.balanceOf(env_accounts[i]) == 0

# test ca mint-ul merge doar daca esti boss (owner)
def test_mint_doar_owner():
    env_accounts = get_env_accounts()
    if len(env_accounts) < 2:
        print("Nu avem destule conturi pentru testul asta, il sarim.")
        return
    owner = env_accounts[0]
    not_owner = env_accounts[1]
    token = DebtToken.deploy({'from': owner})
    token.mint(not_owner, 123, {'from': owner})
    assert token.balanceOf(not_owner) == 123
    failed = False
    try:
        token.mint(owner, 1, {'from': not_owner})
    except Exception:
        failed = True
    assert failed

def test_token_symbol_nu_e_gol():
    env_accounts = get_env_accounts()
    user = env_accounts[0]
    token = DebtToken.deploy({'from': user})
    assert token.symbol() != "" 