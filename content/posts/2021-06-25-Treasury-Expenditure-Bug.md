---
title:			"Treasury Expenditure Policy Bug"
date:			2021-06-25
authors:
-  matheusd
tags:			[Decred, Decentralized Treasury, consensus]
banner_image:		"/images/posts/fiat-is-rigged.png"
---

Payments from the new decentralized treasury infrastructure are currently blocked and will be delayed until a new consensus vote takes place to implement a change to the consensus rules.  Contractor payouts will continue via the legacy treasury until the changes are deployed and activated.

_No funds from either the decentralized treasury or from the legacy treasury are at risk of being lost._

The only practical consequences of this issue are some inconvenience for operators of the Contractors Management System (CMS), the need for a new consensus vote to happen, and some delay for the new treasury to effectively start working.  _All funds in the network (including, but not limited to the treasury) are safe_.

The issue resides in an overzealous check for the maximum expenditure policy. This policy defines the maximum value that a set of treasury spend transactions that are to be included in a block may draw from the treasury.

Due to the test treasury spend transaction mined in mainnet on [block 556716](https://explorer.dcrdata.org/tx/7507bcc72bfde895065034e12e6d462f2360163cd0c879f0db35514f9456b2c1), the maximum amount that can now be spent from the decentralized treasury account for the next few months is approximately 0.15 DCR, which is too low to be able to fulfill all monthly invoices in the CMS system.

While no development team enjoys finding issues in shipped software and doubly so in distributed consensus code, we need to highlight that Decred's governance model and the way the decentralized treasury functions were introduced worked as designed to prevent a bigger problem.

  - The migration plan from the legacy treasury to the decentralized treasury was created to handle any cases such as this
  - The payments to contractors will still continue as usual, coming from the legacy treasury wallet.
  - There are no risks of the network forking, given the corresponding on-chain vote already activated the new rules and all older versions of the software are not following the main chain anymore.
  - The decentralized treasury account is still accruing its 10% block reward.
  - Finally, all the funds in the legacy treasury wallet are still intact and available for spending and eventually being moved to the new account system.


The rest of this document will provide more technical details about the issue, how it was introduced, how it will be fixed and its impact to the network.

# In Depth Analysis

For the rest of this document we assume the reader has some basic knowledge about how the new decentralized treasury feature works and how changes to the consensus rules of Decred are proposed, coded, deployed and activated.

## The History of the Expenditure Policy in the Code

The initial Politeia proposal for the [decentralized treasury](https://proposals-archive.decred.org/proposals/c96290a) included a provision to limit the total amount of funds that could be withdrawn from the treasury during a period of time. To quote from the proposal:

> `OP_TSPEND` shall [...] prevent spending more than this months treasury accrued value + 50%

This was further refined in some comments and will be generally referred to as the "maximum expenditure policy check".

The motivation for adding this restriction is to avoid overspending the treasury - that is, to avoid withdrawing too much DCR from the treasury account in a short period of time.

This has two main applications:

  - A security and safety mechanism, so that in case of implementation bugs or compromise of treasury keys the treasury account wouldn't be depleted too quickly, before the issue could be addressed.
  - A generic "fiscal" policy over the treasury's funds, so that it would not be amenable to being overly spent by short term interests.

This restriction would be enforced via consensus rules in the software, and thus be unchangeable without some other voting process taking place and stakeholders weighing in on the matter.

It's important to note here that no proposal is fully detailed to the level required by actual software code and even this seemingly simple restriction has ambiguity: Decred's blockchain has no concept of "month" and standard calendar months are not easily transposable to a window of blockchain blocks of fixed size. Nevertheless, developers and stakeholders assumed this restriction could be implemented after being properly specified in terms of blockchain primitives.

However, during development of the treasury feature, at this point in time at around October/2020, two objections were raised against this specific form of expenditure policy:

  - The treasury was already spending more than it was receiving via the block reward, due to the USD/DCR exchange rate. Any further decrease would already make it impossible to pay for all monthly contractor invoices.
  - This policy is not stable over a long time frame, since the block reward is being constantly reduced. Following it strictly would mean the treasury would be unable to spend most of its funds, even if it had accumulated a large pool, since the per-month income would be small.

Therefore, a change in the expenditure policy was proposed and discussed among the developers. The general wording for this policy is noted in the [source code](https://github.com/decred/dcrd/blob/afff2fdbcd4c57ade4f0d13e78ad2d3efaebcdec/blockchain/treasury.go#L651-L655):

> The sum of tspends inside an expenditure window cannot exceed the average of the tspends in the previous N windows in addition to an X% increase.

A `window` here is a specific number of blocks, as defined by some constants in the [chaincfg](https://github.com/decred/dcrd/blob/afff2fdbcd4c57ade4f0d13e78ad2d3efaebcdec/chaincfg/mainnetparams.go#L395-L411) package. For mainnet, this cashes out as roughly:

> The sum of tspends within a 6912 window (aprox. 24 days) cannot exceed the average of the preceding 41472 blocks (aprox. 144 days or 4.8 30-day months) in addition to a 50% increase.

This wording intended to preserve the original safety and policy characteristics as defined in the Politeia proposal, by capping rate at which the expenditures could grow, but still allowing enough flexibility that it could handle cases where the exchange rate dropped significantly or that the treasury had enough accumulated funds that stakeholders felt comfortable spending a larger fraction of it.

We should reiterate that this is _not_ the only mechanism by which treasury expenditure is limited: in addition to the maximum expenditure check, treasury spend transactions are still subject to being signed by the Politeia keys and go through the on-chain voting process before being included in a block by a proof-of-work miner.

Thus, it was considered that even though this was a change to what was explicitly discussed in the proposal, it was a reasonable enough change and that the other mechanisms would still be in effect to prevent any excessive withdrawal from the treasury account - the expenditure policy was considered an _additional_ protection to the more overriding one, which is the on-chain voting performed by stakeholders.

## The Bootstrap Expenditure Amount

Basing the maximum expenditure policy check on the average past _expenditure_ as opposed to the absolute past _income_ introduces an additional challenge: what to do at the start of the new treasury accounting system, when there are no past expenditures. Or, more generally, what the maximum allowed expenditure should be when there are no spends within the past window of blocks used as reference.

Thus a new chain parameter was introduced: the expenditure bootstrap amount, which specifies how much DCR can be withdrawn from the treasury when the immediate history has no treasury spend transactions.

For mainnet, this value was chosen to be 16k DCR, which was a value close to the top of the amount spent in the preceding months, maintaining the ability of the decentralized treasury to keep paying the existing contractors.

It was the implementation of this specific feature that caused the policy check to fail when a test treasury spend transaction is present in the immediate history.

## Triggering the Issue

The code related to the bootstrap amount can be summarized as follows (this is an edited section of the [`maxTreasuryExpenditure()`](https://github.com/decred/dcrd/blob/afff2fdbcd4c57ade4f0d13e78ad2d3efaebcdec/blockchain/treasury.go#L650) function, redacted for clarity):

```go
	policyWindow := b.chainParams.TreasuryVoteInterval *
		b.chainParams.TreasuryVoteIntervalMultiplier *
		b.chainParams.TreasuryExpenditureWindow

	// ...

	// Next, sum up all tspends inside the N prior policy windows. If a
	// given policy window does not have _any_ tspends, it isn't counted
	// towards the average.	
	for i := uint64(0); i < b.chainParams.TreasuryExpenditurePolicy && node != nil; i++ {
		var spent int64
		spent, _, node, err = b.sumPastTreasuryExpenditure(node, policyWindow)
		// ...

		if spent > 0 {
			spentPriorWindows += spent
			nbNonEmptyWindows++
		}
	}

	// Calculate the average spent in each window. If there were _zero_
	// prior windows with tspends, fall back to using the bootstrap
	// average.
	var avgSpentPriorWindows int64
	if nbNonEmptyWindows > 0 {
		avgSpentPriorWindows = spentPriorWindows / nbNonEmptyWindows
	} else {
		avgSpentPriorWindows = int64(b.chainParams.TreasuryExpenditureBootstrap)
	}

	//...
```

Note the last `if` statement: if there is at least one preceding window in which a treasury spend tx ("tspend") was mined, then the average used to derive the limit is calculated as the total spent across all tspends over the number of non-empty windows. Otherwise, the bootstrap amount is used.

In other words, a single tspend transaction in the recent blockchain history already switches the expenditure check from using the bootstrap amount to using the historical amount.

Therefore, when the test tspend transaction was published and mined in mainnet, spending a total of 0.1 DCR from the new treasury account, the expenditure check code was "locked" into only allowing a 50% increase from this amount.

While unit tests were written to assert the correct behavior of the expenditure check in the upper limit of operation (that is, when a set of transactions is trying to spend more than allowed) no tests are verifying the behavior in the _lower_ limit operation. Manual testing was also not performed for this particular case.

## Recovering from the Bug

The resulting effects from locking the decentralized treasury on such a low level of possible spending are the following:

  - The payment for contractors for the next few months will have to keep coming from the legacy treasury wallet. This doesn't have any practical implications to contractors.
  - The CMS operators will have slightly more work to do, given they'll have to create the usual payment transactions.
  - Operation of the treasury in a decentralized fashion will be delayed for a few more months.
  
While those are unfortunate effects, they are not critical. In particular, as presented in the previous section, this issue _cannot_ be used to withdraw additional funds from the treasury.

It's also important to highlight that all the other checks on treasury spends are intact. And that the decision to perform a staggered move of the funds and not completely empty out the legacy treasury wallet is also providing us with plenty of room to manuever around this issue.

Finally, we're now faced with a decision regarding how to recover from here on. There are two primary options:

  1. Wait about 4 months (up to block 598188) until the test tspend leaves the recent policy window and the treasury can spend from the account regularly, then resume payments as is.
  2. Perform some on-chain vote to fix this issue.
  
Being _very_ optimistic, any on-chain vote would take at least 3 months to write, deploy and activate. And we already have a possible upcoming consensus change that is currently being voted in Politeia ([Explicit Version Upgrades Consensus Change](https://proposals.decred.org/record/3a98861)) that we want to include in the next upgrade if possible.

Given those prospects, the fact that the exchange rate is no longer an immediate factor in deciding the expenditure level for the treasury (when compared to the amount received from the block reward) and the fact that the currently implemented expenditure check was an explicit change from the one discussed in the proposal, we have decided to write a change to the currently implemented max expenditure check to bring it in line with what was in the original proposal, and to put it to an on-chain vote.

This change will take a form of a [DCP](https://github.com/decred/dcps), along with appropriate code to implement it, to be released in a few days. Voting for this consensus rule change will happen once a new software version is released that implements this agenda (most likely also with the version upgrade change).

## Future Improvements

While the proposed change for this issue is the initially proposed minimal context constraint that stakeholders have already voted on via a Politeia proposal and solves the immediate situation, it is worth pointing out that it doesn't address the long term concern about using the expenditure policy in regimes where the USD/DCR exchange rate is much lower than the current one, or when the income generated by the block reward is significantly smaller then the withdrawal rate needed by the treasury.

As demonstrated, imposing algorithmic spending constraints that are flexible enough to handle ongoing operations as well as sporadic high variance payments while simultaneously avoiding malicious actors is a delicate balance to get right and any proposed solution might have subtle failure modes that will need to be addressed.

Future work will need to refine spending constraints using information about spending patterns that emerge through continued use of the decentralized treasury.

# Acknowledgements

Thank you to the following people that contributed to this post (alphabetical order):

- Dave Collins (@davecgh)
- Jake Yocom-Piatt (@jy-p)
- Jonathan Chappelow (@chappjc)
- Marco Peereboom (@marcopeereboom)
