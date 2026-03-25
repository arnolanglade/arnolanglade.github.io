---
title: "Build less to deliver better: the real cost of unnecessary features"
date: "2026-04-14"
url: "unnecessary-features-software-complexity"
image_credit: "glencarrie"
description: "Unnecessary features can slow down an entire team. Learn how product complexity grows and why understanding the problem is more important than writing code."
keywords: "unnecessary features,software complexity,functional debt,product complexity,software delivery,software architecture,understanding user needs,why too many features slow down a product,software complexity and unnecessary features,avoiding useless features,understanding the problem before coding,reducing software complexity,Event Storming,Example Mapping,technical complexity,technical debt,feature creep,product engineering,software delivery"
tags: [software-mindset-series]
---

When a product grows, teams often think their problems come from technical complexity.

People often blame technical debt, complex code, or the lack of tests.

But there is another cause, more subtle.

Some features bring almost no value…
yet they still weigh on the whole system.

Over time, I realized that the features that create problems are not always the most complex ones.

They are often the ones that should probably never have been built.

## An unnecessary feature can be very expensive

On one project, I joined a team maintaining a software that was already in production.

Among the many features of the product, there was one that seemed important. It had been developed before I arrived and had been part of the system for several years.

But through discussions with the sales and support teams, the same observation kept coming back: very few customers were actually using it.

Some didn’t understand it.  
Others simply didn’t see the value of using it.

The problem was that this feature was not isolated.

It was coupled to the core domain, the part of the system that was actually bringing value to customers and generating revenue.

Every time the business evolved, we had to check whether this feature would be impacted.

It was bringing almost no value, but it was slowing down every change.

You might think the solution is simple: just remove it.

But in reality, removing a feature is rarely an easy decision.

Maybe a few customers are still using it.  
Maybe it appears in the documentation.  
Maybe it was even sold in some offers.

Removing it often becomes a difficult decision.

Not every company has the ability to remove products overnight like Google does.

So the feature stays.

And little by little, it becomes another constraint for the team.

**An unnecessary feature is never free.  
It adds complexity, even if nobody uses it.**

## A feature in production never really disappears

We often underestimate one thing: a feature doesn’t stop existing the day it is delivered.

Once it is in production, it needs to be:

* maintained
* tested
* considered in future changes
* understood by new developers

Every new feature has to coexist with the previous ones.

Little by little, the system becomes harder to evolve.

We often call this technical debt, but there is another form of debt: functional debt.

Features that are rarely used but still weigh on the system.

## Not every feature deserves to be complex

When a team spends several weeks building a very polished feature, they take a risk.

The risk of building something complex… for a need that may not even exist. The more complex a feature is, the more expensive it will be to maintain.

That is why I prefer starting with a simple version.

A version that allows us to validate the idea, observe how it is used, and learn.

If the feature is useful, we can improve it.

If it is not, we will have lost much less time.

## The real problem is not technical

In most cases, the problem is not the quality of the code.

It comes from a lack of understanding of the problem.

When a team builds a solution before really understanding the problem, they risk creating something useless.

And an unnecessary feature is rarely neutral.

It increases the complexity of the system.  
It slows down future changes.  
And it eventually becomes a burden for the whole team.

## Understand before building

Over time, I learned that it is worth investing time before writing code.

Understanding the business.  
Understanding the needs.  
And most importantly, developing empathy for users.

Workshops like Event Storming or Example Mapping are very useful for that.

They help product and technical teams align on what they actually want to build.

And very often, they reveal that the initial solution was not the right one.

## Build less to deliver better

A team does not slow down only because of technical debt.

Over time, system complexity increases.  
Technical complexity, functional complexity, but also organizational complexity.

As a product grows, there are more features, more edge cases, more integrations, and more teams involved.

This is often a good sign: it means the product is used and the company is growing.

But this growth has a cost.

Every new feature adds a little more complexity to the system. And little by little, evolving the software becomes harder.

In this context, the most important question is not only:

**“How are we going to build this feature?”**

But rather:

**“Should we really build it?”**

Understanding the business, the company goals, and putting yourself in the place of the people who will use the software becomes essential.

Because before thinking about the solution, we first need to make sure we are solving the right problem.

**Building less, but building the right things, is often the safest way to deliver better.**
