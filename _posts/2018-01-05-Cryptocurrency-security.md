---
layout:			post
title:			"Cryptocurrency security: Spectre and Meltdown"
date:			2018-01-05

author_image:		/images/marco_300.png
author_location:	"Austin, US"
author_bio:		"Decred New Systems Development"
banner_image:		meltdown.png
tags:			[Decred,cryptocurrency,security,best-practices,spectre,meltdown]
---

Recently Google disclosed a new class of vulnerabilities known as [Spectre and Meltdown](https://meltdownattack.com/).  Folks in the Decred community have
been asking questions about the implications of these bugs for Decred.  This
post delineates implications of these exploits and possible countermeasures.
These bugs are akin to traders issuing cancels without back pressure to
manipulate the market.

### TL;DR

Run your wallet on physical hardware you control and DON'T share with others
and DO NOT run a web browser on the same machine. Hardware wallets do not seem
to be affected by these bugs but great care should be taken where they are
accessed.

<!--more-->

### Spectre

Spectre enables memory leakage in a process.  That translates to, your
web bowser can run hostile javascript code that can leak passwords/keys and
other sensitive information in your web browser over the internet to a third party.

Currently there is no known workaround for this bug and therefore browsers and
internet sites should be considered hostile.

### Meltdown

Meltdown enables kernel memory leakage.  That translates to: if a third party
has access to the hardware, e.g. a shared cloud machine, one can retrieve
keys/passwords and other sensitive information from memory.

Most operating systems have fixes for this bug.  You should update to the
latest operating system version.  Do note that your cloud provider may not have
updated the host operating system. Verify this with your host provider.

Decred voting only wallets are less critical because they do not control any
funds.  Those can be run in the cloud without risking loss of funds.

### Best practices

It is not always possible to not run a web browser on your wallet machine but
you can mitigate most threats.

The main rules are:
1. Update your operating system.
2. Update your web browser.
3. Disable autofill in your browser.
4. Do NOT run a hot wallet on a shared machine or in the cloud.
5. Do NOT run a browser on your wallet machine, if possible.
6. Do NOT use a hardware wallet on a shared machine.

It is obviously not always possible to not run a web browser on your wallet
machine but there are precautions.  For now, only use Firefox and/or Chrome.

1. [Block javascript](https://www.andryou.com/scriptsafe/)
2. [Block ads](https://github.com/gorhill/uBlock)
3. Update your browser.  Firefox has mitigation builtin. Chrome requires [Strict site isolation](https://support.google.com/chrome/answer/7623121?hl=en)
4. [Disable autofill in your browser](https://support.iclasspro.com/hc/en-us/articles/218569268-How-to-Disable-and-Clear-AutoFill-Info-in-your-Browser)
5. Start browser with no tabs or sites open before doing any crypto clicking
6. Quit browser AFTER completing your crypto clicking.
7. Leave browser off unless you need to do anything crypto related (see step 5 and 6).

Those plugins were selected because they exist on Firefox and Chrome.  There
are alternatives that will work just as well.  The Decred project does not
endorse them.
