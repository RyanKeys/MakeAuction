#!/usr/bin/python3

from brownie import Auction, accounts


def main():
    account = accounts.load('metamask')
    return Auction.deploy(100000000, account, {'from': account})

