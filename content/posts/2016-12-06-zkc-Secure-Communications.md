---
title:			"zkc: Secure Communications"
date:			2016-12-07
authors:
-  jy-p
tags:			[zkc,secure communications,instant messaging]
banner_image: "/images/posts/sneakers_glasses.png"
---

As part of our ongoing effort to “decentralize all the things”, we have developed secure communications software that we are open sourcing today, called zkc.  While zkc is not part of the Decred project proper, it is being released as part of our wider effort to increase individual liberty through technology.  zkc stands for “zero knowledge communications” and is intended to provide the highest level of communications security balanced with minimal complexity in its code, configuration and usage.  The various cryptographic protocols used in zkc draw from other existing secure communications tools, such as [Signal](https://whispersystems.org) and [Pond](https://github.com/agl/pond).  zkc is a blending of what we consider to be the best parts of both of these projects, and with its initial release, it functions as an asynchronous instant messenger with the ability to push files.  It makes use of conventional ECDH TLS, [Double Ratchet Algorithm](https://whispersystems.org/docs/specifications/doubleratchet/) using ed25519, salsa20 and poly1305 primitives, scrypt key derivation function, and SIGMA key exchange.  The server and client components, zkserver and zkclient, are designed such that they can both be setup in a matter of a few minutes, and require minimal effort to maintain.  For this initial release, zkc builds and runs on most platforms supported by golang, and is entirely text-based.  zkc should be considered alpha software as of this initial release.

<!--more-->

### Why did we make zkc?

zkc is an attempt to create a generic framework for secure communications, and instant messaging is a good place to start.  Speaking from the perspective of someone who has been a sysadmin for roughly 13 years, it is rather challenging to setup and maintain secure communications infrastructure.  Tools do exist to make this process easier, but it still requires a fair deal of domain knowledge and skill.  For example, here is a list of communications software I might typically setup: ircd-ratbox (IRC), postfix (SMTP), dovecot (IMAP), asterisk (SIP+RTP), sshfs, isakmpd (ISAKMP), openvpn, duplicity.  The ultimate goal is for zkc to allow for replacement of most or all of these tools and avoid the excessive knob-turning required to configure them properly.  As of this first release, zkc supports asynchronous instant messaging, which replaces IRC and part of what postfix, dovecot, isakmpd and openvpn accomplish, and the ability to push files, which has some overlap with postfix, dovecot, sshfs, isakmpd and openvpn.  In the future, we would like to add several features to move this process further along: pull support for files, synchronous audio/video communications and a backup mode.

### Who created zkc?

zkc was designed by Marco Peereboom and I, Jake Yocom-Piatt, with the initial code written entirely by Marco between February and August 2015, with architectural input from Dave Collins.  We have been running zkc in production internally at Company 0 since roughly August 2015, and it is incredibly stable under most of our use conditions.  In the past few weeks, the code has been given a high-level vetting and review by Pedro Martelletto, one of our contractors, who has made several contributions to the code along the way.

### Why not just use Signal or Pond?

This is a totally fair question and I expect that the average user is likely better off using Signal than zkc.  Signal has a much better UI and UX, easy-to-use apps for mobile and desktop platforms, a dedicated team supporting it, in-house cryptography experts, and substantial financial backing via Twitter.  In contrast, zkc only supports a text-based UI, has binaries for most desktop platforms, some part-time attention being paid to it by a couple developers, no cryptography experts, and some nominal financial support from yours truly.  That said, zkc is aiming to serve a different market than Signal, which I will explain below.

Pond is more similar to zkc than Signal in terms of its text-based UI, limited support, code and financial backing.  Pond is not an instant messaging tool, rather, it is more “email on steroids” and meant for sending and receiving episodic larger messages and attachments that are not time-sensitive.  We found Pond to be complex to setup and challenging to use, especially due to the latency imposed by the way it connects to remote servers over Tor.  However, we did prefer the cryptography used by Pond, both in its choice of primitives for the double ratchet (ed25519, salsa20, poly1305) and its SIGMA key exchange.  The use of NVRAM in the TPM for key storage is a nice touch, but caused problems on machines that didn't have a TPM.  In summary, Pond is a replacement for email, with security and privacy dialed to the maximum your hardware allows, along with all the challenges that entails.

We have chosen to keep it simple with zkc and take what we felt were the best parts of both Signal and Pond.  zkc cuts the middle path between Signal and Pond in terms of UI/UX: it is not as easy to setup for clients as Signal, nor is it as challenging as Pond.  This initial release is made with the following considerations:

+ The UI is text-based and emulates the appearance of irssi, in order to keep UI-related complexity low and avoid large GUI toolkits as a dependency.

+ Sysadmins can optionally restrict the ability to create new accounts with zkserver, requiring either a fully manual process to add new users (see zkimport and zkexport) or allowing for an authentication code to be used.

+ zkc does not fully automate key exchange and instead uses a semi-automated process, to give users more fine-grained control over the keys they accept, both when connecting to the server and other users.  This semi-automated process is the result of zkserver not being considered a trusted piece of infrastructure: to automate key exchange requires trusting zkserver to maintain a directory of users' information.

+ We intentionally did not create mobile apps because mobile devices are insecure by design.  Most mobile devices are effectively optionally-turned-on videocameras with microphones, GPS, gyroscope, and an unauditable data uplink.  This does not mean mobile apps will not happen in the future, but if you're serious about secure comms, you should not be using a mobile device.

+ zkc has groupchat support, where the user that creates a given groupchat has sole authority to invite and kick participants. Instead of using a shared groupchat key or similar, messages are instead encrypted and sent to each groupchat member separately, making use of the existing ratchet with that peer.

+ zkc only supports connecting to a single server and a single identity, per instance.  We plan to add multi-server support in the future, and in the meantime we recommend using separate Vms for each instance of zkclient.

+ zkc makes use of code used in Pond since zkc, like Pond, is also written in golang.  Specifically, the double ratchet and SIGMA key exchange code are from Pond.

+ zkc does not support using a TPM for key storage since it creates many additional requirements in terms of OS and hardware.

+ zkc does not include any integration with Tor, e.g. using a hidden service.  It is straightforward to setup zkserver as a hidden service or use zkclient over Tor.

+ There are a couple notable unresolved bugs that users need to be aware of:

	+ Pasting large multi-line blocks of text has inconsistent behavior across platforms. Some OSes and hardware will lead to multiple lines being concatenated and looking ugly for the receiver.

	+ Sudden hard power cycles or power loss can lead to ratchets with other users becoming corrupted. This requires a reset of corrupted ratchets.

	+ There are a few troublesome corner cases that come up when resetting a corrupted ratchet.  These can be worked around, but have a bad UX associated with them.

With that out of the way, it is worth reiterating that zkc is alpha software, so it may contain some bugs.

### How do you setup and use zkc?

The first step is either [downloading the binaries](https://github.com/companyzero/zkc/releases/) or [building the binaries from source](https://github.com/companyzero/zkc/).  Once the binaries and default configuration files are on-hand, you can follow the instructions below.  Please note that these instructions assume you are using Linux, OSX or a BSD operating system.  The instructions for Windows are slightly different and depend on what software you have installed.

### setup zkserver

Choose a machine or VM where zkserver will run and copy the binaries to it.
```shell
$ scp zk* your-server:/home/your-user/
```
Shell into the your-server host, create the configuration directory for zkserver, copy zkserver.conf to it, and change the listen, allowidentify, createpolicy and maxattachmentsize settings in zkserver.conf.
```shell
$ mkdir .zkserver
$ mv zkserver.conf .zkserver/

edit ~/.zkserver/zkserver.conf and change
listen = 127.0.0.1:12345 --> listen = your-server-ip:12345
allowidentify = no --> allowidentify = yes
createpolicty = no --> createpolicy = token
maxattachmentsize = 104857600 --> maxattachmentsize = 1048576000
```
The default configuration is locked-down and requires editing to allow access.  By default, zkserver listens only locally, does not identify itself to remote hosts, does not allow clients to create new accounts and has a maximum attachment size of 10 MB.  In this example, we have set zkserver to listen on the local IP address for your-server, it will identify itself to remote clients, it will allow clients to create new accounts when they have a token, and the maximum attachment size has been increased to 100 MB.

Start a terminal multiplexer, e.g. screen or tmux, run the binary inside it.
```shell
$ ./zkserver
```
Create a new panel in either screen or tmux and get a token for a new client.
```shell
$ ./zkservertoken
5084 6135 3802 2707
```
### setup zkclient

This portion will need to be run for 2 clients, call them Alice and Bob.  Each client will require a separate authentication token, which can be obtained by running zkservertoken on the zkserver host.  The token and server fingerprints must be distributed to clients via another communications channel such as IRC, email, phone or text.

Create the zkclient configuration directory, copy the configuration file to it, and edit the configuration file, changing 
```shell
$ mkdir ~/.zkclient
$ cp zkclienf.conf ~/.zkclient/

edit ~/.zkclient/zkclient.conf and uncomment
tlsverbose = yes
```
Run zkclient, fill out the information required to connect to the server and accept the server keys, after verifying its fingerprints match those given.
```shell
$ ./zkclient
```
{:center: style="text-align: center;"}
![zkclient setup page](/images/posts/zkclient_server1.png "zkclient setup page")
{: center}
{:center: style="text-align: center;"}
![zkclient server key information](/images/posts/zkclient_server2.png "zkclient server key information")
{: center}

After 2 clients are successfully connected to the server, Alice initiates a key exchange, setting a key exchange password in the process, Alice passes her key exchange information to Bob (pin, passphrase and fingerprint), and Bob completes the key exchange, after verifying their identity fingerprint matches.  This process allows key exchange with several peers at once, via Alice sharing her key exchange information with several peers.
```shell
 /kx (in Alice zkclient)
```
{:center: style="text-align: center;"}
![Alice setting key exchange password](/images/posts/zkclient_kx1.png "Alice setting key exchange password")
{: center}
```shell
 /fetch 123456 (in Bob zkclient)
```
{:center: style="text-align: center;"}
![Bob completing key exchange with Alice](/images/posts/zkclient_kx2.png "Bob completing key exchange with Alice")
{: center}

At this point Alice and Bob can message each other directly in zkclient by issuing '/q alice' on Bob's end and simply typing messages. To change to a particular chat window number, use the command '/w number'. To change to the chat window for a given user or groupchat, use the command '/q name'. 
 
For further information on commands that can be run, issue the /help command inside zkclient.  The groupchat and send commands are very useful, so definitely look at the help for that ('/help gc' and '/help send').

## How can I get involved?

If you find zkc interesting or useful, we'd appreciate both [filing issues for bugs](https://github.com/companyzero/zkc/issues) and pull requests for new code [on GitHub](https://github.com/companyzero/zkc).  We have setup a channel on the freenode IRC server network for anyone interested in discussing zkc, #zkc, which is also accessible via [freenode's webchat](https://webchat.freenode.net/). We're also on twitter, [@_company0](https://twitter.com/_company0).
