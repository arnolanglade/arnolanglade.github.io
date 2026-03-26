---
title: "Why a poor testing strategy slows down delivery"
date: "2026-04-30"
url: "testing-strategy-delivery"
image_credit: "nguyendhn"
description: "A poor testing strategy can slow down your team. Learn how to improve feedback loops and speed up software delivery."
keywords: "testing strategy,software testing,software delivery,slow CI,end-to-end tests,unit tests,fast feedback,software quality,feedback loop,continuous integration,automated tests,CI performance,test reliability,integration tests,CI/CD pipeline,software development"
tags: [software-mindset-series]
---

Tests are supposed to help teams deliver more safely.  
But they also provide fast feedback to developers while they are working.

However, in some teams, they produce the exact opposite effect.

I once worked on a project where tests were everywhere in the codebase. On paper, everything looked good: many tests, a CI pipeline in place, and a team that cared about quality.

But in practice, it was much more complicated.

Most of the tests were end-to-end tests. They validated the application through the user interface using Selenium. On paper, it felt reassuring: we were simulating real user behavior in a browser.

But in reality, these tests were often fragile.

Starting a browser in the CI, simulating clicks, waiting for the DOM to update… all of this introduced a lot of uncertainty. We regularly had false positives: a test would fail even though the application was working perfectly.

Little by little, the CI became unstable. And when a test failed, it was not always clear if the issue came from the code… or simply from the test itself.

## When CI becomes a bottleneck

Over time, the test suite became very large. It sometimes took several hours to get a full result in the CI.

The feedback loop was therefore very slow. After pushing code, we had to wait a long time before knowing if everything was still working correctly.

What made the situation even more frustrating was that some failures were not related to the application itself. Selenium tests would sometimes fail for unclear reasons: a missing button, an element appearing too late, or a browser behaving differently.

Little by little, trust in the tests started to decrease.

Tests were supposed to make development safer… but in this case, they mostly slowed the team down and reduced its ability to deliver.


## Finding the right balance

The real problem was not the lack of tests. It was how they were distributed.

On this project, most of the tests were end-to-end tests. As a result, tests were slow, fragile, and the feedback came very late.

An effective testing strategy usually relies on several levels.

Unit tests, which are fast to run and give immediate feedback to developers about the behavior of the code.

Integration tests, which verify that the application works correctly with external dependencies such as databases, object storage, file systems, or other services.

And finally, a few end-to-end tests, used carefully to validate critical features where a regression would have a direct impact on the business.

Each type of test has a different role.

When this balance is not respected, the test suite becomes slow, fragile, and difficult to maintain.

## The importance of team alignment

On this project, we had many discussions about how to test the system: what is a unit test? Should we test through the UI or directly through the code? What level of coverage should we aim for?

These debates kept coming back, and we struggled to agree on a clear direction.

We eventually decided to bring in someone to train the team. They shared their vision without dogma and, most importantly, helped us align.

From there, we started to progressively improve our testing strategy. The goal was simple: make the test suite more stable and improve the CI feedback time.

Step by step, tests became more reliable, the CI became faster, and the team regained confidence in its tests.


## Tests to deliver with confidence

A good testing strategy is not about reaching a coverage percentage.  
It is about maintaining a fast feedback loop.

And without a good testing strategy, a team will eventually slow down.

When tests are well designed:

* they detect issues early  
* they secure deployments  
* they allow developers to work with confidence  

And this is often what makes the difference between a team that hesitates to deploy… and a team that can deliver regularly.
