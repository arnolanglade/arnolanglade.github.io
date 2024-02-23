---
title: Développer avec le sylius resourcebundle
conference:
  title: Symfony live Paris 2015
  link: https://live.symfony.com/2015-paris
description: |
  The resource bundle easy CRUD and persistence for Symfony applications.
  During our work on Sylius, the core team noticed a lot of duplicated code across all controllers. The core team started looking for good solution of the problem. The core team is not big fans of administration generators (they're cool, but not for our usecase!) - the core team wanted something simpler and more flexible.
  Another idea was to not limit ourselves to one persistence backend. Initial implementation included custom manager classes, which was quite of overhead, so the core team decided to simply stick with Doctrine Common Persistence interfaces. If you are using Doctrine ORM or any of the ODM's, you're already familiar with those concepts. Resource bundle relies mainly on ObjectManager and ObjectRepository interfaces.
  The last annoying problem this bundle is trying to solve, is having separate "backend" and "frontend" controllers, or any other duplication for displaying the same resource, with different presentation (view). The core team also wanted an easy way to filter some resources from list, sort them or display by id, slug or any other criteria - without having to defining another super simple action for that purpose.
keyword: "sylius,resource bundle,crud,symfony,rad"
video:
  id: O8jzsNVFQHg
  title: "Développer avec le sylius resourcebundle"
date: 2015-03-01
slideshare: p8KjWf2PyoB94R
---

## Resources

{{< external-link href=https://sylius.com/blog/syliusresourcebundle-how-to-develop-your-crud-apps-faster/ label="Bundle documentation" >}}

{{< external-link href="https://github.com/Sylius/SyliusResourceBundle" label="Github repository" >}}

{{< external-link href="https://sylius.com/" label="Sylius website" >}}
