#!/usr/bin/env bash

# Read the RPC URL
echo Enter Your RPC URL:
echo Example: "https://eth-goerli.alchemyapi.io/v2//XXXXXXXXXX"
read -s rpc

# Read the contract name
echo Which contract do you want to deploy \(eg Greeter\)?
read contract

forge create ./src/${contract}.sol:${contract} -i --rpc-url $rpc --constructor-args "0xf4a6B43Db2f8AeD243d7D14496957aB80486040e" "0xf4a6B43Db2f8AeD243d7D14496957aB80486040e"
