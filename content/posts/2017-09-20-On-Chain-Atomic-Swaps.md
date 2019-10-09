---
title:			"On-Chain Atomic Swaps"
date:			2017-09-20
authors:
-  jy-p
tags:			[Decred,atomic swap,Litecoin,Bitcoin,OTC,exchange]
banner_image: "/images/posts/atomic_swap.png"
---

As many of you know, yesterday marked the [first cross-chain atomic swap between Decred and Litecoin](https://twitter.com/decredproject/status/910224860625780736). This is an important step in a direction that allows users to conduct trustless, cross-chain, over-the-counter (“OTC”) trades without a third party. This disintermediates the exchange process between cryptocurrencies that support these swap transactions. We have created some simple prototype tools under the [atomicswap repository](https://github.com/decred/atomicswap/), dcratomicswap, btcatomicswap and ltcatomicswap, to allow Decred, Bitcoin and Litecoin users to swap between DCR, BTC and LTC using on-chain atomic swaps. These tools were built for those who we have the means at hand to disintermediate the exchange process: transaction script and OP_CLTV support. It is worth noting that these tools do not address the issue of order book management that is typically performed with full-featured exchanges. There are some privacy and transparency consequences related to on-chain atomic swaps that are not present with centralized exchanges. As of this announcement, the tools are text-based, but we will be integrating this into the Decrediton GUI wallet in a future release. The process for on-chain atomic swaps is described in more detail below.

<!--more-->

### Prerequisites

In order to perform an on-chain atomic swap between 2 cryptocurrencies, there are several prerequisites.  Both chains must support:

+ branched transaction scripts
+ the same hash algorithm in both chains' transaction scripts
+ signature checks in transaction scripts
+ CheckLockTimeVerify or CheckSequenceVerify (“CLTV” and “CSV” for short) in transaction scripts

Since Decred and Litecoin are forks of Bitcoin, the first 3 conditions are trivially satisfied.  Further, both Decred and Litecoin have been tracking updates from Bitcoin, so they both support CLTV.  The CLTV/CSV support is used to effect a refund, in the cases where either party does not complete part of the process.  With some further work on part of other Bitcoin-based cryptocurrency projects, this on-chain atomic swap can occur between any pair of cryptocurrencies that satisfy the above constraints.

### Use Cases

On-chain atomic swaps are not useful in all cases where users want to perform an exchange.  This process is well-suited to larger trades that do not require a particularly low latency or high frequency.  Since the process involves on-chain transactions, the speed of the process is bound by the mining of blocks, which can take roughly an hour in a worst-case scenario with Bitcoin.  Additionally, users must pay transaction fees for both the swap transaction and the redeem transaction on each chain, which can have a non-trivial cost with Bitcoin.

### Privacy 

Since these swaps are on-chain, there are some privacy implications that users should be aware of.  The swap transactions on each chain include the same hashed value, meaning that anyone doing passive surveillance of the corresponding blockchains can link the coins on one side of the swap to the coins on the other side.  This is a different threat model than typical centralized exchanges, where the exchange is required by nation state regulations to retain records of user identities and activity.  Instead of having to request data from an exchange, interested parties can follow the coins from one chain to the other.  However, despite the ease of determining provenance of the coins across chains, there is no associated identity data available on the counterparties.

### Transparency

In contrast to the way trading works at exchanges, attempts to churn volume via on-chain atomic swaps will be detectable by passive observers.  This means that users cannot show up with a small amount of coins and then create a ton of fake volume covertly.  In this sense, atomic swaps are a true return to the “moneychanger mat” scenario of the past, before the “casinoization” of exchanges.

### Integration

Currently, this process uses a standalone binary on each side of the swap, e.g. a DCR binary and a BTC binary on each side.  The swap process has 3 steps on each side, requires some manual relaying of information via an existing communications channel, e.g. email or instant messaging, and uses a text interface, which is obviously less than ideal.  Over the next several weeks, we will integrate this process into the Decrediton GUI wallet to simplify it and automate some of the process.  It is our hope that a similar integration can occur with Bitcoin-QT and Litecoin-QT as well, for ease of use.  Detailed instructions on executing an atomic swap can be found [here](https://github.com/decred/atomicswap/).

The atomic swap process has been tested against dcrwallet (CLI), Decrediton (GUI), Bitcoin Core, and Litecoin Core.

### Conclusion

We hope that Decred, Bitcoin and Litecoin users get some utility out of these tools and ultimately integrate them into their respective GUI wallets.  On-chain (and ultimately off-chain) atomic swaps are an exciting technology that earmarks a leap in cryptocurrency: the direct empowerment of users. Decred will be active in this space and continue to innovate toward this goal. We are interested in integrating support for additional cryptocurrencies, so atomic swaps can occur between many different chains.  Please contact us for advice on supporting swaps for your cryptocurrency on [GitHub](https://github.com/decred/atomicswap/), [Slack](https://decred.slack.com/), [Reddit](https://reddit.com/r/decred/) or [our Forum](https://forum.decred.org/).
