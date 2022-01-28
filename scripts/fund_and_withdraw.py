from brownie import FundMe, network, config, accounts
from scripts.helpful_scripts import get_account

AMOUNT_OF_ETH = 1


def fund_contract():
    fundme = FundMe[-1]
    account = get_account()
    # print(fundme.address)
    required_amount = fundme.getEntranceFee()
    print(required_amount)
    print(f"Entry fee is {required_amount}")
    print("Funding contract")
    # print(required_amount)

    transaction = fundme.fund({"value": required_amount, "from": account})
    transaction.wait(1)
    print("amount available to withdraw")
    print(fundme.addressToAmountFunded(account))


def withdraw_contract():
    fundme = FundMe[-1]
    account = get_account()
    transaction = fundme.withdraw({"from": account})
    print("amount remaining after withdraw")
    print(fundme.addressToAmountFunded(account))


def main():
    fund_contract()
    withdraw_contract()
