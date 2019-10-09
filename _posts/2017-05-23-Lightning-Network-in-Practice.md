---
layout:			post
title:			"Lightning Network in Practice"
date:			2017-05-23
author_name:		"Jake Yocom-Piatt"
author_url:		https://twitter.com/decredproject
author_image:		/images/jy-p_300x300.png
author_location:	"Chicago, US"
author_bio:		"Decred project organizer!"
banner_image:		lightning_in_practice.jpg
tags:			[Decred,Lightning Network,lnd,smart contracts]
---

[Lightning Network](https://lightning.network) (“LN” for short) is a recently-proposed, and even more recently implemented, low-latency off-chain micropayment system that can work with Bitcoin or other similar cryptocurrencies, such as Decred.  Since LN makes liberal use of smart contracts, the details of how it works are, unsurprisingly, complex.  To make LN more tangible from a non-technical perspective, we will view it through the lens of practical engineering considerations and the concepts that drive those considerations.

The utility of LN is driven by several major considerations in the context of cryptocurrencies:

+ low-latency payments - Many potential use cases for a modern system of transmitting value require a low latency, e.g. point-of-sale purchases.  Waiting for an on-chain transaction places unreasonable constraints on both the time between blocks in a blockchain and what is considered an acceptable delay for payment to confirm.
+ deferred settlement - In order to minimize the number of transactions that flow between banks, banks make use of a net settlement process wherein multiple transactions between a given pair of banks are consolidated into a single transaction at the end of each day.  Since cryptocurrencies effectively allow you to “be your own bank”, having a similar deferred settlement process substantially reduces transaction load on the blockchain and reduces transaction fees, allowing it to scale much better as the transaction rate increases.
+ privacy enhancement - A blockchain for any publicly available cryptocurrency is necessarily a public ledger, even when the details of ledger entries are obfuscated by cryptography.  By taking transactions off-chain, those transactions have their privacy enhanced simply by merit of not being in the public ledger.
+ cross chain atomic swaps - Reliance on centralized exchanges is a major weak point of cryptocurrencies, whether we are talking about exchanges that handle fiat currencies or that handle cryptocurrencies exclusively.  Cross chain atomic swaps will create liquidity between Decred and other cryptocurrencies without the counterparty risk that exists between users and centralized exchanges.

The benefits of LN are clearly quite substantial, per the considerations above.  However, there are some notable weaknesses with LN that users need to be aware of:

+ counterparty theft - Since LN transactions occur off-chain, it is possible for a counterparty in a payment channel to attempt to steal the funds in the channel, but this can only succeed under certain conditions and is preventable.  Conventional on-chain transactions do not suffer from this problem because they are written directly to a blockchain, an immutable ledger.
+ centralization of nodes - LN transactions are handled by a network of nodes that is separate from the underlying blockchain, and there is potential for these nodes to become centralized, despite them not having custody over coins.  Operating a busy LN node is a potentially expensive operation, creating a barrier to entry for operating such a node and correspondingly increasing centralization.

Despite these weaknesses, I believe that the benefits of LN far outweigh the potential downsides.  Each of these considerations is addressed in greater detail below.

<!--more-->

### Low-latency payments

Cryptocurrencies require the regular creation of blocks in a blockchain, which places a lower bound on the average amount of time spent waiting for a transaction to be confirmed as valid.  The average time between blocks can range from 10 seconds to 10 minutes, depending on the cryptocurrency.  In the case of Decred, the average block time is 5 minutes.  With Decred, on-chain transactions take too long to confirm for most point-of-sale applications, e.g. restaurants, bars, retail businesses, and this is assuming there is not a backlog of on-chain transactions.  The only option to fix this while keeping all transactions on-chain is to substantially shorten the average block time, but this still does not address the scenario of on-chain transaction congestion.

By supporting LN, we enable near-instant micropayments for Decred, which means that Decred can be accepted by merchants with a physical retail presence.  Beyond reproducing an experience similar to that of existing fiat banking payment methods, off-chain payments are not subject to the same congestion issues as exist with on-chain payments.  In the absence of LN support, Decred is not a practical means of paying for items in-person, unless the user experience of “we have to sit here for several minutes now” seems acceptable to the customer and merchant.  More generally, LN's low latency allows for integration of Decred with a wider variety of business models.

### Deferred settlement

Banks make regular use of a net settlement process to minimize the number of transactions between a bank and its counterparties.  The typical process involves taking a sum of the outbound payments from bank A to bank B that occur during a given business day, which consolidates what is potentially thousands of outbound payments into a single payment from bank A to bank B.  By deferring settlement between banks, there is a substantial reduction in the number of transactions that are sent between banks.  A payment channel in LN is a deferred settlement path that has a bounded value, which is very similar to the net settlement process that occurs between banks, albeit with a cap on the amount that can flow either direction.  This means that thousands of LN transactions could occur and correspond to only a couple on-chain transactions.

In the same way that banks perform net settlement to simplify interbank tranfers and save on fees, LN reduces the number of on-chain transactions and, correspondingly, reduces the fees.  Storing data on-chain should be avoided unless necessary, and not storing that data allows users to avoid the associated transaction fees.  All blockchains are backed by some type of database of transactions, and as the record count in that database goes up, the performance of the database starts to degrade.  LN will reduce the number of on-chain transactions, which helps minimize the rate at which the database record count grows.

### Privacy enhancement

A requirement of having a functioning blockchain is that the users must be able to download its blocks, meaning that the transactions in those blocks are available to any user.  Even with cryptocurrencies that offer privacy protections, the individual transactions are required to be stored in a block that is publicly available.  With LN, transactions can occur fully off-chain, so that there is no public data corresponding to that transaction.  The only record of LN transactions is with the intermediate LN nodes that relay that transaction between the sender and its recipient, which is a substantial privacy improvement over it being publicly available.

### Cross chain atomic swaps

Anyone who holds cryptocurrency is aware of how much that acquisition process depends on centralized exchanges.  Exchanges that only handle cryptocurrencies are less prone to problems, but they are still major points of centralization.  In the event an exchange must halt some or all of its business, it can have a very serious effect on the value of the cryptocurrencies it trades.  Decentralized exchanges do exist, but they rely on escrow processes and arbitrators.

The addition of LN support allows for both on-chain and off-chain atomic swaps, meaning that trustless cross chain exchanges can occur.  A caveat here is that both Decred and the counterparty chain must support LN for the swaps to occur.  On-chain atomic swaps work well if a low settlement latency is not required, and off-chain atomic swaps can be used if a much lower latency is required.  These swaps are exclusively between cryptocurrencies, so this technique will not work when fiat is involved.  Creating liquidity via cross chain atomic swaps will reduce the counterparty risk associated with exchanging Decred.

### Counterparty theft

Setting up a LN payment channel requires one or both counterparties to make an on-chain transaction and exchange some additional information to initialize the channel.  Since LN transactions occur off-chain, they are not immutable, but they are carefully constructed from smart contracts in a way such that attempted theft of funds from the channel allows the honest counterparty to take the channel funds as a penalty.  While theft of the funds in the channel is possible, LN transactions have built-in protection against this scenario, and stealing the funds requires the ability to prevent a “breach remedy” transaction from the counterparty being mined on-chain.  This theft scenario can only occur when there is substantial congestion for on-chain transactions or miners collectively collude to not mine the breach remedy transaction, both of which constitute a high barrier when you consider most payment channels will only contain a small amount of coins.

### Centralization of nodes

LN transactions are transmitted over a network that is separate from the network used by the underlying cryptocurrency, which means that LN nodes are separate from the underlying cryptocurrency nodes.  The requirements for running a LN node are very minimal if you're an end user, e.g. a consumer or a merchant, you can just start the node, fully fund a channel with another LN node that has good connectivity, and you're set.  If you are planning to operate a busy intermediate LN node that has many channels open to other nodes, you will have to lock some coins to open up channels with your various counterparties.  The requirement that you have “skin in the game” when acting as an intermediate LN node is good in that it incentivizes competent node administration, but it may also lead to a substantial barrier to entry in the future as the relative cost of operating an intermediate LN node becomes high.  If this barrier to entry is too high, it will encourage centralization over time, despite operating a LN node being permissionless.

### Conclusion

Since supporting LN does not break any existing functionality and only adds to Decred's capabilities as a system of value storage and transmission, it is a very attractive target for addition to Decred.  LN is the most immediately useful application of smart contracts I have seen to date because it facilitates low-latency off-chain transactions, which allows for direct competition with existing fiat payment methods.  While LN does have some shortcomings, its weaknesses were carefully considered as part of crafting the smart contracts that enable it, and the weakenesses are minor in comparison to the utility added by LN.  If you would like to comment on this article, please [join us on the forum thread](https://forum.decred.org/threads/lightning-network-in-practice.5377/).
