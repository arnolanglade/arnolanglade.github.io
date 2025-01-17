---
title: Symfony, Hexagonal architecture and CQRS
date: 2021-03-30
image_credit: alexkixa
url: hexgonal-architecture-and-cqrs-with-symfony
aliases:
    - "how-did-I-organize-my-last-symfony-project.html"
    - "how-did-I-organize-my-last-symfony-project"
description: "Return of experience: In this blog post, I will explain how I organized my last Symfony projects. They are mainly inspired by Hexagonal and CQRS architecture."
keywords: "software,software architecture,symfony,cqrs,cqrs with symfony,php,hexagonal architecture,hexagonal architecture with symfony,port and adapters"
tags: [software-architecture, symfony]
---

In this blog post, I will explain how I organized my last Symfony projects.I mainly use Hexagonal Architecture and CQRS. Keep in mind that I did not aim to implement these architectures strictly by the book. I only took concepts that helped me to create a straightforward and well-organized codebase.

Looking at the project’s root, there’s nothing particularly unusual. I kept all the folders and files generated during the Symfony installation.

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

In the following sections, we will explore how I organized the application sources using Hexagonal Architecture and how CQRS helped me simplify the modeling write and read usecase.

## My Approach to hexagonal architecture

> The hexagonal architecture, or ports and adapters architecture, is an architectural pattern used in software design. It aims at creating loosely coupled application components that can be easily connected to their software environment by means of ports and adapters. This makes components exchangeable at any level and facilitates test automation.
>
> https://en.wikipedia.org/wiki/Hexagonal_architecture_%28software%29

The main advantage of Hexagonal Architecture is that it decouples the heart of your application from [Input/Output](https://press.rebus.community/programmingfundamentals/chapter/input-and-output/).

I call the heart of the application the `Domain`. This is the area of the app where all the pieces of code represent the problem we are solving. This part must be side-effect-free, it must not rely on any tools, frameworks, or technologies.

`Outputs` refer to the tools the application needs to work, such as network calls, database queries, filesystem operations, actual timestamps, or randomness. All `Outputs` are moved to the infrastructure. `Inputs` refer to how the domain is exposed to the outside world, for example, it can be a web controller or a CLI command. These pieces of code are moved to the `UserInterface`.

**Note:** Check out my blog post about Hexagonal Architecture to dive deeper into the subject:

{{< page-link page="hexagonal-architect-by-example" >}}

Based on this approach, my first decision was to split the `src` directory into three areas: `Domain`, `Infrastructure`, and `UserInterface`.

```bash
tree src/Domain/ -L 1
api/src/Domain/
├── Domain
├── Infrastructure
└── UserInterface
```

**Coupling rule:**
* `Domain` must **not** depend on the `Infrastructure` and `UserInterface`.
* `Infrastructure` and `UserInterface` can depend on the `Domain`.

I am not a big fan of Onion Architecture because I prefer to keep my projects as simple as possible. Having many layers can make maintenance challenging, as it requires aligning the entire team on coupling rules. Even agreeing with yourself can be difficult, so getting several people to agree is often much harder. Here, we follow just one simple rule : `Domain` must **not** use IO

At times, I needed to create custom libraries because I couldn’t find any open-source libraries that met my expectations. To avoid coding directly in the `vendor` directory, I introduced a third area called `Libraries` (this area is optional). These libraries can be used in both the `Domain`, `UserInterface` and `Infrastructure` layers, but their usage must not violate the coupling rules defined for those areas.

```bash
tree src/Domain/ -L 1
api/src/Domain/
├── Domain
├── Infrastructure
├── Librairies
└── UserInterface
```

**Coupling rules:** `Libraries` must **not** depend on `Domain`, `UserInterface` and `Infrastructure`

Finally, I created a sub-area called Application within the Infrastructure layer. It contains all the code needed to have the application up and running, such as framework code (Symfony kernel and framework customizations), data fixtures, and migrations. In the following example, `Exception` and `Security` folders contain framework customizations.

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

**Note :** Looking back, I won't keep the folder in infra. All code related to framework customization should go into a dedicated folder called framework in the `Libraries` folder, whereas `Fixtures` and `Migrations` can remain at the root of the infrastructure folder.

## Focus on the business

A really important aspect for me is organizing the codebase around business concepts. I avoid naming folders and classes based on technical patterns like `Entity`, `ValueObject`, or `Repository`, and especially not `Provider`, `DataMapper`, or `Form`. Non-technical people should be able to understand the purpose of a class simply by its name.

### Domain

```bash
tree src/Domain -L 1
api/src/Domain
├── Cartographer
└── Map
```

Since I avoided using technical terms to name folders, it's easy to imagine that the project is about creating maps. Now, let’s take a look inside the `Map` folder:

```bash
tree src/Domain/Map -L 1
├── CartographersAllowedToEditMap.php   // ValueObject
├── Description.php                     // ValueObject
├── MapCreated.php                      // Event
├── MapId.php                           // ValueObject
├── MapName.php                         // ValueObject
├── Map.php                             // Root Aggregate
├── Maps.php                            // Repository Interface
├── Marker                              // All classes to design Marker entity
├── MarkerAddedToMap.php                // Event
└── UseCase                             // Use cases orchestration
```

In this folder, we have all the code necessary to design the `Map` aggregate. As you can see, I didn’t organize it by design patterns like `ValueObject`, `Entity`, or something else.

As you might have noticed, the `Map` entity has a one-to-many relationship with the `Marker` entity. All classes required to model this entity are located in the `Marker` folder, which is organized in the same way as the `Map` directory.

The `UseCase` folder contains all the code needed to orchestrate use cases, such as commands, their handlers, and business validations.

**Tip:** I don’t suffix repositories with "Repository." Instead, I try to use a business concept for the name, such as `ProductCatalog` for a `Product` aggregate. If I can’t find a suitable business concept, I use the plural form of the aggregate name, since a repository represents a collection of objects.

I organize the root of the `Infrastructure` and `UserInterface` folder in the same way as the `Domain` one.

### Infrastructure

```bash
tree src/Infrastructure -L 1            
api/src/Infrastructure
├── …
├── Cartographer
└── Map
        └── InMemoryMaps.php
        └── PostgreSqlMaps.php
```

### UserInterface

```bash
tree src/UserInterface -L 1            
api/src/UserInterface
├── …
├── Cartographer
└── Map
        └── WebAddMarkerToMap.php
        └── CliAddMarkerToMap.php
```

## My Approach to CQRS

> Starting with Command Query Responsibility Segregation, CQRS is simply the creation of two objects where there was previously only one. The separation occurs based upon whether the methods are a command or a query (the same definition that is used by Meyer in Command and Query Separation, a command is any method that mutates state and a query is any method that returns a value).
>
> [Greg Young](https://web.archive.org/web/20190211113420/http://codebetter.com/gregyoung/2010/02/16/cqrs-task-based-uis-event-sourcing-agh/)

The main idea of CQRS is the separation of the read and write sides. You can use different models for writing (commands) and reading (queries). I appreciate the concept of having two small, simple models dedicated to specific : purposes reading or writing instead of relying on one huge model. This approach helps prevent your aggregate from becoming a "god object," which can happen as the system grows and more read and write use cases need to be handled.

Additionally, when you link aggregates by their IDs instead of direct references, complex read use cases can become challenging. How do you retrieve information from several aggregates? It’s simpler to query the database directly rather than merging data from multiple aggregates.

**Note:** Check out my blog post to understand the difference between CQS and CQRS:

{{< page-link page="what-is-the-difference-between-cqs-and-cqrs-patterns" >}}

To manage having two models with the same name, I decided to split each subfolder of the domain into two areas: `Command` and `Query`. This structure allows me to design models with the same name, tailored to either reading or writing purposes.

```bash
tree src/Domain/ -L 2
api/src/Domain/
├── Cartographer
│   ├── Command
│   └── Query
└── Map
    ├── Command
    └── Query
```

**Coupling rule:**  `Command` area must not depend on the `Query` area and vice versa.

**Caution:** Using CQRS, as defined by Greg Young, doesn’t mean introducing unnecessary complexity into your application. You don’t need a command and query bus, an event-sourcing architecture, or multiple databases to apply it. I chose to separate write and read use cases because it made my codebase simpler and clearer.

## Last word

I’ve spent the last few years trying to find the perfect architecture, but I’ve realized it doesn’t exist. Instead, I’ve focused on using architectural concepts that make me and my teammates comfortable working on a daily basis. This project organization has been applied to multiple production projects. One of them is a [side project](https://mymaps.world) I created for fun to build maps without relying on Google Maps. The others are a professional project that real people use daily.

