---
title:			"Clearing the Route"
date:			2016-10-05
authors:
-  jy-p
tags:			[dcrd,database]
banner_image: "/images/posts/gotthard.jpg"
---

The most difficult groundwork required to clear the route to distributed decision making via Proof-of-Stake (“PoS”) in Decred is nearing completion.  While many users and interested outsiders are understandably keen to see a steady stream of new features, we decided to instead focus on making important structural upgrades before beginning work on the more substantive features that make use of Decred's hybrid PoW/PoS consensus system.  The major hurdle of upgrading Decred's chain database format and related code is almost behind us, and it is accompanied by a substantial performance increase when both doing the initial chain sync (roughly 5x faster, depending on hardware) and handling many concurrent RPCs to the chain daemon.  With the database hurdle cleared, the process of steady incremental decentralization can continue without further significant detours.

<!--more-->

As mentioned in the previous blog post, syncing the database upgrade from btcd entailed taking an enormous +22,685 / -9,155 line change set and adapting it to work with dcrd.  This work was completed in 2 phases: first, the database format was adapted to replace the existing data stored by dcrd, and second, the existing independent ticket database was integrated into the new database to create a single database containing both transaction and ticket data.  The first phase was relatively straightforward and led to a roughly 2x speed increase when syncing the chain from scratch.  The second phase was more involved and required creating new infrastructure to handle the tickets in an efficient way and store them atomically in the database.  While many other projects may have opted to delay these database changes in lieu of adding more user-visible features, doing so would have only delayed this work and made it more challenging to pull off once more features depended on the old database code.

The result of this work is a single unified database that contains both transactions and tickets, and is much easier to manage from a consistency standpoint.  Long delays that were previously present when starting and stopping dcrd, due to the old ticket database format, have been substantially reduced.  Now that the tickets are stored in LevelDB, it is much rarer to experience any consistency issues due to a “dirty” shutdown of dcrd.  This unification of databases has been accomplished by making use of buckets, which effectively partitions the database into multiple smaller databases, with the stake transactions being stored in a separate bucket than normal transactions.  By taking what was previously 2 separate databases for transactions and tickets and combining them into a single database, the challenges associated with attempting to maintain atomicity across 2 databases have been eliminated.

Speed improvements for the initial chain sync with the new database are substantial and vary based on hardware.  We have seen speedups of roughly 5x for the initial chain sync on a modern laptop or desktop machine with SSD.  The drastic increase in performance is due to several factors:

* storing blocks as flat files on disk vs storing them directly in the database
* using an immutable treap for handling transaction and ticket data
* ability to efficiently retrieve arbitrary regions of blocks (transactions, scripts, etc).
* optimization for read performance with consistent write performance

With the database performance optimized, users benefit from a substantially reduced sync time for the chain.  Less waiting around for the chain to sync makes for happy users.

### What now?

Once the database upgrades land in master early next week, this means that users who upgrade to the coming 0.5.0 release from 0.4.0 or earlier will need to sync their chain from scratch.  As the syncing process is substantially faster now, it should only take 30 minutes to 2 hours to sync the entire chain, depending on the uplink and hardware.  After the sync is complete, all Decred software should function per the usual.  Since this is a major upgrade, users should upgrade to 0.5.0 sooner rather than later.

With upgrading the database out of the way, Decred can begin the process of enabling the more powerful aspects of its PoS system.  Currently, stakeholders can only exercise a single votebit when casting votes, i.e. only a vote of 0 (“nay”) or 1 (“yea”) can be cast and it applies to the validity of the previous block's PoW reward.  There are obviously many other matters of potential interest to Decred users beyond the validity of the prior block's PoW reward, so we will add the ability for stakeholders to set additional votebits to vote on other issues.  A key application of this voting will be voting on consensus changes, wherein stakeholders are given the ability to vote on consensus changes, effectively subjecting the act of voluntary hard forking to a vote.  Further details on the process of enabling additional votebits will be made available in a future blog entry.

If you'd like to leave a comment, please do so on [the forum thread for this entry](https://forum.decred.org/threads/clearing-the-route.4038/).
