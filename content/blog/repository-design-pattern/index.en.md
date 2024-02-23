---
title: The repository design pattern
date: 2024-04-09
image_credit: ningshi
description: Discover the repository design pattern explained thanks to a simple example. Learn how it works and it ensures a clean separation between the domain model and the persistence model, aiming to hide the complexity of the object’s state storing.
keywords: Repository Pattern,Persistence Model,Aggregate,Domain-Driven Design,DDD,Design Pattern,DDD tactical patterns
tags: [design-patterns, OOP, repository]
---
The repository is a valuable design pattern for managing the persistence and retrieval of domain objects. It ensures a clean separation between the domain model and the persistence model, aiming to hide the complexity of the object’s state storing.

A repository behaves as a collection of domain objects. However, it can handle only a single type of domain object at a time. It provides a simple API that allows users to save and get domain objects no matter where and how they are stored.

Consider a concrete example: we are working in the cartography domain, developing an application that enables people to create maps and add markers to them. To understand how it works, let's create a repository that handles a  `Map` aggregate.

So, what does a repository look like? The following example illustrates an interface that manages a `Map` domain object. It's quite basic, allowing for the persistence, retrieval, and removal of a map.

```php
interface Maps
{
   /**
    * @throws \LogicException
    * @throws UnknownMap
    */
   public function get(MapId $mapId): Map;

   /**
    * @throws \LogicException
    */
   public function add(Map $map): void;

   /**
    * @throws \LogicException
    */
   public function remove(MapId $mapId): void;
}
```

In the following example, we can see an implementation of a repository using Doctrine ORM:

```php
final class DoctrineMaps implements Maps
{
   public function __construct(
       private EntityManagerInterface $entityManager
   ) {}

   public function get(MapId $mapId): Map
   {
        try {
            $doctrineMap = $this->entityManager->find(
                DoctrineMap::class, 
                (string) $id
            );
            
            if (!$doctrineMap) {
                throw UnknownMap::fromId($id);
            }

            return Map::fromState($doctrineMap);
        } catch (ORMInvalidArgumentException|ORMException $e) {
            throw new LogicException('Cannot retrieve a map', 0, $e);
        }
   }

   public function add(Map $map): void
   {
        try {
            $doctrineMap = $this->entityManager->find(
                DoctrineMap::class, 
                (string) $map->id
            );
            
            if (!$doctrineMap) {
                $doctrineMap = new DoctrineMap();
            }
            
            $map->mapTo($doctrineMap);
            $this->entityManager->persist($doctrineMap);
            $this->entityManager->flush();
        } catch (ORMInvalidArgumentException|ORMException $e) {
            throw new LogicException('Cannot persist a map', 0, $e);
        }
   }


   public function remove(MapId $mapId): void
   {
       try {
           $doctrineMap = $this->entityManager->getReference(
               DoctrineMap::class, 
               (string) $mapId
           );
           
           $this->entityManager->remove($doctrineMap);
           $this->entityManager->flush();
       } catch (ORMInvalidArgumentException|ORMException $e) {
           throw new LogicException('Cannot remove the map', 0, $e);
       }
   }
}
```

Using an ORM is not mandatory to implement this design pattern. I’ve written a blog post explaining how to avoid using an ORM to persist the state of your domain objects:

{% include blog-post-link.html url='/persisting-entities-without-orm.html' image='persisting-entity-without-orm.webp' title='Persisting entities without ORM' %}

What happens under the hood? Domain objects are abstractions of the domain problem, they are rich models that handle business logic. In contrast, the persistence model consists of data structures only used for storing data.

![Understand how the repository works](images/posts/repository-design-pattern/repository-overview.svg)

When a domain object is added to the repository, it's converted into a persistence model that is used to persist the object's state. During retrieval, the repository gets data from storage to recreate the domain model from the persistent model.

{{< training-link >}}

Do the functions 'get, add, and remove' ring a bell? Perhaps, they remind you of CRUD operations? However, a repository isn’t a tool for simplifying CRUD. The example given earlier is straightforward and illustrates some common methods a repository might include. Beyond this, a repository acts as an Anti-Corruption Layer (ACL), allowing for the design of domain problems without worrying about persistence. Personally, I prefer using in-memory repositories at the beginning of a new project. This approach allows me to postpone the database choice. This is a strategy I applied in the MikadoApp project. Have a look at the GitHub sources:

{% include mikado-method-source.html %}

![Repository acts as acl](images/posts/repository-design-pattern/repository-acts-as-acl.svg)

The repository design pattern is ideal for isolating the domain from Input/Output operations. I’ve written an article about hexagonal architecture, an architectural pattern that helps in building sustainable software and ease testing too:

{% include blog-post-link.html url='/hexagonal-architect-by-example.html' image='hexagonal-architecture/hexagonal-architect-by-example.webp' title='Hexagonal architecture by example' %}

Depending on business needs, a repository can include various retrieval methods. As I mentioned earlier, a repository is a collection of domain objects. To be more precise, it's a collection of aggregates. An aggregate is a cluster of objects that together represent a domain concept, like the `Map`. In this case, the `Map` object is the aggregate root, and the `Marker` object is an entity that belongs to the `Map` aggregate. Since the aggregate root acts as the entry point for all internal interactions, a repository can only work with an aggregate root.

For instance, to change a marker's location on a map, we won’t use a marker repository, as it cannot exist because the `Marker` is not an aggregate root. To perform this action, we need to use the `Map` repository to retrieve the `Map` aggregate, and then call a method on the `Map` to move the Marker.

```php
$maps = new PostgreSqlMaps(/** ... */);
$map = $maps->get(new MapId('2d3e4f5g-6h7i-8j9k-0l1m-2n3o4p5q6r7s'));

$map->move(
    new MarkerId('2d3e4f5g-6h7i-8j9k-0l1m-2n3o4p5q6r7s'), 
    new Coordinates(43.48333, -1.53333)
);
``` 

**Note:** I like using this naming convention for retrieval methods: methods starting with 'get' aim to fetch the aggregate or throw an exception, while those beginning with 'find' attempt to retrieve the aggregate but return an empty result if there is no aggregate found.

Be careful when removing an aggregate, as this action can significantly impact your application. For instance, consider a use case where a marker has categories like bar, restaurant, and point of view. What happens if we delete a category associated with a marker? Allowing this could lead to data inconsistency. Before removing an aggregate, it's crucial to analyze the impact with your product manager.

To conclude, the repository pattern is excellent for preventing the coupling of the domain with persistence concerns. It facilitates code evolution by allowing easy switches to different persistence systems and ease testing by isolating the domain from IO usage
