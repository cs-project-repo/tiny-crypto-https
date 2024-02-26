# Tiny Crypto Token/Coin Anonymizer with Merkle Trees

## Introduction

Welcome to the Tiny Crypto Token/coin anonymizer repository. This project aims to provide a solution for anonymizing cryptocurrency transactions using Merkle Trees. By following the code provided, you can leverage this tool to enhance privacy and security in your cryptocurrency transactions.

## Features

Anonymize cryptocurrency transactions.
Utilizes Merkle Trees for transaction validation.
Supports various cryptocurrencies and networks.
Installation
To get started with this project, follow these steps:

              ROOT
             /    \
         H(1-2)   H(3-4)
         /  \      /   \
      H1    H2  H3     H4
      / \   / \ / \    / \
    L1  L2 L3 L4 L5   L6  L7  L8

You can use the zkpWithdraw function to anonymize your cryptocurrency transactions. Here's an example of how to use it:

## Usage

```
const leaves = [/* List of leaves */];
const leaf = /* Your leaf */;
const address = /* Your address */;
const coin = /* Your coin */;
const amount = /* Your amount */;
const zeta = /* Your zeta */;
const coinPreImage = /* Your coin preimage */;
const amountPreImage = /* Your amount preimage */;
const coins = [/* List of coins */];
const recipient = /* Recipient's address */;
const network = /* Your network */;

zkpWithdraw(leaves, leaf, address, coin, amount, zeta, coinPreImage, amountPreImage, coins, recipient, network)
.then(() => {
    console.log('Transaction anonymized successfully');
})
.catch((err) => {
    console.error('An error occurred:', err);
});

```
Replace the placeholders with your actual data and parameters.
