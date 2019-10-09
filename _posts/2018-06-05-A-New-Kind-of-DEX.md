---
layout:			post
title:			"A New Kind of DEX"
date:			2018-06-05
author_name:		"Jake Yocom-Piatt"
author_url:		https://twitter.com/decredproject
author_image:		/images/jy-p_300x300.png
author_location:	"Chicago, US"
author_bio:		"Decred Project Lead"
banner_image:		dex-header.png
tags:			[Decred,decentralized exchange,DEX,atomic swap,decentralized regulation,verifiable volume]
---

Decentralized exchange (“DEX”) is a concept that has received increasing attention in the cryptocurrency domain as a result of exchanges being hacked, used as exit scams or subjected to regulatory actions.  Several cryptocurrency projects exist with the intention of replacing typical centralized virtual-only cryptocurrency exchanges with a token or a blockchain.  We propose an alternative to existing decentralized exchanges with the following properties:

+ It facilitates exchange between only cryptocurrencies, not fiat currencies. 
+ It is architected as a simple client and server, without a corresponding token or a blockchain.
+ Server operators never take custody of client funds.
+ It uses on-chain transactions for order fulfillment and rule enforcement.
+ Server operators collect no fee for matching orders.
+ Adding support for coins is a straightforward matter of adding the corresponding atomic swap support.
+ Orders placed on the exchange can be internally regulated via rules enforced by the clients and the server.
+ Malicious clients are managed using a reputation system based on Politeia.
+ There is an upfront fee to create a client account on a server, to discourage malicious behavior.
+ Order matching occurs pseudorandomly within epochs.
+ Order sizes on both the buy and sell side of a trading pair have standardized lot sizes.
+ Limit orders and cancels are broadcast by clients via the server, but market orders are routed from client-to-client.
+ Near-instant exchange for smaller orders can be achieved through a related off-chain LN-based network which uses atomic swaps.
+ Servers can connect via a mesh network to allow cross-server order matching.
+ External services, e.g. wallets, can access a simple client API on the server that provides a data feed, ability to place orders, and other services.

I believe this infrastructure has the ability to substantially improve the resiliency of the cryptocurrency ecosystem as a whole, and Decred markets more specifically.  In what follows, I will explain the various considerations that have led us to propose the architecture summarized above.

<!--more-->

## Motivation

Anyone familiar with the processes of operating an exchange, using an exchange, or getting a cryptocurrency project added to an exchange knows that there are various gatekeepers that one must deal with.  For operators of centralized exchanges, there are numerous hurdles to cross since taking custody of client funds requires compliance with various jurisdiction-specific regulations and regulatory agencies, e.g. registering with FinCEN, the Bank Secrecy Act, implementing KYC/AML policies, and registering as a money transmitter. For users of centralized exchanges, being subjected to KYC/AML is a substantial invasion of privacy and client funds on the exchange can be frozen at any time, for a variety of reasons. Projects seeking the addition of their cryptocurrency to exchanges are often pressed to pay large listing fees despite the work to add support being straightforward, and many larger exchanges are only interested in listing cryptocurrencies they feel will generate the most profit via trading fees.

Several DEX projects have been created to address some of these issues by replacing the exchange with a blockchain or a token, and they have met with varying degrees of success. While they remove the trusted third party (“TTP”), they insert their own products as a means to capture the trading fees, which replaces the TTP friction with a new platform friction.  The simple act of collecting trading fees serves to act as an incentive to centralize on a given solution, which runs counter to a system of open voluntary exchange.  At the same time a chain or token serves to remove the TTP, it also creates challenges with the order matching, which typically occurs via the intermediate chain or token.

In addition to all the challenges present from the regulatory, user experience and technological perspectives, exchanges and existing DEX projects, along with their corresponding ecosystems, are vulnerable to being exploited by high-frequency trading algorithms (“HFTs”).  HFTs have become an increasingly large influence in equity, commodity and foreign exchange markets since the 1990s, and there have been several notable [“flash crashes”](https://en.wikipedia.org/wiki/Flash_crash) that have occurred as a result of HFTs pulling their ephemeral liquidity simultaneously.  HFTs typically keep the positions they have open at a given time to a minimum, but they open and close these positions with a very high frequency.  They take advantage of the first in, first out (“FIFO”) order matching policies at exchanges and go to extreme measures to have a lower latency than their competition, e.g. have HFTs execute trades from machines very close to the exchange servers, pay large sums for the lowest latency data feeds, use FPGAs or ASICs for order gateways, use microwave or laser relays to lower inter-exchange latency.  While there are attempts to characterize HFTs as positive, e.g. that they add liquidity to the market, that liquidity can disappear in the blink of an eye and acts as pump to siphon funds from less sophisticated market participants to those who operate the HFTs.  Beyond the question of whether it is fair to operate these HFTs, it is clear that operators of HFTs can seriously distort the price of assets they trade, sabotaging the price discovery process.  Many of these HFTs are operated and/or funded by the investment banking arms of major international banks, meaning that despite cryptocurrencies removing the need to use banks for storage and transmission of value, the fiat banking sector can still exert substantial influence over cryptocurrencies via their HFTs.

{% include image_caption.html imageurl="/images/posts/dex-practical-considerations.png" title="Practical Considerations" %}
## Practical Considerations

To make a DEX work, there are a number of basic practical considerations that must be taken into account.  Using atomic swaps, it is possible to perform trustless exchanges of supported cryptocurrencies both on-chain and off-chain.  In order to generate and maintain an order book, there needs to be a meeting place where users can communicate about prices.  To prevent users from submitting fraudulent orders, there needs to a mechanism for users to demonstrate they control the funds their orders correspond to.  Users need to be able to transmit and receive limit and market orders so their orders can be matched. Due to the constraints of on-chain transactions, limit orders must have a standardized size on-chain.  It is possible to start with a simple client-server architecture and then extend it by having the servers relay orders between each other, creating a mesh.

### Atomic Swaps

As we demonstrated with our [atomic swap tools](https://github.com/decred/atomicswap) in the fall of 2017, using a particular minimal-complexity smart contract, it is possible to exchange two separate cryptocurrencies in a trustless fashion, and this process is referred to as an atomic swap.  Due to the trustless nature of the atomic swap, it is a natural basis upon which to build a DEX.  Several other DEX projects make use of atomic swaps for precisely this reason.  An atomic swap can handle settlement of matched orders both on-chain and off-chain, so the task of building a DEX becomes a question of handling the order matching process.

### Client-Server Architecture

Using atomic swaps as the basic building block, we can begin to discuss the broad outlines of the architecture of a DEX.  Several existing DEX projects have made the decision to replace the exchange with either a standalone blockchain or an Ethereum token.  In each case, these projects use the fees associated with trade execution as a means to extract value from the exchange process.  However, the observant reader will note that atomic swaps facilitate exchange without requiring any trusted third party (“TTP”).  We take the position that, instead of recreating a TTP as a blockchain or token, that the most logical path is to create a DEX as a simple client-server service that fully eliminates the need for any TTP.  Blockchains and tokens are very “heavy” solutions and impose a variety of engineering constraints, so avoiding them frees us from these constraints.  In its most basic form, a DEX is simply a meeting place where users who want to exchange cryptocurrencies meet and participate in some price discovery process.  Using a client-server model for a DEX allows us to recreate the most basic form of human exchange in a permissionless context: an on-demand open outcry pit.

### Order Verification

Preventing clients from creating fraudulent orders is an important component of ensuring the DEX operates smoothly.  For on-chain exchange, it is straightforward to demonstrate control of funds by signing order messages with private keys that correspond to funds referenced in an order.  Do note that signing orders using a corresponding private key bleeds the public key, which has some negative security implications, particularly in the context of an adversary with a quantum computer.  The server will need to check each order against either a local copy of the corresponding blockchain or a block explorer service to verify it is valid and properly signed.  Once a client’s order is validated by the server, it can be transmitted to one or more clients by the server.

### Limit and Market Order Routing

A DEX requires support for 2 types of orders: limit orders and market orders.  Limit orders are standing orders to buy or sell at a particular price, and market orders are issued by spot buyers and sellers to get filled at the best price.  The server can either act as a dumb relay, where it simply retransmits orders sent by clients, or it can assemble and maintain the order book, so it only pushes updates to the order book as clients transmit orders.  In either case, limit orders will be broadcast to other clients, whereas market orders will be routed directly to the clients with the matched limit orders.  To prevent the server from faking the order book, the server will transmit only signed orders to clients, so they can verify themselves that the orders in the order book are valid.

### Standardized Lot Sizes

An important detail to consider with an on-chain DEX is how to handle partial fills, e.g. there is limit buy order for DCR of BTC 100 and there are market sell orders being matched against it for BTC 0.1 of DCR.  If we allow for arbitrarily-sized limit and market orders, it creates problems because the client who gets partially filled must create an on-chain transaction to update their signed order, which can take several minutes or longer.  More explicitly, assume we have a limit buy order for BTC 100, a partial fill with a market sell BTC 0.1 is made against it  now the client with the limit buy order has to make change from their original order to settle the partial fill using an atomic swap, forcing them to wait until the BTC 99.9 can be made into a new order and resubmitted to the DEX.  To avoid this problem, the DEX will settle upon standardized sizes for lots on the buy and sell side of each trading pair, where clients are required to place orders using these lot sizes.

### Server Mesh

The minimum viable product for the DEX has a simple client-server architecture, but that model has some shortcomings which can be addressed by creating a mesh of servers that relay orders between each other.  Adding support for server-to-server communication is obviously non-trivial, but it would allow for the creation of worldwide trading pairs, with the bonus that it would be stable under loss or disconnection of large segments of the network, unlike many blockchains.

## Aligning Incentives

Cryptocurrencies have served to demonstrate the immense value that can be extracted from properly aligned incentives, and we aim to reproduce this incentive alignment in the context of the DEX.  For cryptocurrencies, alignment of incentives is related to block subsidies and how to distribute them, and with the DEX, it is a question of how to deal with trading fees, custody of funds and account fees.  As late entrants to the DEX space, we have the luxury of seeing how other DEX projects have approached the question of incentives, rather than having to innovate in a vacuum.

{% include image_caption.html imageurl="/images/posts/dex-zero-trading-fees.png" title="Zero Trading Fees" %}
### Zero Trading Fees

Existing DEX projects all extract fees from each trade via their corresponding blockchain or token, but we take the position that this is the wrong incentive structure.  The collection of fees on trades directly incentivizes centralization of trading by the service provider, whether it is a blockchain, token or a service.  In order to realign incentives with a truly decentralized exchange, we need to eliminate the trading fees from the DEX.  Many prospective users are likely happy to hear this, but many DEX projects or centralized exchanges are not keen to see this being suggested.  It is reasonable to ask “if there are no trading fees, what is the incentive to run a DEX server?”, and the answer is similar to the answer to questions like “if nobody is paying you to operate a mail, chat, or blockchain server, what is the incentive to run it?”.  Running a DEX server provides you and others with a tangible utility, which is low-cost fungibility of value across blockchains.  Thankfully, not everyone needs to operate a DEX server in order for this infrastructure to provide substantial utility.

### Non-Custodial Servers

While atomic swaps do away with the need for the server to take custody of funds, the server not taking custody of funds is another example of incentive alignment.  When an exchange takes custody of funds, its incentives change quite a bit.  It is incentivized to not lose those funds from a reputational and regulatory standpoint, but it is also incentivized to take other (undesirable) actions as a result of those concerns, e.g. collect a vast amount of personal information from users, trace the origin of user funds, share information with law enforcement officials, delay and/or limit withdrawals and deposits.  Beyond these risk-of-loss incentives, there is always incentive present for exchanges to be bad actors, e.g. steal user funds, manipulate the order book, run bots against their own books, provide select users with fee-free accounts, provide latency advantages to select users.  DEX servers not taking custody of funds rules out the majority of these various undesirable incentives.

### Client Account Creation Fee

To prevent malicious clients from causing trouble on DEX servers, we will have a small server-configurable fee for creating a new client account.  For benevolent clients, this amounts to a one-time fee they must pay to access the server’s services, but malicious clients will have to pay this fee repeatedly if they cause trouble and have their account disabled.  These fees will not scale with volume and are intended to act as a spam deterrent, potentially offsetting some of the costs of operating the DEX server.

{% include image_caption.html imageurl="/images/posts/dex-transparency-as-a-tool.png" title="Transparency as a Tool" %}
## Transparency as a Tool

To date, most participants in the blockchain space have viewed the transparency of blockchains as a necessary weakness, but we will be using this transparency as a constructive tool in the context of the DEX.  By performing exchanges on-chain and using cryptographic attestation, both clients and servers can be held accountable for malicious behavior.  Cryptographic proof of malicious client or server behavior will be submitted to a Politeia repository, creating an independently verifiable reputation system for the DEX.  More significantly, it is possible to create the equivalent of consensus rules for one or more DEX servers, allowing the server and clients to dictate and enforce what constitutes an acceptable order, which is a kind of decentralized regulation.  Another beneficial side-effect of using on-chain transparency is that it makes it much more difficult to churn “fake” volume by wash trading, and those who participate in questionable trading practices can be identified.

### On-Chain Transactions for Accountability

When performing on-chain atomic swaps, it is possible for a client on either side of the swap to behave maliciously, so it is necessary to have accountability for this process.  Similarly, it is possible for DEX server operators to behave maliciously, and clients can demonstrate their malicious action by merit of cryptographic receipts for submitted and matched orders.  A combination of on-chain transactions and cryptographic receipts will act as the basis for a reputation system for the DEX.

### Politeia-based Reputation Systems

This reputation system will be based on Politeia, Decred’s time-ordered git-based filesystem, and it will make it clear that a given client or server misbehaved as of a particular time and date.  It is possible to have multiple reputation systems and for them to be either public or private, depending on the use case.  Clients and servers will use these reputation services as a basis for either accepting or denying orders.

### Decentralized Regulation

While the DEX will not be a blockchain, it is possible to create rules that are voluntarily enforced by both clients and servers in the network.  Per the prior comments about the format of orders, there are certain rules that must be adhered to for the DEX to function properly, e.g. that orders must correspond to signed messages demonstrating control of a corresponding amount of unspent coins.  Since the DEX will use on-chain transactions, it is possible to place additional arbitrary constraints on what constitutes a valid order by clients and/or servers, e.g. that a valid order requires that the coins have not moved on-chain for over 24 hours.  It is important that clients and servers agree on what constitutes a valid order or else it could cause issues when matching orders, so these additional rules are analogous to a blockchain’s consenus rules, which are required to be the same across a given blockchain for stability/fork-avoidance purposes.  Even very simple additional rules, e.g. orders are only considered valid if the coins have not moved on-chain for 24 hours or longer, can have significant consequences for the DEX, e.g. limiting clients to churning their coins only once a day.  These additional voluntarily-enforced rules constitute a form of decentralized regulation, which will allow for the DEX to block behaviors considered unacceptable by its clients and servers, e.g. excessive spoofing.

### Verifiable Volume

A major outstanding problem with existing exchanges is that of fake volume.  It is straightforward to setup an exchange and then either outright falsify volume data or have an exchange-operated bot wash trade with itself.  Centralized exchange services have no way to demonstrate that the trades occurring on them are “real” and not falsified or wash trading since the orders occur off-chain and cannot be checked against a distributed ledger.  By having the DEX operate on-chain, the volume data can be externally verified against the corresponding blockchains and the atomic swaps that occur there.  Further, attempts to wash trade can be recognized and filtered out by merit of their on-chain transaction history.  If clients and servers see fit, they can implement rules to prevent wash trading in its various forms.

{% include image_caption.html imageurl="/images/posts/dex-lowering-barriers.png" title="Lowering Barriers to Entry" %}
## Lowering Barriers to Entry

There are many obstacles to both operating an exchange and being a client of an exchange, so the DEX will be built with an eye to simplifying both these processes.  Per prior comments, the DEX will have a simple client-server architecture, which not only makes sense from a practical deployment perspective, but also from the perspective of lowering barriers to entry.  Getting a particular cryptocurrency supported by the DEX is a simple matter of adding support for atomic swaps, which can be done by developers associated with the project rather than the exchange service.  A data feed for each server will be available to its clients, and may optionally offer historical data on trades and be stored in a Politeia repository.

### Simple Client-Server Setup

To keep the DEX decentralized it is ideal to make it simple to setup the server and be added as a client.  Setup for alternatives to the DEX is cumbersome, e.g. creating and maintaining a blockchain or setting up a service with KYC/AML regulatory constraints.  While unlikely, it is possible to block access to a given blockchain inside nation state borders, and the same goes for any exchange service.  Having a client-server architecture with a straightforward setup not only makes it easy to setup new servers and clients, it also enhances censorship resistance.

### Add Support Via Atomic Swaps

Getting a new cryptocurrency supported on exchanges is typically an exercise in patience, politics, payment or some combination of thereof.  The current process for getting listed on exchanges is a real drain on a project’s resources and places artificial restrictions on the liquidity that a given project has access to.  The only requirement for supporting a particular cryptocurrency on the DEX will be support for the corresponding atomic swap, eliminating the existing political and procedural hurdles associated with getting listed on various services.  Simplicity in gaining access to exchange liquidity will help level the playing field between cryptocurrency projects, where some projects can obtain a substantial advantage over others via their exchange listings.

### Client API

Data feeds will be available to clients from their respective server and will be used for both real-time and historical data.  The API will allow clients to get a snapshot of the order book, subscribe for updates to the order book, and access historical data.  Since this data is sourced from the server, the amount of real-time and historical data will vary from server-to-server.  The quality and amount of data available will likely go up substantially once servers can relay between each other.  Wallets that support the DEX will make use of the client API for user interface purposes.

## Latency Games

As cryptocurrency markets have grown in size and maturity, they have become a ripe target for automated trading algorithms, high-frequency trading algorithms (“HFTs”) in particular.  HFTs add substantially to trading volumes cited by exchanges, but the value of this volume is questionable, at best.  The DEX will use pseudorandom order matching within epochs to limit the effects of HFTs, while still allowing for lower frequency clients to get their orders matched fairly.  It is worth mentioning that off-chain payment systems, e.g. the Lightning Network, can be used for exchange, but it is important to understand that there are issues with transparency and price discovery, similar to existing equity or commodity exchanges.

{% include image_caption.html imageurl="/images/posts/dex-pseudorandom-matching.png" title="Pseudorandom Order Matching" %}
### Pseudorandom Order Matching

The extent to which modern financial markets are dominated by HFTs is not often discussed.  Making changes to reduce the influence of HFTs is even less often discussed since exchanges are incentivized to allow their operation by merit of the trading fees they generate.  Some traditional exchanges, e.g. [IEX and CHX](https://www.bloomberg.com/view/articles/2016-08-31/speed-bumps-are-the-hot-new-thing-for-exchanges), have added a 350 microsecond “speed bump” to prevent latency arbitrage below this threshold, and this goes part of the way towards fixing the problem.  Instead of only partially addressing latency arbitrage, which is still possible in the face of a 350 microsecond minimum, the DEX will match orders pseudorandomly within epochs.  Using an epoch of 10 seconds or greater should act to substantially reduce the advantages that can be obtained by clients with low latency connections to their server.  By abandoning a first in, first out (“FIFO”) order matching algorithm, clients can have their orders matched in a demonstrably fair fashion within an epoch while preventing the “queue cutting” behavior required for the successful operation of most HFTs.

### Separate Off-chain Subsystem

Considering the much lower latencies involved with off-chain payment systems, e.g. the Lightning Network, it is natural to examine their utility in the context of the DEX.  A major advantage of the DEX operating on-chain is that the swaps are demonstrable and can be verified as not wash trades.  As Lightning Labs has demonstrated, [off-chain atomic swaps](https://blog.lightning.engineering/announcement/2017/11/16/ln-swap.html) are indeed possible, but verifying matches occurred and that the matches are not wash trades is a non-trivial, and likely very difficult, process.  In light of these issues with transparency and price discovery that come with LN swaps, the DEX could incorporate off-chain swaps as a means for smaller orders to get filled with low latency.  Instead of having an off-chain order book, orders could be filled at the market prices set by the DEX on-chain, where transparency and price discovery can occur with less complexity.

{% include image_caption.html imageurl="/images/posts/dex-big-picture.png" title="The Big Picture" %}
## The Big Picture

Much of this proposal has been about the practical considerations of how an ideal DEX should operate and how that can be achieved using existing cryptocurrency infrastructure.  Taking a step back, what is being proposed here is a multiplexing infrastructure for cryptocurrency exchange.  In the same way that telephone and networking switches multiplex electromagnetic communications, cryptocurrencies and their exchange multiplex the storage, transmission and exchange of value.  The Lightning Network daemon, [lnd](https://github.com/LightningNetwork/lnd), is an excellent example of a permissionless, neutral, non-custodial, smart contract multiplexer, similar to our proposed DEX.  While the DEX will operate on-chain and between cryptocurrencies, lnd operates off-chain and for a given cryptocurrency.

Existing DEX projects have the aim of making such a protocol “fat”, using it as a means to monetize their services, whereas what we are proposing is to intentionally make the protocol “thin”.  By making the protocol thin and removing the incentives to centralize, our goal is to provide long term value by bringing added stability to the cryptocurrency exchange markets.  Putting all cryptocurrencies on a more equal footing in the context of exchange will ease the process of acquiring cryptocurrencies, which will benefit the overall ecosystem.

## Conclusion

Having the ability to exchange cryptocurrencies with minimal friction, risk and centralization is important to the process of cryptocurrency adoption by the wider public.  Implementing the DEX as described above will:

+ make the exchange process permissionless for both projects and users
+ remove gatekeepers, barriers to entry, and most fees
+ be more censorship resistant than an intermediate chain or token
+ reduce the influence of HFTs on the price discovery process
+ protect the cryptocurrency ecosystem liquidity from predation
+ prevent or filter wash trading, creating verifiable volume
+ facilitate decentralized regulation of trading

This preliminary proposal is being made on the Decred Blog since it is relevant for Decred and the wider cryptocurrency community.  Once our own proposal platform, [Politeia](https://blog.decred.org/2017/10/25/Politeia/), is running on mainnet, this proposal will be submitted there, with the goal of finding developers and funding for this project.  We estimate the DEX can be built for USD 1-5M in 6-18 months, depending on the developers who are interested.  If other cryptocurrency projects are interested in collaborating with us to build the DEX, we are totally open to it, feel free to drop by [our Slack](https://slack.decred.org) and join channel #thedex.
