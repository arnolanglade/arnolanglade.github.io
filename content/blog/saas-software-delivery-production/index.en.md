---
title: "Merging code does not mean delivering"
date: "2026-05-05"
url: "saas-software-delivery-production"
image_credit: "simonkadula"
description: "Moving to SaaS changes delivery: why merging code is not enough and how to deliver to production in a reliable and frequent way."
keywords: "saas software delivery,production deployment,continuous delivery,ci cd software,software deployment,feedback loop development,on premise vs saas,deliver to production,software delivery cycle,engineering delivery"
tags: [software-mindset-series]
---

At first, we don’t really realize what moving to SaaS implies.

On paper, it mostly looks like an infrastructure change. But in reality, it is a much deeper shift. The mindset changes, the constraints evolve, and most importantly, the way we deliver software is not the same anymore.

We no longer just deliver code. We need to deliver to production, in a reliable way, and at any time.

## When delivering is not really delivering

In an on-premise context, going to production is often a special moment.

We prepare a version for months. We validate it, sometimes over several weeks, and then we release it to clients and partners.

In this model, it is possible to work for a long time without actually delivering to production.

A merged pull request can give the feeling that the work is done. Once the code is on the main branch, we often consider the job finished.

But in reality, value only exists when the code is running in production.

## The shock of moving to SaaS

When a team moves to a SaaS model, this way of working no longer works.

Production becomes the center of the system. Every change can have an immediate impact on users.

We can no longer wait weeks before delivering. We can no longer afford risky deployments. And most importantly, we can no longer see production as a secondary step.

This change requires a new mindset.

Merging a pull request is not enough anymore. What matters is what is actually in production.

## A new way of working

In this context, teams need to adapt how they build software.

Changes need to be smaller, more frequent, and better controlled.

Each commit should be able to go to production without putting the system at risk.

This requires several things:

* reliable tests
* a fast CI
* an automated deployment system
* the ability to roll back quickly if something goes wrong

Without these, delivering becomes risky. And when delivering becomes risky, teams deliver less often.

## Production as a feedback tool

In a SaaS environment, production is no longer just the final step.

It becomes a feedback tool.

Teams can quickly observe the impact of their changes, detect issues earlier, and fix them faster. The feedback loop becomes shorter.

This is often what allows teams to improve product quality while also accelerating delivery.

## A change of mindset

Moving from on-premise to SaaS is not only a technical change.

It is a change of mindset.

We no longer focus only on writing correct code. We focus on delivering regularly, in production, in a reliable way.

The work is not done when the code is merged. It is done when it is in production… and working.

## Conclusion

Moving to SaaS highlights an important point.

What matters is not the code we write, but the code running in production. And until a change is in production, it creates no value.

To get there in a reliable way, teams need to adapt how they work: their practices, their tools, and their mindset.

This is often the moment when teams start to truly transform the way they deliver software.
