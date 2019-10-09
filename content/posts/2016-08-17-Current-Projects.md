---
title:			"Current Projects"
date:			2016-08-17
authors:
-  jy-p
tags:			[gominer, paymetheus, dcrd, dcrwallet]
banner_image: "/images/posts/canal_du_nord.jpg"
---

Welcome to the Decred Blog!

This is a status update on our projects currently in progress.  We are working on several projects within Decred and want to keep users and other interested parties informed of what is going on.  Recently, we've been pretty quiet on the communication front and have been focusing on getting development work done.

Currently, the major projects underway are

* [Paymetheus](https://github.com/decred/Paymetheus/), a native Windows GUI for dcrwallet
* [gominer](https://github.com/decred/gominer/), a cross-platform PoW mining client
* [Web Wallet](https://github.com/decred/copay/), a fork of BitPay's Copay stack
* Synchronizing the btcd database rewrite to dcrd
* Adding support for more gRPC API calls to dcrwallet

A short section describing the status and progress on each of these current projects can be found below.

<!--more-->

### Paymetheus, a native Windows GUI for dcrwallet

The Paymetheus project was started in June 2015 by Josh Rickmar and is now 29,154 lines of C# code that makes use of native Windows GUI bindings.  While the porting to Decred proved to be relatively straightforward, a large amount of work went into improving the UI and UX after it was ported.  As part of [RFP-0001](https://github.com/decred/RFPs/blob/master/rfp-0001/rfp-0001.md), Mauricio Ferreira did the initial Windows Presentation Foundation (“WPF”) implemenation of a wallet UI design created by Tanel Lind.

Recent and ongoing work has focused on refining and improving the WPF implementation from Mauricio, adding support for purchasing stake tickets, and improving the UX for installing and using Paymetheus.  Stake ticket purchasing was added in [v0.3.0](https://forum.decred.org/threads/dd-15-v0-3-0-08-15-16.3960/), which was released on Monday, August 15th.  Currently, the user must manually start the dcrd process before Paymetheus, and in v0.4.0 both dcrd and dcrwallet will be started and stopped by Paymetheus as necessary.

### gominer, a cross-platform PoW mining client

The gominer project was started by Dario Nieuwenhuis on February 8th, 2016.  Initially, it supported solo mining without TLS and worked best on AMD GPUs.  Since then, we have added TLS support, stratum support for pool mining, intensity support, autotuning for GPU intensities, logging for rejected pool shares and selection options for GPUs.  This further work was completed by John Vernaleo and Jolan Luff.

The mining speed on AMD GPUs has been substantially improved by importing a new OpenCL kernel from sgminer, so gominer should run very close to the speed of sgminer.  If you mine using AMD GPUs, we would welcome a comparison of gominer to your usual mining software.  Gominer v0.4.0 will include support for NVIDIA GPUs and use the latest Cuda kernel from ccminer.

### Web Wallet, a fork of BitPay's Copay stack

As part of our launch of Decred, Alex Yocom-Piatt made a fork of BitPay's Copay stack on September 22nd, 2015 that became the Decred Web Wallet.  Copay made for a nice web wallet for launch, but as a function of our focusing on making it work with Decred, it has not been updated since the original forking.  The Web Wallet has been synced through June 23rd, 2016, from the Copay repositories.  The new Web Wallet has been thoroughly tested interally and should have a seamless upgrade path from the older version, it should only take a few clicks to upgrade your wallet once the changes are live.

A major benefit of updating to a more recent Copay stack is that it allows for standalone GUIs to be built using Electron.  This means we may have a cross platform wallet solution in the near future.  Once the local GUI version of Copay is building and tested on each platform, we will make that available in future releases (v0.4.0 and above).

### Synchronizing the btcd database rewrite to dcrd

Dave Collins did a complete rewrite of the database layer in btcd throughout 2015 and committed it in August 2015, which is relevant to Decred because the database layer of dcrd is inherited from btcd.  The new database is a substantial improvement over the previous version performance-wise, both for intial block download and RPCs, and improves how blockchain consensus rules are organized.  As such, this is obviously something Decred wants from a performance and code improvement perspective, but it is also a prerequisite for syncing new code from btcd.

This database upgrade is an enormous change set, at +22,685 / -9,155 lines of code, and touches consensus rules, so extra care must be taken with this upgrade.  The new database code is working and bugs are being worked out of it.  It is hoped that the new database will land in master in another 2-4 weeks.

### Adding support for more gRPC API calls to dcrwallet

When Josh created Paymetheus, he decided that it needed to use a new type of wallet RPC, so he chose gRPC.  This decision was made because of shortcomings observed in the JSON-RPC that btcwallet, and later dcrwallet, cloned from bitcoind.  In order for Paymetheus to use gRPC, dcrwallet needs to support gRPC.

Dcrwallet has had several new gRPC calls added recently to support ticket purchasing through Paymetheus.  The process of adding new gRPC calls will continue as new functionality is added to Paymetheus in the coming weeks.

In conclusion, we are staying quite busy with Decred and will be making a point to keep everyone better informed regarding ongoing and future work.  The attentive reader will also have noticed the new logo and design elements, which will be covered in a future entry.

If you'd like to leave a comment, please do so on [the forum thread for this entry](https://forum.decred.org/threads/current-projects-new-blog.3969/).
