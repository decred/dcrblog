---
title:                 "Bison Relay: The Sovereign Internet"
date:                  2022-12-14
authors:
- jy-p
tags:                  [Decred, Lightning]
banner_image:          "/images/posts/2022-12-14-bison-relay.jpg"
---

## Introduction

Today I am releasing a new Decred-based communications tool, [Bison Relay](https://bisonrelay.org/), that enables free speech, free association, and can act as a fully independent alternative stack to [the web, whose substantial problems were outlined in my prior article](https://blog.decred.org/2022/12/09/Trapped-in-the-Web/).  Bison Relay is an asynchronous client-server protocol that makes heavy use of the Decred Lightning Network (“LN”), where every message sent is encrypted, metadata-minimized, and paid for via LN micropayment.  The Bison Relay server is accountless and every message is handled individually, where it is both paid for prior to being sent and then received.  Bison Relay tightly integrates payments, messaging, and social media, and this initial release implements a peer-to-peer Twitter/Facebook-like functionality of making posts to subscribers, subscribing to users’ posts, relaying posts, and replying to posts and comments on posts.

In reasoning outlined below, it will become clear why free speech requires this micropayment-based architecture.  While LN comes with its own complexity, Bison Relay can effectively replace 4 of the 5 protocols and stacks mentioned in the prior article - DNS, HTTP, SMTP, and TLS – where the existing Decred LN and on-chain payments replace fiat payment infrastructure.  The rampant and aggressive nature of surveillance and censorship on the web is a sign the web is in dire need of a redesign, and Bison Relay supplies that redesign in the form of a fundamentally peer-to-peer  encrypted content relay network.  For a very small amount of Decred, e.g. 0.1 DCR, users can access free, sovereign, and private speech via Bison Relay for many months.

This initial release includes both a graphical user interface (“GUI”) client for Windows, MacOS, and Linux and a command line interface (“CLI”) client for most platforms.

## Reasoning and Design

Bison Relay has been developed under the threat model of assuming that a powerful adversary controls major components of the infrastructure, which is standard for major Decred features, e.g. Proof-of-Stake governance, StakeShuffle privacy, or DCRDEX atomic swap exchange.  A key observation that has guided the architecting of Bison Relay is that custody of user data and metadata by server operators is used to censor and surveil users, so the broad approach is to aggressively minimize the accessibility and custody of user data and metadata by server operators.

The design process for Bison Relay can be described clearly by the following series of observations:

- Assume the server operator is malicious and seeks to surveil and censor clients.
- Per many other chat protocols, encrypt user messages by default using end-to-end encryption (“E2EE”).  This prevents server operators from reading client messages.
- Remove the server concept of a client account to minimize metadata tracking by server operators.
- Reduce client message metadata to a dead minimum.
- If a server operator cannot link data transfers to particular clients, it prevents traditional banning of malicious clients thereby creating a Denial of Service ("DoS") vector.
- In lieu of attempting to ban malicious clients, instead charge all clients a fee per message sent and received, where the fee is paid via LN.
- Reduce server complexity to a dead minimum, where a server only checks that payments are made prior to receiving sent messages and prior to relaying messages to their recipient.
- Clients connect to each other via out-of-band (“OOB”) invites or via invites mediated by links they have in common, e.g. Alice knows Bob, Bob knows Carol, so Bob introduces Alice to Carol.

Building Bison Relay took roughly 2 years and started in fall of 2020, where I proposed the original concept, Marco Peereboom and I did the initial design work, and Marco did all the early development for a CLI client and server.  Going from a working CLI proof-of-concept to a finished product, which included all the LN payment integration, a cross-platform GUI, and server backend resdesign, was done by Miki Totefu, Dave Collins, David Hill, and Alex Yocom-Piatt.  Bison Relay has been in a private beta test for several months now, and has only had a few bugs fixed and is stable.

## Implementation

The motivation and features of Bison Relay should be relatively clear from the above, so it is time to review how these major features were implemented from an engineering standpoint.

- Bison Relay was built using code from our existing [secure communications tool, zkc](https://github.com/companyzero/zkc/), where work began by removing the client and server notions of a client account.  Correspondingly, Bison Relay has inherited the [various security features from zkc](https://blog.decred.org/2016/12/07/zkc-Secure-Communications/) like Double Ratchet message and header encryption, postquantum-secure Public Key Infrastructure, and a simple CLI client and server.
- To limit DoS attacks against the message send and receive paths on the server, each such action requires a preceding corresponding micropayment from the client to the server.
- A new peer-to-peer process for clients to connect to new peers was added, where ratchet initiation between peers is done either via OOB invite or mediated by 1 or more intermediate peers, rather than using a server.

### No accounts

Removing accounts from zkc was a bit tricky because of how zkc uses a Double Ratchet to encrypt and decrypt all messages.  In zkc, as with most other chat protocols, the server routes messages from user A to user B, and any missed messages can lead to the ratchet state getting out of sync and needing to be reset.  We decided to use the ratchet state as the basis for a unique per-message identifier, so the ratchet state, which is already shared between 2 peers, could be used as the basis for routing in addition to message encryption.  To do this, we took the header encryption key from the Double Ratchet, which is not unique per message, and adjusted it to be unique per message using HMAC.  By taking a unique per-message header encryption key and hashing it, we can derive a unique identifier for each message that both peers using a ratchet can track.  This process was inspired by [Jonathan Logan’s coverage of dropgangs](https://pca.st/7xws4p19), where black market items are sold online using cryptocurrency and dropped in locations that are later disclosed to the buyers for retrieval.

### Embedded LN and paying per message

Once accounts are no longer linked to messages, clients uploading and downloading messages with the server must precede their actions with micropayments over LN.  If this did not occur, malicious clients could run a DoS attack at a very low cost.  Uploaded data is paid for by the byte and received messages are paid for by the message because in the first case disk space is the limited resource and in the second case the database load scales with message count.  Sent messages are stored by the server for 30 days and then purged from its database (PostgreSQL), which may force ratchet resets for users who are offline for over 30 days at a time.

### P2P social networking

Typical social media or chat services have a database table of their users, so user A can request to be connected with user B and the server routes the messages.  Since we have engineered out the server-based routing of messages and instead use client-based routing, clients must connect with each other without the use of a server “phonebook”, i.e. lookup table.  Clients may connect either via OOB invite, which can be sent over other chat or relay networks, preferably via a secure channel, or via Bison Relay directly using mediated key exchanges.  This mediated key exchange process would occur roughly as follows:

- Bob is in contact with Alice and Carol, but Alice and Carol are not in contact over Bison Relay.
- Bob posts something that both Alice and Carol can see.
- Alice makes a comment on the post.
- Carol sees Alice’s comment on the post.
- Carol decides to initiate a mediated key exchange to connect directly with Alice.
- Bob mediates the key exchange requested by Carol with Alice.
- Carol and Alice are connected directly.

A similar process can occur across several intermediate peers that exist in between the 2 peers that are attempting to connect.  Mediated key exchanges avoid the need for an authoritative lookup table by reverting to the “old” meatspace model of meeting people, where you’re introduced to new people via people you already know.

Analogous to reposting on various existing social media platforms, clients can “relay” another client’s post to their own followers.  If several clients relay a single post in a series, the scenario described above with several intermediate peers existing between 2 peers attempting to connect can occur.

## Implications

Bison Relay represents a major architectural shift in how communications platforms operate.  There are both obvious and more subtle consequences of this architecture.

The obvious:

- The audience for credibly-neutral social media infrastructure may find Bison Relay an attractive option.  There is no server operator or central planner who can arbitrarily turn off your account, unlike almost every other social media plaform.  Clients are sovereign over their communications and networks.
- Using Bison Relay requires possessing a small amount of Decred, e.g. 0.1 DCR.  This will generate demand for Decred across a wider audience that previously did not exist.
- Networks built on Bison Relay are surveillance- and censorship-resistant, reducing many issues originating from malicious advertiser, server operator, and government actions.
- An existing Bison Relay client can be used to onboard new clients via invites and sending small amounts of Decred on-chain to fund new clients’ channels.  Users are onboarded by their friends and associates, tying telecommunications to users’ existing social networks.
- Bison Relay will drive growth and decentralization in Decred LN.  Just like the internet started with a few nodes, LN hubs can be added in more locations to spread out the load.

The subtle:

- Unlike most tech corporations, we do not need hundreds of thousands or millions of users on Bison Relay for it to substantially magnify the value proposition for Decred.  Bison Relay is built to grow via word of mouth.  Just the prospect of a Signal-like system without the requirement of phone number metadata and a low cost is a draw.
- Most existing web infrastructure can be replicated on Bison Relay, e.g. pages, ecommerce, and paid subscriptions.  This is a work-in-progress and there should be something to demonstrate in the next several weeks.  Think bricks and mortar stores, Patreon, Substack, Soundcloud, and OnlyFans without the questionable platform fees and restrictions.
- Bison Relay has no authoritative naming system on purpose.  As soon as there is a public directory, it is not possible to attribute spam to a source.  By having no phonebook in Bison Relay, the path of spamming users and spam is always attributable.
- Decred has had difficulty obtaining substantive fiat exchange listings, so Bison Relay creates an informal way around this barrier by facilitating localized purchases of Decred, either via cash or other means.

It is difficult to capture all the various implications of Bison Relay, so feel free to [communicate with us about it via chat](https://chat.decred.org/) or [other communication channels](https://decred.org/community/).

## Conclusion

Bison Relay is a years-long effort of mine to use cryptocurrency to create a platform for free speech and free association.  Back in 2017, I had idly wondered how this was possible, and 5 years later we have a working product with a nice user interface.  The years since fall 2017 have been unpleasant as we soldiered forward through malicious miners manipulating our markets, persistent coordinated trolling campaigns, trade media blacklisting, and acute Twitter censorship.  With the release of Bison Relay, Decred and any other individuals or groups that are being actively censored on other platforms can begin to build their own sovereign internet of content, ideas, and capital.  Decred is money evolved and Bison Relay is internet evolved.

[Come join us on Bison Relay](https://bisonrelay.org/) and build your own sovereign internet.  The revolution will not be custodial, censored, or surveilled.
