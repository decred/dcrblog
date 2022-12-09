---
title:                 "Trapped in the Web"
date:                  2022-12-09
authors:
- jy-p
tags:                  [Decred]
banner_image:          "/images/posts/2022-12-09-trapped-in-web.jpg"
---

The web is the world’s largest software platform and is, correspondingly, a central pillar of modern society.  Large public corporations have built their fortunes by creating web-based businesses, investors in those corporations have reaped huge profits, and the web has become a ubiquitous concept in day-to-day life.  However, over the past 33 years since the web was invented in 1989 by Tim Berners-Lee, its initial role as a means to educate and liberate has evolved into a means to oppress, manipulate and indoctrinate.  This darker side of the web emerging is due to increasingly aggressive efforts of governments and large corporations working in tandem to control public opinion.  While many are keen to attribute these dark patterns gaining prominence on the web to a particular political party, class, government, or other out-group, the true problem is the software that powers the web and how it is architected.  The defects of the web are best revealed by answering several key questions:

- What is the web?
- How are people being oppressed via the web?
- What is wrong with the web from a technological standpoint?

## What is the web?

[The definition of “The Web” from Wikipedia](https://en.wikipedia.org/wiki/World_Wide_Web) refers specifically to the Hypertext Transport Protocol (“HTTP”), the related stack (HTML, DOM, CSS, Javascript, etc), servers, clients/browsers, and documents transferred over this network of servers and clients using HTTP.  As someone with a couple decades of experience as a system administrator, I believe this definition is too narrow since to meaningfully use the web several other supporting protocols and their stacks are required.  A more complete definition of the web is

A collection of certain protocols, their corresponding stacks, protocol servers, and protocol clients run by individuals, corporations and governments that relay data.  The protocols are

- Domain Name Service (DNS) – DNS creates a mapping from human-readable names to IP addresses, facilitating connection to protocol servers via dns clients embedded in other protocol clients.
- Hypertext Transfer Protocol (HTTP) – HTTP allows documents and other data to flow between web browsers and web servers and is synchronous.
- Simple Mail Transfer Protocol (SMTP) – SMTP allows for asynchronous messages to be sent between users at domains, where messages are cached on mail servers and fetched by mail clients.
- Transport Layer Security (TLS) – TLS is a link encryption layer that prevents routers between a protocol client and a protocol server from seeing the data being transferred.
- Bank Credit Cards – Bank credit cards and similar “instant” payment systems are the primary means by which payments occur on the web, where the precise protocol used in the software depends on the payment processor used.

For many readers, they will only see the client side of what is described here: web browser, email account/client, and a credit card from the bank.

Using the narrow definition of the web makes it much harder to understand the practical and technical problems with the web as a communications platform.  The problems inherent in HTTP extend into and interlock with problems in the other protocols, so discussing issues with HTTP is insufficient to expose the broader problems in the ecosystem.

## How are people being oppressed via the web?

The web started as a well-intentioned meritocratic tool for communication via publishing simple documents.  As investors and corporations began making more active use of the web to build businesses the question of monetization naturally arose, and it became clear that the custodial nature of the web could be actively exploited for advertising and surveillance revenue.  Nodes in this network, called websites, would take custody of user data to facilitate its transfer to other endpoints or users as part of some service rendered.  To this day, there are only very limited laws governing the use of such data on the web, despite there being numerous examples of this data being used maliciously in a variety of ways by a variety of counterparties.

Much of modern society in developed states depends strongly on a handful of custodial web-based businesses owned by public corporations.  Governments have observed this centralization and taken advantage of it by embedding themselves into these public corporations.  Unlike common carrier networks, e.g. public swtiched telephone network, web-based businesses can covertly censor content and collect a wide variety of metadata that can be used for surveillance.  If someone is being censored on a phone call, that censorship is much more overt and harder to deny, creating potential legal ramifications for any government implementing it.  On the other hand, if someone is shadowbanned on social media, that is much harder to prove and has correspondingly weaker legal implications.  Web-based businesses can claim an account is censored due to a publicly-stated terms and conditions when the real reason is a government is acting at arm’s length to censor them via the business.

A small number of large public corporations control most of the web-based communications tools, and if a user sends messages on these platforms that run afoul of either the corporations or the governments they collaborate with, that user will find themselves censored by the corporation.  This problem is present on practically every major platform, where censorship is driven by a user’s actions related to a number of approved narratives on certain topics, e.g. COVID-19, vote fraud, immigration, bad versus good states, and asserting government-enumerated rights.  Users that adhere to the approved narratives never see the censorship and claim it does not exist, whereas users that stray from the approved narratives are shadowbanned, driven off the platform, and gaslit by appproved-narrative adherents.  Even under the best circumstances, users are forced to depend on the hypothetical goodwill of the platform operators that they will not censor and surveil the users.

## What is wrong with the web from a technological standpoint?

A common human reaction to a problem is to find a particular person to blame for that problem, but the problems with the web are fundamentally technological in nature, not personal or political.  All of these web protocols and stacks I listed above were created in the 70s, 80s or 90s, and are correspondingly brittle and poorly-suited to modern day use cases.  People will argue all day about who should be in charge of communications platforms and completely neglect to discuss the technological underpinnings of those platforms, as if the problems experienced can be fixed if only the right person were in charge.  It is best to take the high road and instead focus on the ecosystem-wide problems web protocols and stacks create.

### Centralized custodial networks

All the web protocols under discussion are custodial to varying degrees, meaning a trusted third party takes custody of user data.  The trusted third parties in the case of these protocols are the servers and their operators, which are predominantly large public corporations.  The surveillance and censorship that occur on the web result from this custody of both user data and metadata.  Having custody of user data is what allows web-based businesses to extract revenue from services that do not charge users.

Beyond protocol servers and operators having custody of user data, the protocol servers are highly centralized.  For example, [Apple and Google respectively operate servers that control 57% and 29% of the email client (SMTP) market share](https://techjury.net/blog/gmail-statistics/).  Other protocol server networks are similarly centralized to lesser degrees.  While it is possible for more technical users to run their own protocol servers, this is a relatively rare practice.  The combination of these protocol networks being strongly centralized and custodial facilitates straightforward government access to user data.  In addition to government access, corporations that seek to surveil users can often access similar data via different paths.

### Weak security models

Web protocols are architected such that governments can surreptitiously surveil and manipulate users with limited cooperation from the data-rich protocol operators.  The data-rich protocols are HTTP, SMTP, and banking transactions since the data being transferred communicates a lot about a user.  Compromising the data-rich protocols is accomplished via the custodial and centralized nature of the DNS and TLS protocols.  When a domain is registered with a domain registrar, they create and maintain special DNS glue records that route DNS queries for your domain.  If these records are changed, say at government request, the government can intercept and reroute DNS requests for your domain and masquerade as a user’s protocol servers.  TLS has a similar vulnerability, where security depends on a certificate authority signing a certificate for a domain.  If a government requested an existing certificate authority sign a forged certificate for any protocol protected by TLS, that government could man-in-the-middle the encrypted protocol messages being exchanged.  By exploiting the routing and encryption web protocols, surreptitious access can be gained to the other data-rich web protocol traffic.

### High protocol stack complexity

As a result of having [a very broad experience managing open source software projects](https://en.wikipedia.org/wiki/Xombrero), I have witnessed web stack complexity and the resulting oligopoly in web protocol stack software toolkits up close.  All of these protocol stacks each possess a non-trivial amount of complexity, but HTTP and SMTP are by far the most complex of the group.  The HTTP stack in particular requires a monolithic toolkit to properly render web pages in a web browser, and there are only a few options that will properly render all web pages, each maintained by a corresponding major US tech corporation: WebKit (Apple), Blink (Google), and Gecko (Mozilla).  Due to the exceedingly high complexity of the HTTP stack, building and maintaining HTTP toolkits requires a lot of developer time, leading to an effective oligopoly in the HTTP toolkit space.  Instead of reducing HTTP stack complexity over time to improve the situation, HTTP stack complexity continues to balloon and entrench this oligopoly.  This can also be seen with the web browsers that use the corresponding toolkits: Safari, Chrome, and Firefox.

Protocol server implementations suffer from a similar oligopoly that is also driven by the protocol stack complexity.  Each protocol has only a few dominant server implementations, and it is rare to see new projects for protocol servers because of the high stack complexity.  Even amongst the better protocol server projects, e.g. Postfix (SMTP) or Nginx (HTTP), the process of configuring the server requires a non-trivial amount of domain knowledge and attention to detail, where it is easy to make mistakes that can lead to security problems.

### Complex payment integration

Payment integration on the web was clearly an afterthought, where web-based businesses eventually figured out they needed the ability to process payments for goods and services.  Since bank credit cards already existed and provided an effectively-instant process for users to make purchases in person, integrating bank credit cards as the primary means of payment for the web made sense.  Despite the relative ease-of-use for credit cards on the consumer side, dealing with payment processing on the business side has always been painful at best.  Getting payment processing, i.e. a merchant account, working is much harder than getting a normal bank account because it involves underwriting by credit card companies and corresponding multi-day settlement processes.  All of the parties involved in receiving fiat payments via the web – banks, payment processors, and credit card companies - can surveil and censor both users and businsesses.  Maintaining credit card payment processing infrastrucure is a permissioned, complex, and generally irritating process for businesses, and on top of this, malicious users can cause trouble by revoking payments after-the-fact via the chargeback process.

##  Conclusion

After 20 years of being a system administrator and 10 years of managing projects in the cryptocurrency space, I am personally quite fed up with the web as it currently exists.  The web facilitates surveillance and censorship, incentivizes the formation of corporate oligopolies in its infrastructure, and is unnecessarily complex.  As mentioned in the prior article, these problems with the web are both directly and indirectly linked to Decred, which has struggled to gain wider adoption.  Decred has been actively censored a variety of ways via the web, and the broader censorship and surveillance on the web are in direct opposition to Decred’s principles of sovereignty, privacy, and freedom.

Decred is evolving to deliver real digital free speech and free association.  The revolution will not be censored or surveilled.  Stay tuned for our release announcement and article next week.

