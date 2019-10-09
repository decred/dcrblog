---
layout:			post
title:			"2018 Decred Roadmap"
date:			2018-02-28
author_name:		"Jake Yocom-Piatt"
author_url:		https://twitter.com/decredproject
author_image:		/images/jy-p_300x300.png
author_location:	"Chicago, US"
author_bio:		"Decred Project Lead"
banner_image:		2018_decred_roadmap.png
tags:			[Decred,roadmap,Politeia,DAE,Lightning Network,SPV,decentralized exchange]
---

It is finally time for the 2018 Decred roadmap to be released.  2017 has been quite an eventful year for both Decred and the entire cryptocurrency domain, with exchange rates surging and a substantial increase in interest from the conventional finance sector.  Decred has continued with its approach of generating deliverables before hyping them, despite many other projects in the space continuing to relentlessly hype their work far in advance of generating deliverables or focusing on exchange listings in lieu of doing any substantive work.  We have substantially improved our marketing in the past several months and expect a strong uptrend to continue on this front throughout 2018.  Here is a summary of what we have planned for the rest of 2018 and early 2019:

+ **SPV Wallet Support** - Instead of taking the typical wallet service approach where wallets connect to a centralized server, we have added support for a proper SPV mechanism that uses compact filters and works over the P2P network.
+ **Politeia Voting** - Our proposal system is nearing completion and will allow users and stakeholders to make proposals, dictate what does and does not get funded, and participate in project-level decision-making.
+ **Lightning Network** - The bulk of the work to port Lightning Labs’ lnd to Decred has been completed and it will be released soon.
+ **Initial Privacy Release** - Privacy work has begun in earnest and we will make an incremental privacy release where we release working code and give further information about our plans and approach.
+ **Decentralized Control of Funds** - While Politeia voting will be used to control the flow of dev org funds in the meantime, we will be creating a smart contract that will fully decentralize control of the dev org funds.
+ **Decentralized Autonomous Entities** - Using a similar method as that used to decentralize control of the dev org funds, we will allow for the creation of DAEs on the Decred chain.
+ **Scalability Optimizations** - A variety of changes, some of which are consensus changes, are required to improve the scaling properties of Decred, e.g. a new signature algorithm, multipeer sync support, and header commitments.
+ **Decrediton Integrations** - The Decrediton GUI will be adding new integrations to support SPV, mobile, Politeia voting and Lightning Network.
+ **Decentralized Exchange** - We will draft a proposal for a cryptocurrency-only decentralized exchange and share it publicly.
+ **Marketing Growth** - Decred has lined up a presence at many of the premier cryptocurrency trade shows for the rest of 2018 and will continue dialing up its marketing efforts.

These roadmap items are discussed in greater detail below.

<!--more-->

### Timelines

In prior roadmap updates, I have attempted to manage users’ expectations by providing estimated completion dates, e.g. Q1 2018.  What has ended up occurring as a result of this attempt to manage expectations is that there is a vocal and confrontational minority of users who will use these estimated dates as grounds to complain about the project.  If we observe how other cryptocurrency and other software projects manage their milestones, it is typical to not include a date and rather have a list of current outstanding milestones.  After experiencing the ire of these upset users on several occasions, I believe that adopting a similar approach is ideal, where milestones are listed and they are marked as completed as the work is performed.
 
### SPV Wallet Support

Many cryptocurrency projects have punted on creating a proper SPV wallet and instead opted for wallets that make use of a centralized service for receiving payment notifications.  There is certainly a level of convenience that comes with such a service, but there are often subtle consequences, e.g. that you upload an extended pubkey to the service and it knows all your addresses.  We have opted to add SPV support to dcrwallet by integrating compact filters, which is a superior method of SPV that preserves the user’s privacy while minimizing the amount of data that needs to be downloaded prior to the wallet being usable.  Compact filters came from [discussions on the bitcoin-dev mailing list](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-June/014474.html) and was initially proposed by Alex Akselrod and Olaoluwa Osuntokun from Lightning Labs.  As of late February 2018, a full copy of the Decred chain uses 2.1 GB of storage, compared to 66 MB of storage for the headers and compact filters required by the SPV wallet.  Users interested following this SPV work more closely can do so [here](https://github.com/decred/dcrwallet/issues/1000).

### Politeia Voting

The core of our proposal system, [Politeia](https://github.com/decred/politeia/), was recently completed, and we are adding support for voting.  Politeia can be described succinctly as a git repository that is timestamped by the Decred chain and uses cryptographic attribution to create accountability for all participants - users and admins alike.  Having superior accountability means that proposals, comments, votes and admin actions in Politeia will not suffer from the opaque censorship that has become increasingly common amongst many major tech companies and their websites.  Once voting support is complete, Politeia will be tested on testnet and then deployed on mainnet.  After Politeia is up on mainnet, we will use it to discuss and fund new proposals, set budgets and to make ongoing payments with stakeholder approval.  It is worth noting that voting on Politeia will be restricted to stakeholders whose tickets are live in the ticket pool at the time a vote is called for a given proposal.

### Lightning Network

Most of the work to port Lightning Labs’ lnd to Decred is done, and the remaining work is being completed currently.  Decred is a fork of Bitcoin, but Decred lacks many of the changes that were bundled into Bitcoin’s “segregated witness” changeset and this made porting lnd quite a challenge.  There are some outstanding issues with transaction signatures that need to be sorted out, at which point testing can begin on testnet.

### Initial Privacy Release

Due to the extent of competition in the privacy subdomain, we have been reticent to expose our plans for privacy for Decred.  Several months ago, dev work started in earnest and steady progress is being made towards a prototype that can be published as part of our initial privacy release.  This initial release will be comprised of working code and a summary of our plans for several further related improvements.

### Decentralized Control of Funds

The final step to complete the decentralization of our dev org will be decentralizing control of its funds.  Prior to formal control being decentralized, disbursements of funds will be subject to “soft” decision making via Politeia.  Rather than taking the approach used in Ethereum, which involves 100s or 1000s of lines of Solidity code, we will create a succinct smart contract that allows Decred stakeholders to vote on the disbursements on-chain and release the funds.

### Decentralized Autonomous Entities

The method for decentralizing control of the dev org funds will be generalized to support user-created entities that we refer to as decentralized autonomous entities (“DAEs”).  Since the main distinguishing point of a corporate entity relative to an individual is ownership and control of funds and assets, we will use decentralized control of funds as the basis for DAEs within Decred.  We will focus less on the speculative component of tokenization and more on the fundamental mechanics of making it work since tokenization creates several serious scalability issues, which have led to substantial congestion on the Ethereum chain.  In short, a DAE will be comprised of a simple on-chain smart contract that delegates control over funds in the contract to a group of individuals.

### Scalability Optimizations

In order to make Decred operate smoothly at scale, myriad optimizations need to be performed on an ongoing basis.  Since software optimization often involves a lot of details, here is a list the major planned optimizations:

+ [new signature algorithm](https://github.com/decred/dcrd/issues/950)  Changing the signatures algorithm to SigHashAllValue fixes the quadratic scaling issue Decred inherited from Bitcoin, drastically speeding up signature verification.
+ mulitpeer sync support  Currently, dcrd can only sync its chain from a single peer at a time, which leads to long initial sync times, especially when connecting to a slow peer, and syncing from multiple peers simultaneously would remove that bottleneck.
+ [header commitments](https://github.com/decred/dcrd/issues/971)  Decred’s block headers can be modified to support a variety of commitments, e.g. for compact filters, unspent transaction outputs, and ticket journaling, which allows for SPV clients to operate securely, secure blockchain pruning, and tracking ticket pool state with a SPV client.
+ Schnorr signatures  Signatures from multiple private keys can be aggregated into a single signature, leading to a substantial savings on network and storage for Decred nodes.

### Decrediton Integrations

To many users, features that are not available in a nice graphical interface effectively do not exist.  Decrediton, our cross-platform GUI wallet, will be integrating support for several of our subprojects that are nearing completion: SPV support, mobile platforms, Politeia voting and the Lightning Network.  Progress on these integrations can proceed in parallel and should be much more routine than the work required to complete the underlying backend components.

### Decentralized Exchange

We released the [atomicswap tools](https://github.com/decred/atomicswap/) in September 2017 as a useful standalone component of a larger and more significant project, a decentralized exchange.  Many projects have made it their mission to decentralize the exchange process, and they have a variety of different profit models.  Our proposal for a decentralized exchange will be based on principles before profits and will be created as an open effort, which we hope will involve other cryptocurrency projects besides Decred.  The initial proposal for this system will be the next Decred blog entry and become a formal proposal within Politeia once it is live on mainnet.

### Marketing Growth

A substantial amount of work has been done on the marketing front in the past 6 months.  Decred has booths and speaking spots lined up at many of the larger cryptocurrency events for the next several months and has attended several other conferences in the past few months.  Initial testing has been done on paid advertisements via several digital marketing services, e.g. Facebook, Twitter, and Google.  We will substantially scale up digital marketing as we continue to establish metrics on the effectiveness of various approaches.  To date, our presence has been strongest at US events, and we will be making an effort to broaden our presence to include additional countries throughout 2018.

### Conclusion

There are a lot of deliverables listed on this roadmap and we’ll make an effort to knock out as much of this as we can in 2018.  I, personally, am looking forward to Politeia voting going live on mainnet since it will put the dev org funds, approximately DCR 460,000, or USD 33,000,000 at the current exchange rate, into the hands of stakeholders.  While we cannot know precisely what will happen when these funds are directed by our stakeholders, we are all here because of the belief that decentralized decision making, a form of collective intelligence, is a promising sovereignty model.  Building the infrastructure around a new sovereignty model leads naturally to novel new applications of that sovereignty, e.g. Politeia, DAEs, and the concept of digital statehood.  We are always looking for new contractors, so if this excites you or you see something you want improved, we encourage you to show up, work with us, build stuff and get paid  in decred, of course.  We can be reached on our [Rocket.Chat](https://rocketchat.decred.org), [Matrix](https://riot.im/app/#/room/#general:decred.org), [Discord](https://discord.gg/GJ2GXfz), [Slack](https://decred.slack.com/), [IRC](https://webchat.freenode.net/?channels=decred&uio=d4), [Telegram](https://t.me/decred), [Reddit](https://reddit.com/r/decred) or our [Forum](https://forum.decred.org/). Note that Slack invites must be manually requested via one of the other chat networks before access can be granted.
