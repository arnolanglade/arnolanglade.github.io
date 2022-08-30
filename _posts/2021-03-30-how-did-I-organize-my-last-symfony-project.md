---
title: How did I organize my last Symfony projects?
permalink: /:title:output_ext
description: "Return of experience: In this blog post, I will explain how I organized my last Symfony projects. They are mainly inspired by Hexagonal and CQRS architecture."
layout: post
date: 2021-03-30
image: project-symfony-organization.jpg
alt: How did I organize my last Symfony projects?
tags: [php, symfony, architecture]
related_posts: [Command and command handler design pattern, "How to validate a command?", Persisting entities without ORM]
---

# How did I organize my last Symfony projects?

![How did I organize my last Symfony projects?](assets/img/posts/project-symfony-organization.jpg)
[@alexkixa](https://unsplash.com/@alexkixa)

In this blog post, I will explain how I organized my last Symfony projects. They are mainly inspired by Hexagonal and CQRS architecture. Keep in mind that I did not try to implement these architectures by the book, I only took some concepts that helped me to have a simple and clear codebase organization.

If we have a look at the project’s root, nothing special happens, I kept all folders and files created during Symfony installation.

```bash
tree . -L 1                       
├── bin
├── composer.json
├── composer.lock
├── config
├── features
├── public
├── src
├── symfony.lock
├── tests
├── translations
├── var
└── vendor
```

In the next sections, we are going to see how I organized the src folder.

## Hexagonal architecture

The foundation of the hexagonal architecture is the explicit separation between the domain (inside) and the infrastructure (outside). All dependencies are going from Infrastructure to the Domain.

The domain is the part of the application that contains your business logic. It must reflect as much as possible the problem your application has to solve. This part of the application must not use IO, the infrastructure contains them all. For instance, IO are side effects like network calls, database queries, filesystem operations, actual timestamps or randomness..

Based on that information my first decision was to split src into two areas: `Domain` and `Infrastructure`.

```bash
tree src/Domain/ -L 1
api/src/Domain/
├── Domain
└── Infrastructure
```

**Coupling rules:**
* Domain must not depend on the Infrastructure.
* Domain must not use IO

I am not a big fan of the onion architecture because I want to keep my projects as simple as possible. Having a lot of layers can be really hard to maintain because you need to align the whole team on the coupling rules. Agreeing with yourself is not easy, so getting several people to agree may be really hard. Here, we only have a single rule.

Sometimes, I needed to write libraries because I could not find any open source libraries that match my expectations. To avoid coding in the vendor directory, I introduced a third area called `Libraries` (this new area is optional). Those libraries may be used in the domain and the infrastructure but their usage should not break the coupling rules that are defined for those areas.

```bash
tree src/Domain/ -L 1
api/src/Domain/
├── Domain
├── Infrastructure
└── Librairies
```

**Coupling rules:**
* Libraries must not depend on Domain and Infrastructure

Finally, I created a “sub” area called `Application` in the infrastructure that contains all pieces of code needed to have an application up and running: framework code (Symfony kernel, framework customizations), data fixtures, and migration.

```bash
tree src/Infrastructure/Application -L 1 
api/src/Infrastructure/Application
├── Exception 
├── Fixture
├── Kernel.php
├── Migrations
├── Security
└── Kernel
```
In this example, `Exception` and `Security` folders contain framework customizations.

## Business first

A really important thing for me is to drive codebase organization by business concepts. I don’t want to name folders and classes with technical patterns like factory or repository for instance. Non-tech people should be able to understand what a class does thanks to its name.

### Domain

```bash
tree src/Domain -L 1
api/src/Domain
├── Cartographer
└── Map
```

Because I did not use any technical words to name folders we can easily imagine the project is about making maps. Now, let’s have a look inside the `Map` directory:

```bash
tree src/Domain/Map -L 1
├── CartographersAllowedToEditMap.php   // Value object
├── Description.php   // Value object
├── MapCreated.php   // Event 
├── MapId.php   // Value object
├── MapName.php   // Value object
├── Map.php   // Root aggregate
├── Maps.php   // Repository interface
├── Marker    // All classes to design Marker entity
├── MarkerAddedToMap.php   // Event
├── MarkerDeletedFromMap.php   // Event
├── MarkerEditedOnMap.php   // Event
├── UnknownMap.php   // Exception
└── UseCase    // Use cases orchestration
```

In this folder, we have all the pieces of code needed to design the `Map` aggregate. As you can see, I did not organize it by design patterns like `ValueObject`, `Event` or `Exception`.

As you might have understood the `Map` entity has a one-to-many relationship with the Marker entity. All classes needed to modelize this entity are in the Marker folder and they are organized the same way as the `Map` directory.

The `UseCase` folder gathers all pieces of code needed to orchestrate use cases like command, their handler and business validation.

**Tip:** I don’t suffix repositories by ‘Repository’ but I try to use a business concept to name them like `ProductCatalog` for a `Product` aggregate. If I can find a business concept to name it I use the plural of the aggregate because a repository is a collection of objects.

### Infrastructure

I organize the root of the `Infrastructure` folder the same way as the `Domain` one.

```bash
tree src/Infrastructure -L 1            
api/src/Infrastructure
├── Application
├── Cartographer
└── Map
```

Now, let’s have a look at the `Map` directory:

```bash
tree src/Infrastructure/Map -L 1 
api/src/Infrastructure/Map
├── Storage
└── UserInterface
        └── Web
        └── Cli
```

The `Storage` namespace gathers everything related to data storage like repositories, queries. The `UserInterface` namespace gathers everything related to ways to interact with the application like the WEB API (controllers) called by the front application or CLI (Symfony commands).


## CQRS

CQRS is the acronym for Command Query Responsibility Segregation. The main idea of CQRS is that you can use different models for writing (command) or reading (query) information. I like the idea of having two small and simple models dedicated to a precise purpose: reading or writing instead of having one big model. It can prevent your aggregate from becoming a god object because as things progress you can have many write and read use cases to handle.

From this pattern, I decided to split the domain into two areas, the first one: `Command` and the second one: `Query`. It allows me to design a model with the same name for these reading or writing purposes.

```bash
tree src/Domain/ -L 2
api/src/Domain/
├── Command
│   ├── Cartographer
│   └── Map
└── Query
    ├── Cartographer
    └── Map
```

**Coupling rule:** 
* `Command` area must not depend on the `Query` area and the other way around.

**Note:** I did not make major changes in the infrastructure, the only change I made is to split the storage into two areas like the domain.

**Caution:** For those projects, I did not make any projections because my database schema remained simple so I did not need them. I only decided to split my models because my codebase was simple and clearer this way.

## Last word
I tried for the last few years to find the perfect architecture but it does not exist. I just tried to use some architectural concepts that make me and my teammates comfortable to work on a daily basis. This project organization has been used for two projects that are in production. One of these projects is a side project I made for fun to create maps without Google Maps. The second was a professional project, real people use it on a daily basis.

Thanks to my proofreader [@LaureBrosseau](https://twitter.com/LaureBrosseau).
