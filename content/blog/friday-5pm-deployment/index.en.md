---
title: "The Friday 5pm deployment: why big releases are risky"
date: "2026-04-21"
url: "friday-5pm-deployment"
image_credit: "sincerelymedia"
description: "Why waiting too long before deploying increases risk. A real story about a Friday 5pm deployment and why deploying often makes teams safer."
keywords: "software deployment,production deployment,continuous delivery,deploy often,production release,deployment risk,software release,software delivery"
tags: [software-mindset-series]
---

A few years ago, I waited two weeks before deploying a feature.

Two weeks of work.
Two weeks of commits.
Two weeks without a deployment.

Everything seemed ready.

It was a Friday, around 5pm.
Confident, I triggered the deployment.

A few minutes later, production was not working anymore.

Big regression.
A lot of pressure.

We had to understand what happened and fix the system urgently.

Looking back, it was not really a surprise.
For two weeks, we had been working in tunnel mode, focused on finishing the feature.

In this situation, you mostly think about finishing… not about delivering small increments.

## The problem with big deployments

When you wait too long before deploying, changes accumulate.

One feature becomes several features.
A few commits become dozens.
A simple modification becomes a set of changes that are difficult to understand.

And when something breaks in production, everything becomes more complicated.

You have to analyze much more code.
Understanding what changed becomes harder.
Finding the root cause takes time.

The bigger a deployment is, the riskier it becomes.

## Deliver small changes to learn faster

On the other hand, when you deploy often, each release contains only a small number of changes.

If a problem appears, it is much easier to understand where it comes from.

You know the issue is probably in the latest commits.

And most importantly, you can fix it quickly.

That is why I try to deploy as often as possible.

Not necessarily complete features.
But stable increments.

Small improvements that can go to production at any time.

## When production becomes a feedback tool

When a team deploys rarely, production becomes a stressful place.

People hesitate to deploy.
They wait for the right moment.
Changes accumulate.

On the other hand, when deployments are frequent, production simply becomes a normal step of the work.

Developers know their changes can be deployed quickly.

Problems are detected earlier.

And the team gains confidence.

## A change of mindset

In some teams, merging a pull request is already seen as a success.

But in reality, a feature only truly exists when it is in production.

This is an important change of perspective.

Code in a repository does not create value. Only code in production does.

## Deploying to reduce risk

People often think deploying often is risky.

In reality, it is the opposite.

Big deployments are much more dangerous.

Because they concentrate too many changes at the same time.

Deploying regularly reduces the risk.

Each deployment becomes smaller.
Easier to understand.
Easier to fix.

And little by little, production stops being a stressful moment.

It simply becomes a habit.
