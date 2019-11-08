---
title:                  "LN & Multi-Owner Tickets"
date:                   2019-11-07
authors:
-  matheusd
tags:			[Decred,lightning-network,split-tickets,multiowner-tickets]
banner_image: "/images/posts/ln-splits-00-banner.png"
---

One consistent question over the past few months as Decred's Lightning Network has entered testnet, is on how it relates to the staking system and if they will be somehow integrated.

Now that [dcrlnd](https://github.com/decred/dcrlnd), our port of the most prominent LN implementation available, is synced to the upstream work and nearing mainnet release, I feel it's time to show one of the things that we've been leading up to: a plan for implementing multi-owner tickets over the Lightning Network.

The greatest benefit of this work is that once deployed, the staking system will be truly approachable by all interested parties, even those without sufficient funds to purchase a full ticket and in the future where lower stake rewards make large on-chain splits uneconomical. 

In this blog post I'll review the motivation for this work and present a rough outline of the constructions and changes that are needed for it to become a reality.

<!--more-->

# Motivation

The [original work](https://github.com/matheusd/dcr-split-ticket-matcher) on multi-owner ("split" or "shared") tickets has seen quite some usage even if still technically marked as beta, not directly integrated to the main GUI wallet (Decrediton), and requiring some expertise to setup.

Over 1000 tickets have voted and over 100 are live right now, as of this writing.

These are modest numbers when compared to the regular individual staking options, but they do show there is demand for a service which allows interested parties to more easily acquire DCR and participate in the staking process, even in the midst of a downward trend for price, both in BTC and fiat terms.

While it's clear that it is useful, the current on-chain solution for multi-owner tickets has severe scalability issues and we've known from the start it wouldn't be around forever. It was implemented that way because that was (relatively speaking) simple and all consensus rules necessary to make it work were already in place - there was no need for any new voting agendas or code in the full node implementation.

We conclude that a second layer solution is needed for split tickets. One that allows multiple owners to come together and fund tickets even if all they had was a fraction of a DCR.

[Lightning Network](https://dev.lightning.community) is the current leading contestant for a permissionless second layer solution for UTXO-based cryptocurrencies such as Decred and Bitcoin and the natural choice to enable large numbers of people to contribute into a single ticket.

As usual, the tricky bits are the nitty gritty details of just _how_ to orchestrate purchasing the ticket, and then disbursing the stake rewards after a vote such that all participants are assured their funds are recoverable in the worst case scenario of a breakdown of communication.

The [on-chain version](https://matheusd.com/post/ticket-splitting-challenges/) of split tickets naturally solves this problem by relying on the consensus rules that enforce the returns of the funds of the ticket to each original financer. Off-chain multi-owner tickets however, cannot rely on that given the UTXOs are generally locked into two-party contracts. 

{{< legendfigure src="/images/posts/ln-splits-01-onchainsplit.png" alt="Typical on-chain split" title="Typical on-chain split ticket with 6 participants. Notice the return addresses are guaranteed by consensus rules so funds are completely safe after a vote or revocation." >}}

For example, in the Lightning Network the channel balance is defined by the UTXO which locks funds in the multisig 2-of-2 script of the channel's parties. While it would be possible to use that UTXO to directly fund a ticket, that's still an on-chain operation and ends up having the same scalability problems as the current on-chain solution. Besides that, users might not want to commit all their available channel funds into tickets, or only one of the parties might be interested in doing so.

Therefore a viable solution for off-chain multi-owner tickets needs to run independently of any and all outstanding channels of the network. It needs to be able to aggregate funds from up to thousands of users into a single output that is used to fund a ticket, and then allow these same users to redeem the stake rewards, potentially months after their initial coordinated purchase and accounting for all possible failure modes.

After quite of bit of design work we're finally at a stage where we can show the outline of the solution for multi-owner split tickets over LN!

It involves some interesting new smart contract constructions, new consensus enforced opcodes, and leads naturally to several changes to the staking system.

This will be a big undertaking which will require touching the entire stack of Decred software. It needs to be more carefully vetted by the larger stakeholder community and is something of a longer term project that will take months to get moving, with a successful payoff only being realized in the future where a much larger audience wants to participate in our on and off-chain decision making processes.

But we do feel it's a worthwhile program to get going. As will be presented in the next few sections, even if this ends up not being _the_ ultimate solution to multi-owner tickets, the byproducts of this work - the new constructions, opcodes and staking changes - are valuable contributions that enable new use cases for the coin.

# Background on LN and Relevant Prior Art

The Lightning Network{{< ref 1 >}} is a second layer solution for instant, secure and largely permissionless payments implemented over a first layer cryptocurrency. While it's outside the scope of this post to explain in detail how LN works, it's useful to give a quick review on it and all the prior art necessary to put the proposed solution in context. Readers intimately familiar with how LN works and its current research landscape may skip this section.

To participate in LN, an end-user must cooperate with a counterparty to _open a channel_ into the network. This consists in both parties cooperating to create a single on-chain output redeemable by a multisig 2-of-2 script. At any one time the parties are holding onto a special transaction called a _commitment_ transaction, which spends the multisig output into two new outputs: one for each party with their corresponding balance.

Payments are done by changing the relative balance of the parties in a channel. Multi-hop payments involving several channels are done by creating an output redeemable by a special script called an HTLC along the payment path. This script basically says _"This output is redeemable by anyone in possession of a [random] number `x` which hash is `hash(x)`"_. Would-be receivers of a payment create an invoice which include `hash(x)` while payers encumber multiple adjacent channels with the HTLC script. Once the final receiver notices the HTLC in one of its channels, it presents the corresponding `x` (called a _preimage_) and updates the relative channel balances with its immediate counterparty. All other nodes in the payment path proceed with the same process in sequence up to the original payer.

{{< legendfigure src="/images/posts/ln-splits-03-htlc.png" alt="Payment via HTLCs in LN" title="Payment by using HTLCs in LN. Only the final receiver knows the preimage x so only they can start the redeeming process." >}}

The HTLC construction offers many interesting use cases besides simply multi-hop payments, some of which contributed to get to the final solution to LN-based multi-owner tickets.

Multi-coin swaps{{< ref 2 >}} can be done as long as both coins support the same hashing function. In that case, a compatible HTLC can be added on channels in both coins performing the same function as a standard atomic swap.

Submarine Swaps{{< ref 3>}} \(or Loop Swaps{{< ref 4 >}}) are a way of atomically swapping on-chain for off-chain funds (or vice-versa). An on-chain output is created encumbered by the same `hash(x)` as the off-chain HTLC. Both are redeemed as usual on their respective networks. From the point of view of the off-chain initiator a _Loop Out_ sends funds from their local balance in a lightning channel to an on-chain output while a _Loop In_ does the reverse and refills the local balance in a channel by sending on-chain funds to a counterparty.

Channel Factories{{< ref 5 >}} are a proposed way of allowing multiple channels to be created from a single output by having multiple users cooperate to create the aggregated multisig n-of-n output and then always maintaining an up to date _allocation_ transaction which splits the funds among them into new LN channels. Timelocks are used to ensure the intermediate state. 

One of the components of Channel Factories is the Invalidation Tree (of transactions){{< ref 6 >}}. Each branch of the Invalidation Tree carries transactions with descending timelocks such that at any one point there is a single path with transactions carrying the smallest (current) timelock. Updates can happen as long as the root branch of the tree has a timelock higher than a given minimum, at which point the tree needs to be cooperatively closed.

Finally, Eltoo{{< ref 7 >}} is a proposed update to the Lightning Network where a new type of signature hash is introduced (`SIGHASH_NOINPUT`) which allows freely binding transactions that update the channel state back to the original funding output such that any future update transaction can spend a previous (erroneously or maliciously published) update transaction removing the asymetry that currently exists between peer's commitment transactions and in general simplifying the architecture of LN.

# Sketch of a Solution

Recall that the main problem to solve to enable multi-owner tickets is tracking the original funds used to purchase the ticket, and allowing all participants to redeem them back after a successful vote or revocation transaction is published.

This is further constrained by the fact that votes can be issued up to about 142 days after the corresponding ticket is purchased and revocations may be needed even after that. Such a long time between these events means cooperation between the original participants in the ticket might break down completely: there's no guarantee the original group can precisely coordinate again to redeem the funds.

Experience with the current software for split tickets indicates that coordinating a group of online users even a single time is hard for low numbers of users. This problem only grows as the number of users increase: the naive solution of simply aggregating funds into an output and requiring cooperation to redeem the funds suffers from the nasty failure mode that any single participant may lock all other's funds and is therefore unacceptable.

The solution to non-cooperation in the worst case scenario is to be able to split the on-chain UTXO into several new outputs, each corresponding to the funds originally submitted by individual users. While a single withheld transaction with one output per user would be a solution to this case, that has the drawback of being _too_ strict. We'd like to support the case of _partial_ cooperation between users, such that all cooperating users can get back their funds off-chain and _only_ the uncooperative ones need to go on-chain at a later time.

A Binary Tree of Transactions is the natural choice for this, given it strikes the optimum balance for cooperation/non-cooperation between random groups of arbitrary numbers of users. The root UTXO can be controlled by a multisig key involving all users and the first transaction splits the funds into two outputs. Subsequent levels further split the funds down to the leaves which are the individual users funds themselves.

This tree of transactions can be prepared in advance during the setup stage of the multi-owner ticket and participants can hold onto it and broadcast the relevant branches in case of non-cooperation.

However the most important open question was: how can we allow partial redeeming of this prebuilt transaction off-chain, such that the tree (or a large portion of it) doesn't need to be published on-chain?

We have now come up with a design to solve this and will provide it in the rest of this post.

# MRTTREE 

Start by observing that an HTLC preimage is simply a 32 bit random number. And secp256k1 private keys, the ones used by Decred and Bitcoin to sign transactions, are also for the most part just 32 bit random numbers.

We can combine these two uses of a single number in a clever way by constructing the tree of transactions such that the leaf outputs are redeemable by a standard HTLC (that is to say, by presenting the preimage `x` to `Hash(x)`) and then ensuring that this exact same `x` is the key that is used to sign the previous corresponding branches of the tree.

This allows off-chain redeeming of funds by using a collaborating third party called a _provider_: the provider will keep the on-chain funds while paying back atomically off-chain. Assuming each individual user is the only one in possession of the preimage that encumbers each leaf output, once they redeem their funds off-chain by presenting the preimage to the provider then the provider is able to rewrite the branches of the tree of transactions such that the funds are sent to it.

{{< legendfigure src="/images/posts/ln-splits-02-mrttree-partial02.png" alt="MRTTREE with partial redemption" title="Partial off-chain redemption of the tree of transactions by users and on-chain by provider." >}}

In the case where all participants collaborate, only a single transaction is sent on-chain and all funds are dispersed off-chain. With partial collaboration, only the non-rewritten branches are sent on-chain minimizing the load on the blockchain and the effective fees paid. And given that each user can claim their funds individually, there's no need for real time collaboration between all users at the exact same time - until the root transaction is published there's ample time for any individual user to redeem their funds off-chain and therefore not pay the higher on-chain fees.

In order to guarantee the requirement that the HTLC preimage corresponds to a given pubkey, we need to introduce a new opcode tentatively called `OP_PUBSECP256K1FROMPRIV`. This new script function would allow us to create a smart contract to ensure that not only a given preimage `x` corresponds to `Hash(x)`, but that it also _at the same time_ corresponds to `Pubkey(x)`.

In addition to this opcode, we would also require `SIGHASH_NOINPUT` to ensure the root UTXO can be freely bound to the vote transaction, which is unknown at the time when a ticket is being purchased.

More details on how to build the Multi-Redeemer Transactions Tree (MRTTREE) can be found in my [first post on LN and Split Tickets](https://matheusd.com/post/ln-split-tickets-01-mrttree).

# Dealing with a variable Stake Reward

There's still an unaddressed issue with the above construction: the stake rewards. The reward reduces over time, and the (pseudo-)random nature of ticket selection means we don't know the exact value of the reward at the time of building the ticket (and the redeeming tree of transactions).

To deal with this we need to introduce yet another opcode and sighash type: respectively `OP_CHECKOUTPUTPERCENTAGE` and `SIGHASH_NOTOUTPUTVALUE`. Combining these two we would be able to create a UTXO script that encumbers the redeeming transaction to have a specific percentage of the input amount in one of its outputs, while still allowing the transaction to be pre-signed without knowing the amounts in advance.

`SIGHASH_NOTOUTPUTVALUE` effectively makes the wallet sign the transaction discarding the output value. But consensus rules on the implementation of `OP_CHECKOUTPUTPERCENTAGE` would ensure the output is _at least_ the specified percentage of the corresponding input amount guaranteeing the users are getting back their relative contribution amounts plus their reward in case of votes.

There are _many_ nuances to implementing these features and how they are effectively applied to allow the MRTTREE construction to be used in multi-owner tickets. There are also plenty of additional considerations for on-chain voting rights, Politeia voting rights, and privacy improvements, so for a deeper look please see my [second post on LN and Split Ticket](https://matheusd.com/post/ln-split-tickets-02-splits).

# Improving Stake Transactions

The current consensus-enforced layout of ticket transactions carries quite some baggage and is much less efficient than it could be. The present ecosystem of Decred software makes the majority of its functions simply obsolete while still lacking features that would improve the blockchain load and allow better support of split tickets.

Therefore, assuming the multi-owner tickets will be moving to the LN version in the near future and will see increased usage, we also propose a set of changes to improve to story of ticket transactions in Decred.

The main change is to do away with the requirement that the number of outputs must be equal to twice the number of inputs (plus the voting output).

For the majority of ticket purchases the corresponding `SSTX_CHANGE` outputs are always empty ([example](https://dcrdata.decred.org/tx/a8efdfb5f475f780a33289c847070a743de809d7db4d4b84e2c15dea8121b7c8/out/2)). And given the most recent privacy work also relying on split transactions for ticket purchases (that is a transaction which creates outputs of the exact required amount for a ticket purchase - [example](https://dcrdata.decred.org/tx/b2997108c53b78b5ac5bdfd7443e592d94d2a5dda706a87544749eafa1ad3e9e/out/0)) it's unlikely that type of output will be used in the future.

Besides that, and even without LN multi-owner tickets, being able to create fan-in and fan-out ticket purchases (that is, ticket purchases that consolidate funds or spread them over multiple redeeming UTXOs) would enable novel methods to build cooperative tickets.

Another aspect that needs to be addressed is the need to improve handling of Politeia voting rights. Today those rights are assigned to the largest (by value) commitment of a ticket purchase, which makes them vulnerable to influence amplification. Having a separate output for an individual key would allow it to be assigned in a pseudo-random fashion, or even with fractional voting power in case of a group key.

For further discussion of the proposed changes, please see my [third post on LN and Split Tickets](https://matheusd.com/post/ln-split-tickets-03-ticket-layout).

# Moving Forward

Hopefully this post was illuminating enough on the scope of the proposed changes. While there are obviously a large number of details to work out and the implementation and deployment of those will take at least months to come, there isn't an immediate pressing need to rush into releasing them. We can take the time to think through the implications of the changes and go through the standard process for each set of individual features.

Some of those can actually be included in already proposed changes (such as the new [signature hash calculation algorithm](https://github.com/decred/dcrd/issues/950)) and most can stand on their own merits (the new opcodes or staking changes) so an iterative approach is best here.

Nevertheless, this does represent a major milestone to Decred and we can safely say we have a concrete plan for a regime where a very large number of users can participate in our staking process in a safe, permissionless manner without incurring further bloat of the underlying blockchain.

My series has a [final post](https://matheusd.com/post/ln-split-tickets-04-summary) with an overview of the proposed changes linking to the previous ones for those that want to venture deeper. And for those who want to help us build the future of Decred, [Stake](https://docs.decred.org/proof-of-stake/overview/), [Contribute](https://docs.decred.org/contributing/overview/) and [Interact](https://decred.org/community/) with the community.

# References

{{% ref-content 1 %}}
Poon, Joseph, and Thaddeus Dryja. "The bitcoin lightning network: Scalable off-chain instant payments." (2016). Available at https://www.bitcoinlightning.com/wp-content/uploads/2018/03/lightning-network-paper.pdf
{{% /ref-content %}}

{{% ref-content 2 %}}
Fromknecht, Conner. "Connecting Blockchains: Instant Cross-Chain Transactions On Lightning" (2017). Available at https://blog.lightning.engineering/announcement/2017/11/16/ln-swap.html
{{% /ref-content %}}

{{% ref-content 3 %}}
Bosworth, Alex. "Submarine Swaps Github Repository" (2019). Available at https://github.com/submarineswaps/swaps-service
{{% /ref-content %}}

{{% ref-content 4 %}}
Lightning Labs. "Lightning Loop Github Repository" (2019). Available at https://github.com/lightninglabs/loop
{{% /ref-content %}}

{{% ref-content 5 %}}
Burchert, Conrad, Christian Decker, and Roger Wattenhofer. "Scalable funding of Bitcoin micropayment channel networks." Royal Society open science 5, no. 8 (2018): 180089. Available at https://royalsocietypublishing.org/doi/pdf/10.1098/rsos.180089
{{% /ref-content %}}

{{% ref-content 6 %}}
Decker, Christian, and Roger Wattenhofer. "A fast and scalable payment network with bitcoin duplex micropayment channels." In Symposium on Self-Stabilizing Systems, pp. 3-18. Springer, Cham, 2015. Available at http://people.cs.georgetown.edu/~cnewport/teaching/cosc841-spring19/papers/new/micropayment-channels-1.pdf
{{% /ref-content %}}

{{% ref-content 7 %}}
Decker, Christian, Rusty Russell, and Olaoluwa Osuntokun. "eltoo: A simple layer2 protocol for bitcoin." White paper: https://blockstream.com/eltoo.pdf (2018).
{{% /ref-content %}}