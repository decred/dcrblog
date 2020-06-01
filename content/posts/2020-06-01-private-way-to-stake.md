---
title: "A More Private Way to Stake"
date: 2020-06-01
authors:
-  jholdstock
tags: [Decred,cryptocurrency,privacy,Proof-of-Stake,CoinShuffle++]
banner_image: "/images/posts/private-way-to-stake.png"
---

The Decred community considers privacy to be a fundamental human right.

Protecting the privacy of Decred users has been a core tenet of the project
since it's inception. To quote the [Decred
constitution](https://docs.decred.org/governance/decred-constitution/):

> Privacy and security are priorities and shall be balanced with the complexity
> of their implementations. Additional privacy and security technology shall be
> implemented on a continuing and incremental basis, both proactively and
> on-demand in response to attacks.

In late 2019, Jake Yocom-Piatt revealed a much anticipated [privacy
solution](https://blog.decred.org/2019/08/28/Iterating-Privacy/) for Decred -
[CoinShuffle++ (CSPP)](https://docs.decred.org/privacy/cspp/overview/). The
introduction of CSPP enables users to anonymize their Decred by mixing with the
steady stream of ticket transactions which flow through the network as part of
its [hybrid PoW & PoS](https://docs.decred.org/research/hybrid-design/)
consensus mechanism.

The community response has been emphatic. Over 22% of the [circulating
supply](https://dcrdata.decred.org/charts?chart=coin-supply&zoom=ikd7pc00-khv7pxc0&bin=day&axis=time&visibility=true-true-true)
of Decred currently resides in mixed UTXOs.

The CSPP announcement highlighted that additional work would be required for VSP
users to participate in mixing. Given that up to 50% of tickets at any time are
held by VSPs, it is reasonable to approximate that enabling VSP tickets to be
mixed could double CSPP participation.

After working on the problem with [David Hill](https://github.com/dajohi) for a
few weeks, I am pleased to announce that work on a [new VSP
implementation](https://github.com/decred/vspd) is nearing completion.

<!--more-->

## Voting Service Providers

Participating in Decred's Proof-of-Stake system requires the use of an
always-online wallet. Those who are unable or unwilling to maintain their own
internet connected computer 24/7 can choose to use a [Voting Service Provider
(VSP)](https://docs.decred.org/proof-of-stake/how-to-stake/#pos-using-a-voting-service-provider-vsp).
A VSP maintains a pool of online voting wallets, and will allow users to add
their tickets to the wallets in exchange for a small fee. VSPs are completely
non-custodial - they never have access to any of their user's funds - the user
is *only* giving the VSP the rights to vote their tickets.

Until now, VSP operators have offered this service to users by running
[dcrstakepool](https://github.com/decred/dcrstakepool). This software works well
and has a proven track record of almost four years. Currently, VSPs running
dcrstakepool are trusted with the voting rights of over 14,500 tickets with an
approximate value of 2 million DCR.

When a user wants to use a VSP running dcrstakepool, they must purchase their
ticket in a particular way such that a portion of the ticket [vote
reward](https://docs.decred.org/advanced/issuance/) is automatically paid to the
VSP. As a result, VSP tickets have a different on-chain footprint to tickets
bought by solo voters, which makes them identifiable by an outside observer
performing on-chain analysis. This footprint is problematic because it prohibits
VSP users from taking full advantage of the privacy offered by CSPP - VSP
tickets cannot be mixed in the same anonymity set as solo tickets.

## Introducing vspd

[vspd](https://github.com/decred/vspd) is a from scratch implementation of a
Voting Service Provider (VSP) for the Decred network. It has been created with
user privacy as a fundamental design goal.

vspd does not require tickets to be purchased with any special conditions such
as the built-in fee payment required by dcrstakepool. Fee payments occur as a
completely independent on-chain transaction. This enables both the ticket
purchase and the fee payment to be mixed in the same anonymity set as solo
tickets.

Ticket holders are not required to register an account with vspd. This means no
email address needs to be handed over, there is no password to remember, and no
[CAPTCHAs](https://en.wikipedia.org/wiki/CAPTCHA) need to be solved.

vspd also offers the following improvements to users:

- No [redeem scripts](https://docs.decred.org/proof-of-stake/redeem-script/) to
  back up.
- A single wallet could use a different VSP for each of its tickets.
- Voting preferences can be set on a per-ticket basis.
- No [address reuse](https://docs.decred.org/privacy/general-privacy/#trade-offs-of-reusing-vs-not-reusing-addresses).
- The possibility of using multiple VSPs for a single ticket.

VSP operators have also been considered in the design of vspd. dcrstakepool had
the unfortunate property of collecting fee payments with a single reused address
per user. vspd requires clients to request a new fee address and fee amount for
each ticket, which not only removes the address reuse, but also enables
administrators to easily update their fee amount as they please.

The required sysadmin work and overheads have also been reduced with the
following changes:

- An instance of [etcd-io/bbolt](https://github.com/etcd-io/bbolt) on the
  front-end server is used as the single source of truth:
  - bbolt does not have the sysadmin overhead associated with maintaining a full
      database server such as MySQL. vspd automatically creates and maintains
      its own database.
  - The database is only accessed by the vspd process. There is no need to
    expose the system to additional risk by opening ports for other processes to
    access the database.
- Voting wallet servers only require dcrwallet and dcrd to be running. There is
  no longer an additional VSP process, i.e. stakepoold, running on voting
  servers.
- No email addresses or personal information are held by vspd - no need to worry
  about GDPR or other data protection regulations.
- Voting servers no longer need dcrd to be running with a transaction index.
- No need to use the same wallet seed on each voting wallet.

## Next Steps

As a core piece of the Decred infrastructure, fundamental to the smooth
operating of the network, vspd is of utmost importance and its development
cannot be rushed.

Thus far, vspd has only been tested with a custom-built client tool, not
suitable for everyday use. We will not recommend running vspd on mainnet until
the new server software has been thoroughly tested and the client code is
properly integrated into [dcrwallet](https://github.com/decred/dcrwallet). Once
vspd tickets can be purchased with dcrwallet, integration into the GUI wallet
[decrediton](https://github.com/decred/decrediton) should follow shortly after.

A transition period of around 12 months is to be expected, where VSPs are able
to run either vspd, dcrstakepool, or both. This should avoid interrupting the
user experience too sharply, and protect the steady stream of ticket purchasing
and voting which is essential to the Decred network. Existing VSP operators may
choose to deploy vspd alongside their existing dcrstakepool deployment. Newer
operators may choose to only run vspd. It is envisioned that eventually, the
majority of VSP tickets will be purchased on vspd, dcrstakepool deployments can
be decommissioned, and support for dcrstakepool can be removed from wallets.

## In Conclusion

The release of vspd represents another incremental step forward in Decred's
project mission to produce open-source technology for public benefit. Enabling
VSP tickets to be purchased with funds mixed through CSPP increases the size of
the overall anonymity set, which in turn provides a greater level of privacy for
all Decred users.

To find out more about how vspd is built and how it works, the source code and
some documentation is [available on GitHub](https://github.com/decred/vspd).

The Decred project is always looking for talented developers, so if vspd or any
other aspect of Decred development interests you, please pop into [our
chat](https://decred.org/community/) and introduce yourself.
