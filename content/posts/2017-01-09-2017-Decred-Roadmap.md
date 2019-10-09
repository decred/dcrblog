---
title:			"2017 Decred Roadmap"
date:			2017-01-09
authors:
-  jy-p
tags:			[Decred,hard fork,Lightning Network,DAO,RFP]
banner_image: "/images/posts/hoover_dam.jpg"
---

The time for a new Decred roadmap has finally arrived.  While many users have been keen to know where the project is headed in detail, we have intentionally avoided laying out our longer term plans in order to prevent other projects from implementing these ideas before they make it into Decred.  I recognize that our approach with Decred runs counter to most other cryptocurrency projects, which often focus much more on hype and marketing than on development and sound engineering.  Instead of hyping future work in advance of its completion, we have quietly completed our work and will hype it as it goes into production.  Now that we are close to our first major post-launch milestone, hard fork voting, it is a good time to share where Decred will go from here.  Here is a summary of what we have planned for Decred in 2017:

+ **Convert Decred into a stakeholder-directed DAO** - While other projects have attempted to create a DAO via a monolithic smart contract, Decred will build a DAO in several steps, ensuring each component works independently before putting it into production.
	+ **Hard fork voting** - Stakeholders will be able to vote on all hard fork changes to Decred, with only those changes obtaining greater than 75% support being activated.
	+ **Public proposal system** - After hard fork voting is in production, we will create an off-chain system where Decred users can submit proposals for future work to be performed by the development organization, Decred Holdings Group (“dev org” or “DHG”).
	+ **Decentralized control of DHG funds** - Currently, the control of DHG funds is centralized, and this will be resolved by creating a system whereby control of these funds is decentralized, e.g. based on stakeholder voting.
+ **Lightning Network support** - The lightning network is the most directly useful application of smart contracts to date since it allows for off-chain transactions that optionally settle on-chain.  This infrastructure has clear benefits for both scaling and privacy.
+ **Improved GUI wallets** - We have made substantial progress with GUIs, Paymetheus (Windows) and decrediton (Windows, OS X, and Linux), and will continue to improve the user experience.
+ **RFP process change** - To date, the RFP process has involved giving quotes on deliverable sets, and this system is cumbersome to administrate and maintain.  The RFP process will change to one where individuals and businesses will be contracted on a longer term basis to work for the project.  As part of the RFP changes, we will be looking for contractors to do marketing, advertising, documentation and community management work.
+ **Presence at events** - With hard fork voting nearly ready for production, we have some legitimately interesting content to discuss at events.  Our presence at events will ramp up starting in late Q1 2017.
+ **Enhanced privacy** - Starting in late Q2 or early Q3 2017, we will propose a new initiative to enhance user privacy.
+ **Payment integration support** - Instead of only focusing on Decred from a speculative position, we will support efforts to integrate Decred as a payment method for businesses starting in Q1 2017.

Each of these roadmap items is discussed in greater detail below.

<!--more-->

### Hard fork voting 

Bitcoin demonstrated that it is possible to disintermediate the storage and transmission of value, an area that is the mainstay of the banking industry.  Decred will demonstrate that it is possible to disintermediate the process of political decision-making for a cryptocurrency, something that typically requires an elected or appointed official.  Allowing stakeholders to vote on all hard fork changes ensures interested parties have representation in major decisions that will affect Decred, unlike most other cryptocurrencies.  The ability to implement ongoing user-approved hard fork changes will give Decred the ability to continuously adapt and evolve.

This ability to hard fork on an ongoing basis with stakeholder support is key to the decentralized governance that was proposed as part of our February 2016 launch.  In terms of relative difficulty, this hard fork voting is the highest hurdle to cross since it deals with consensus code, which is notoriously brittle and challenging to write.  Instead of knocking out the easier more visible tasks first, we have opted to clear the most difficult hurdle first and move to unlock what we see as the most valuable part of Decred.  We will have a hard fork voting demo for the coming 0.8.0 release, to be followed soon after by a set of hard fork changes to be voted on in the next release.

### Public proposal system 

Once hard fork voting is working, a natural question to ask is “how do you decide on what to vote on?”, which several astute users have pointed out is currently a centralized process.  We are aware that the decisions about what the dev org should work on and what issues get voted on are centralized, and fixing this is a further step towards decentralization of the dev org.  Setting up a system where users can submit proposals for what to work on, fund or vote on is a good way to start.

The proposal infrastructure will be public and off-chain but will be anchored to the Decred chain.  A formal proposal for the software used for this will be made public following hard fork voting going into production.  Getting the proposal system into production should only take a few months and be relatively easy in comparison to the hard fork voting work.

### Decentralized control of DHG funds 

In order to complete the transition from a centralized dev org, DHG, to a decentralized autonomous organization, the Decred DAO, control of the dev org funds must be decentralized.  This will be the last step required before DHG can be dissolved and dev org funds transferred to the Decred DAO.

As the Ethereum Project has learned first-hand, bugs or exploits that affect control of a DAO's funds can create a very serious problem.  Instead of entrusting the funds to a contract that is Turing complete, we will design, implement and test a simple non-Turing complete smart contract that decentralizes the control of funds.  One possible route to take here is to make disbursements of funds from the dev org require generic stakeholder approval, but this and any other proposed solutions will need to be examined from a legal and tax perspective.

### Lightning network support

The [Lightning Network](https://lightning.network/) (“LN”) that builds on top of Bitcoin is the best proposed use of smart contracts I have seen to date.  LN uses minimally-complex non-Turing complete smart contracts to facilitate off-chain transactions, which is something that all cryptocurrency projects should consider supporting from both a scaling and a privacy perspective.  Once enabled, this will allow atomic cross-chain transfers between Decred, Bitcoin and any other project that supports LN, creating a new low-latency low-risk liquidity channel for Decred.

Since Decred is still rather close to Bitcoin in terms of code, it should be straightforward to sync code from btcd to dcrd that will enable the various opcodes and other soft fork changes required to support LN.  Instead of activating these changes via soft forking, as was done in Bitcoin, we will activate these changes via hard fork voting, so our stakeholders will have the opportunity to make the decision to activate LN support.

### Improved GUI wallets

In the past several months, we have made substantial progress with our wallet GUIs, [Paymetheus](https://github.com/decred/Paymetheus/) (Windows) and [decrediton](https://github.com/decred/decrediton/) (Windows, OS X, and Linux).  Decred is based on btcsuite, so it did not have the luxury of inheriting an existing well-used GUI, unlike many projects based on bitcoin-qt  In the next few releases, all the major functions performed by dcrwallet, the command line wallet, will be made available in Paymetheus and decrediton, e.g. using a stakepool, automatic purchasing of tickets and voting support.

The next release will feature substantial improvements to decrediton, which is currently in an alpha state and not recommended for non-technical users.  All basic wallet functions will be working the 0.8.0 release of decrediton, and possibly some of the more advanced features.  As part of hard fork voting, graphical components will be added so that users can easily set their voting preferences without dealing with the command line in both Paymetheus and decrediton.  After the wallet GUIs are "caught up" with dcrwallet's features, we will move onto integrating multisig, the proposal system and LN support.

### RFP process change 

The original prescription for distributing dev org funds was one based on deliverable-driven requests for proposal (“RFPs”).  In some cases this deliverable-driven process worked out rather well, but in others it led to complete inaction on part of the contractors.  What has become clear is that a deliverable-driven process makes sense for certain types of work and not for others.  For example, design work and sysadmin/infrastructure tasks work well on a deliverable-driven basis, while development, documentation, marketing and community management require continuous work over longer periods of time.  In order to make progress on these fronts, we need to find individuals or businesses that are independently motivated and can steadily deliver while being paid in decred.

Having identified the problems with the RFP process from this first iteration, we will begin searching for contractors who are interested in performing ongoing work in the areas of development, documentation, marketing and community management.  Since DHG pays out in decred, a typical contractor would work on the project on a part time basis, submitting a monthly invoice where DHG is billed on an hourly basis, with some maximum billable number of hours per week.  The weakest areas are the community management and marketing, so we will turn our attention to staffing those areas first.  Specifically, we're looking for people who can help maintain and drive participation on the Decred Forum, Slack, Twitter, bitcointalk, reddit and other relevant forums and sites.

### Presence at events 

With hard fork voting going into production in the next 2 releases, Decred will have unique infrastructure for modifying its consensus rules on an ongoing basis, which provides plenty of material for a talk or presentation at conferences.  Previously, it could be argued that Decred did not provide a particularly strong value proposition for its users, but with hard fork voting, that value proposition becomes concrete.  Decred will continue ceding sovereignty over its various functions to the stakeholders as we continue to pursue decentralization as a process, and each step of that process will be something that can be presented and discussed.

Ensuring Decred has a presence at various cryptocurrency conferences and events will be a priority starting in late Q1 2017.  In the meantime, we will publicly and collectively prepare a list of events to attend, either as attendees or as speakers.  I am aware that there is a political dimension to getting speaking time at conferences, so anyone who can help us get speaking time should make a point to get in touch via the forum.  Based on my experience going to Bitcoin conferences over the past several years, I have learned it is very easy to burn a lot of money attending events, so we will need to be cautious with expenditures in this area.

### Enhanced privacy 

The attentive Decred user may have noticed that most of us at Company 0 are pretty serious about privacy and security (see the [previous zkc entry](https://blog.decred.org/2016/12/07/zkc-Secure-Communications/)), so it should be entirely unsurprising to hear that we have plans to enhance privacy in Decred.  To date, several larger cryptocurrency projects have focused on privacy, e.g. Monero, Dash and Zcash.  Based on the level of competition amongst the various privacy-centric projects, we decided to avoid competing in this domain, at least in this early phase of Decred.  In late Q2 or early Q3 2017, we will begin publicly developing a new method of enhancing privacy for Decred.

Since the cryptocurrency privacy domain is so competitive, I will not be sharing any details on what we have planned.  It will be a substantial departure from what is currently in use by other projects, so it should make for a decent surprise.

### Payment integration support

Cryptocurrencies are intended to be used as a system for both the storage and transmission of value, so it is only natural to support the integration of Decred in the context of transmitting value.  Giving merchants the ability to accept decred as payment or to spend it with their vendors creates utility, liquidity and value for Decred.  The integration work needed to support Decred can take many forms, e.g. WooCommerce plugin, supporting fiat-to-decred exchange, or adding support to an existing payment processor.  Integration work for accepting payments in decred will require several groups of people collaborating: merchants, implementors, developers and payment processors.

Initially, it is ideal to isolate support to the larger platforms and more technical merchants, e.g. top e-commerce solutions, larger altcoin payment processors and more technologically adept merchants.  An ideal scenario for a payment integration would have the following properties:

+ The merchant is sufficiently technologically adept to use and nominally understand Decred.
+ The merchant is located in a jurisdiction with a volatile currency and/or capital controls, e.g. Venezuela, so that Decred's volatility is less of an issue.
+ The merchant routes some portion of their sales and/or purchases via Decred.
+ The merchant and their counterparty are in jurisdictions where other individuals or businesses can assist with fiat-to-decred (or vice versa) liquidity.
+ The merchant uses decred as a store of value.
+ The merchant makes larger transactions in decred.

While it's obviously not possible for every interested merchant to satisfy this checklist, it serves to demonstrate the ideal scenario where Decred and merchants can mutually benefit from payment integration.  If you own a business and are interested in using decred as a payment method or store of value, come interact with us on the forum to see what your options are.  We will begin discussing what integration work to start with on the forum this week and merchants can expect several options to be available by end of Q1 2017.

### In conclusion

After quietly grinding on Decred for the past several months, we are at the point where we are preparing hard fork voting infrastructure that is both unique and decentralizes much of the control over the project typically retained by the project developers and founders.  We look forward to making decentralized decisions with our stakeholders and building a stakeholder-directed Decred DAO.  The roadmap presented above is comprised of tangible components, most of which will be completed in 2017.  Some of the goals presented are of an ongoing nature, e.g. payment integration, enhanced privacy, and RFP refinements, so those will reappear in future roadmaps.  If you have any questions, ideas or comments about this roadmap, I encourage you to comment in [the forum thread](https://forum.decred.org/threads/2017-decred-roadmap.4937/).
