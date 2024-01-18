---
title: Persisting entities without ORM
description: The repository pattern provides a good abstraction to manage object persistence. Even if a lot of projects use an ORM, persisting entities do not necessarily require it.
date: 2021-03-23
image: persisting-entity-without-orm.webp
image_credit: tofi
tags: [design-patterns, OOP, repository]
keywords: "software,oop,repository,design patterns,orm,persistence,sql,database"
---

Today, I will talk about persisting entities without ORM. First, I will introduce the repository pattern because it provides a good abstraction to manage object persistence. Then, we will see what are the impacts on the entity design.

## Repository pattern

The repository design pattern can be used to manage entity persistence and retrieval. It behaves like a collection of objects and hides the complexity of their storage. It ensures a clean separation between the domain model (the entity) and the data model (SQL tables). The following example shows a basic repository interface. Thanks to the `Maps` interface we will be able to add and retrieve Map entities, no matter their storage.

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
}
```

**Caution:** All `Maps` implementations should be tested with the same test because we need to be sure they behave the same way. It ensures the application works no matter the chosen implementation.

Let’s see how we can implement this interface with PostgreSQL for instance. The `get` method is only responsible to get information from the database to build the map entity whereas the `add` method extracts the entity information to store them in the database.

```php
class PostgreSqlMaps implements Maps
{
   private Connection $connection;

   public function __construct(Connection $connection)
   {
       $this->connection = $connection;
   }

   public function get(MapId $mapId): Map
   {
       $sql = <<<SQL
           SELECT map."mapId", map.name
           FROM map
           WHERE map."mapId" = :mapId
       SQL;

       $statement = $this->executeQuery($sql, ['mapId' => (string) $mapId]);

       if (false === $map = $statement->fetchAssociative()) {
           throw UnknownMap::withId($mapId);
       }

       return new Map($map['mapId'], $map['name']);
   }

   public function add(Map $map): void
   {
       $sql = <<<SQL
           INSERT INTO map ("mapId", name)
           VALUES (:mapId, :name)
           ON CONFLICT ("mapId")
           DO UPDATE SET name = :name;
       SQL;

       $this->executeQuery($sql, ['mapId' => $map, 'name' => $map->name()]);
   }

   private function executeQuery(string $sql, array $data): Result
   {
       // Execute query or throw logic exceptions if something goes wrong.
   }
}
```

**Tip:** Thanks to the clause [ON CONFLICT](https://www.postgresql.org/docs/9.5/sql-insert.html) we can easily insert or update data with a single query.

## Entity design impacts

Now we are able to persist and retrieve our map entity. Let's study the impact on entity design.

Let’s start with persistence. In the previous example, I used getters to get its properties but I am not a fan of the getter to be honest! Getters break data encapsulation because they expose object implementation details. They don’t follow the [Tell don’t ask](https://www.martinfowler.com/bliki/TellDontAsk.html) principle because we should not ask about the object state to do something, we should tell the object to do something for us. I like adding a `toState` method that is responsible to turn the entity into an associative array.

```php
final class Map
{
   public function toState(): array
   {
      return [
          'mapId' => (string) $this->mapId,
          'name' => (string) $this->name,
      ];
   }
}
```

So I just need to call the `toState` method instead of getters, this method returns data expected by the `executeQuery` method.

```php
class PostgreSqlMaps implements Maps
{
   // ...
   public function add(Map $map): void
   {
       // ...
       $this->executeQuery($sql, $map->toState());
   }
   // ...
}
```

Let’s continue with retrieval. If we have a look at the `Map`constructor method we can see that a `MapInitialized` event is recorded there. Houston, we have a problem! When we build an entity from its state (data stored somewhere) we don’t want to record any event because nothing happens. So, we need to find a solution to avoid recording those events.

```php
public function __construct(
   MapId $mapId,
   MapName $name
) {
   $this->mapId = $mapId;
   $this->name = $name;

   $this->recordEvent(new MapInitialized(
       $mapId,
       $name
   ));
}
```

I like adding a named constructor called `fromState` to the entity. This constructor is responsible for building the aggregate from the state. Moreover, named constructors are explicit and give developers information about when to use them. In the following example, after calling the [primary constructor](https://arnolanglade.github.io/build-object-using-php.html) we call the `eraseRecordedEvents` method to reset events before returning the object in the right state.


```php
public static function fromState(array $state): self
{
   $map = new self(
       new MapId($state['mapId']),
       new MapName($state['name'])
   );

   $map->eraseRecordedEvents();

   return $map;
}
```

So, the only change in the repository is to build the `Map` entity from the named constructor.

```php
class PostgreSqlMaps implements Maps
{

   public function get(MapId $mapId): Map
   {
       // ...

       return Map::fromState($map);
   }
}
```

## Last word

I did a presentation about the repository design pattern at the Forum PHP in 2018. A video is only available in French [here](https://www.youtube.com/watch?v=cYFKkhtIr8w&ab_channel=AFUPPHP) but the slides are in English [here](https://arnolanglade.gitlab.io/bad-or-good-repository/) (press “s” to display English notes). Even if this presentation was made for Doctrine ORM it gives a lot of information about the pattern.

**Note:** In this talk I spoke about generating the entity identity by the repository. To be honest, I stopped doing that because generating it from controllers is easier and makes the repository design simpler.

Thanks to my proofreader [@LaureBrosseau](https://www.linkedin.com/in/laurebrosseau).
