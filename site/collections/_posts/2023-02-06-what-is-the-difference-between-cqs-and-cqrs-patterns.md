---
title: What is the difference between CQS and CQRS patterns?
description: "CQS and CQRS are misunderstood design patterns. They are more simple than people think! CQS is about dividing an object's methods into two categories: commands and queries while CQRS is about separating query and command into two objects."
date: 2023-02-06
image: what-is-the-difference-between-cqs-and-cqrs-patterns.webp
image_credit: mihaistrompl
keywords: "cqs,cqrs,design pattern,software"
tags: [software-architecture, design-patterns]
---

I recently found out that I did not grasp those design patterns. There are a lot of resources on the Internet about them but they are not always accurate. That’s a shame because they are pretty simple. I will share my understanding of them with you.

## What is Command Query Segregation (CQS)?

> The fundamental idea is that we should divide an object's methods into two sharply separated categories:
>  * Queries: Return a result and do not change the observable state of the system (are free of side effects).
>  * Commands: Change the state of a system but do not return a value.
>
> [Martin Fowler](https://martinfowler.com/bliki/CommandQuerySeparation.html)

This concept is not specific to Object Oriented Programming but improves the object's design. The object methods only have a single purpose: reading or changing the object state. We can see an object as a living entity. We can ask a question to someone because we need information. For example, we can ask someone what time it is. This is a query. We can ask someone to do something, we don’t expect an answer but we want to get the job done. For example, we can ask a child to finish his/her spinach. This is a command.

We can apply this pattern to any object: like an aggregate. Let’s take an example! I would like to add markers on a map and then I would like to find which markers are the closest to a specific location (GPS Coordinates).
k
```ts
class Map {
    addMarker(label: string, latitude: number, longitude: number): void {
        // ...
    }

    findClosestMarkers(location: Location): Marker[] {
        // ...
    }
}
``` 

The `addMarker` method is in charge of mutating the object state without returning any result, while the ‘findClosestMarkers’ method finds the right markers without changing the object’s state. This object follows the CQS definition.

{% include training-link.html %}

Let’s go further. If we design our aggregates following the CQS pattern, we should apply it to the classes that handle use cases.

```ts
interface MapService {
    addMarkerToTheMap(label: string, latitude: number, longitude: number); void
    findAllMarkersCloseToLocation(): Marker[]
}
``` 

This ensures there is no inconsistency in the codebase. The business services use and manipulate the aggregates. For example, if the `MapService.addMarkerToTheMap` method returns a result, it might mean that the `Map.addMarker` method will need to return the expected result.

## What is Command Query Responsibility Segregation (CQRS)?

> Starting with CQRS, CQRS is simply the creation of two objects where there was previously only one. The separation occurs based upon whether the methods are a command or a query (the same definition that is used by Meyer in Command and Query Separation, a command is any method that mutates state and a query is any method that returns a value).
>
> [Greg Young](https://web.archive.org/web/20190211113420/http://codebetter.com/gregyoung/2010/02/16/cqrs-task-based-uis-event-sourcing-agh/)

**Note:** Greg Young’s blog does not exist anymore but his blog posts are still available thanks to archived.org.

CQRS is the separation of command and query into two different objects instead of only one. MapService does not follow the CQRS pattern because it has a query and a command. We need to cut this object in half.

```ts
interface MapReadService {
    addMarkerToTheMap(label: string, latitude: number, longitude: number); void
}

interface MapWriteService {
    findAllMarkersCloseToLocation(): Marker[]
}
``` 

That’s pretty simple, right? Anyway, we don’t need to introduce complicated things in our application to use this tactical design pattern. We don’t need a write and a read model,
a command and query bus, an event sourcing architecture or multiple databases. Greg Young published this blog post in 2012 to explain what CQRS was not about.

> CQRS is not a silver bullet
> 
> CQRS is not a top level architecture
> 
> CQRS is not new
> 
> CQRS is not shiny
> 
> CQRS will not make your jump shot any better
> 
> CQRS is not intrinsically linked to DDD
> 
> CQRS is not Event Sourcing
> 
> CQRS does not require a message bus
> 
> CQRS is not a guiding principle / CQS is
> 
> CQRS is not a good wife
> 
> CQRS is learnable in 5 minutes
> 
> CQRS is a small tactical pattern
> 
> CQRS can open many doors.

**Note:** This blog does not exist anymore but it has been archived by archived.org. The post is available [here](https://web.archive.org/web/20160729165044/https://goodenoughsoftware.net/2012/03/02/cqrs/)

Depending on the number of use cases the service classes can become really huge. CQRS helps to decrease their size but I am a big fan of them. I like to separate each use case into a dedicated class.

I've written a blog post to explain what is a commands and we can apply it to query too:

{% include blog-post-link.html url='/command-handler-patterns.html' image='command-handler/command-handler.webp' title='Command and command handler design pattern' %}

Thanks to my proofreader [@LaureBrosseau](https://www.linkedin.com/in/laurebrosseau).
