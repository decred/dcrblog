---
title: "Introducing DownloadHawk"
date: 2019-12-12
authors:
- degeri
tags: [Decred,security,binary verification]
banner_image: "/images/posts/download_hawk_1.png"
---

We recently observed the Monero hack in which an attacker compromised [getmonero[.]org](https://www.zdnet.com/article/official-monero-website-compromised-with-malware-that-steals-funds/) and replaced one of the binaries with a malicious coinstealer. 

The Monero team has good reliability when it comes to security and all indicators seem to show that the attack was sophisticated. Point being no matter what your security posture, this could happen to anyone.


<!--more-->

## How should everyone protect themselves? 

In a perfect world, every user would be checking the hash for each download. They would also be making sure that the hashes are signed by a reputable source. And this all should be done Out-of-band. But sadly, we do not live in a perfect world and a small fraction of downloads are checked properly by users. 

On the project front, Decred is working towards reproducible builds for all binaries. This will allow community members to verify that the files being given for download match with the actual source code.

## What is DownloadHawk?

I wanted to build a simple tool that would alert users if any of the binaries or the links in the download page changed. 

[DownloadHawk](https://github.com/degeri/DownloadHawk) makes use of [Selenium](https://selenium.dev/) to visit the website like an actual user. Then it proceeds to do a series of checks on the rendered HTML. 

### It can handle two types of links. 


#### 1. External Link (Play Store, iTunes, 3rd party wallets)

- Checks if the link is present
- Checks if the URL matches with the defined link

#### 2. File download 

- Checks if the link is present
- Checks if the URL matches the defined link
- Downloads and compares the hash with a known good hash


All of this can be configured from a single [edit](https://github.com/degeri/DownloadHawk#how-to-edit-the-configini-file) of a [config.ini](https://github.com/degeri/DownloadHawk/blob/master/config.ini) file. 

If any anomaly is found it gives an alert. This currently sends a message on [Matrix](https://matrix.org/) but can easily be [edited](https://github.com/degeri/DownloadHawk/blob/master/functions.py#L126) to send alerts to a platform of your choice.


## Does this mean its 100% secure? Why release it? 

No! This might be bypassed by someone with enough resources or skills. Proper security is layered. While keeping this private might be beneficial for Decred, we felt it was in the greater interest of the cryptocurrency community to make this publicly available. It also allows for new ideas and [improvements](https://github.com/degeri/DownloadHawk/issues).


## Conclusion

The [README](https://github.com/degeri/DownloadHawk/blob/master/README.md) should contain all the information to get started. It should be very simple to edit and set up for your site. Please note depending on the size of the download files and the frequency of checks it might consume a lot of bandwidth. You can always reach out to me on twitter or matrix if you face any issues or want to help with improvements.

Repo Link:
https://github.com/degeri/DownloadHawk/
