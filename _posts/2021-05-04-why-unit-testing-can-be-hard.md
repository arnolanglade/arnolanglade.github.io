---
title: Why unit testing can be hard?
permalink: /:title:output_ext
description: Testing can be really difficult for beginners. The main reason is that your code probably uses IO. This blog post gives you tips about improving your code design to ease testing.
layout: post
date: 2021-05-03
image: why-unit-testing-can-be-hard.jpg
alt: Why unit testing can be hard?
tags: [php, oop, testing]
related_posts: ["Why you should not expose objects' state to test them"]
---

# Why unit testing can be hard?

![Why unit testing can be hard?](assets/img/posts/why-unit-testing-can-be-hard.jpg)
[@craftedbygc](https://unsplash.com/@craftedbygc)

> Unit tests are typically automated tests written and run by software developers to ensure that a section of an application (known as the "unit") meets its design and behaves as intended
>
> [Wikipedia](https://en.wikipedia.org/wiki/Unit_testing)

I remember when I started to test my code it was really hard! It was mainly because I misunderstood some basics like what testing was about and the need of well-designed code. Unit tests ensure your code works as expected, but we often forget that unit testing is also the simplest way to have quick feedback during development phase.

In this blog post, I will share what I learned to easily unit test my codebases.

## Test your public methods

Objects should be seen as black boxes. Public methods are the only way to interact with objects, while private and protected methods are implementation details. We should not pay attention to how objects work internally. That’s why we don’t test private and protected methods. If you need to test them, that's a design smell! Your objects might do too many things and they probably do not respect the **S**ingle **R**esponsibility **P**rinciple.

> The single-responsibility principle (SRP) is a computer-programming principle that states that every class in a computer program should have responsibility over a single part of that program's functionality, which it should encapsulate.
>
> [Wikipedia](https://en.wikipedia.org/wiki/Single-responsibility_principle)

Actually, it is better to have several small objects solving simple problems instead of having god objects that are doing everything the wrong way. If your objects become too big, split them into smaller ones because they are easier to maintain and to test.

## Do not unit test code that uses IOs

> Input/output (I/O, or informally io or IO) is the communication between an information processing system, such as a computer, and the outside world, possibly a human or another information processing system.
>
> [Wikipedia](https://press.rebus.community/programmingfundamentals/chapter/input-and-output/)
k
For example, IO are side effects like: network calls, database queries, filesystem operations, actual timestamps or randomness.

### Do not deal with the outside

The code covered by unit tests should not depend on the outside world like databases, external services and so on. Unit tests should not require any application setup, they have to remain as simple as possible. Their goal is to give you quick feedback by checking that a small piece of code (a unit) matches a business expectation. If you want to be sure that all application parts are well integrated with the outside world, you have to use an integration test.

The following example shows a piece of code that depends on the external service. Here, we can’t build the `Map` object without a working database.

```php
final class HandleMarkerAddition
{
   private Connection $connection;

   public function __construct(Connection $connection)
   {
       $this->connection = $connection;
   }

   public function __invoke(AddMarkerToMap $command): void
   {
       $mapState = $this->connection->executeQuery('SELECT ... FROM ...', [$command->mapId()]);

       $map = Map::fromState($mapState);
       $map->addMarker($command->name(), $command->location());

       $this->connection->executeQuery('INSERT INTO ...', $map->toState()]);
   }
}
```

The goal of this piece of code is to add a marker to a `Map` object, no matter how the object is stored. Tests that cover this class should focus on business use cases instead of technical details. A solution would be to use a repository design pattern to hide the map storage logic. The class will better follow the **S**ingle **R**esponsable **P**rinciple because it will only handle the marker addition use case whereas the map repository will be in charge of storing data.

```php
final class HandleMarkerAddition
{
   private Maps $maps;

   public function __construct(Maps $maps)
   {
       $this->maps = $maps;
   }

   public function __invoke(AddMarkerToMap $command): void
   {
       $map = $this->maps->get($command->mapId());
       $map->addMarker($command->name(), $command->location());

       $this->maps->add($map);
   }
}
```

With this new design, it is easier to test this class. Thanks to the `Maps` interface , we are able to simply create test doubles for the map repository.

```php
// `PostgreSQLMaps` is the implementation used by default on the production
$maps = new PostgreSQLMaps();
(new HandleMarkerAddition($postgreSQLMaps)($command);

// `InMemoryMaps` is an implementation that keeps map objects in memory for testing 
$maps = new InMemoryMaps();
(new HandleMarkerAddition($inMemoryMaps)($command);

// In both cases we can retrieve the Map object from the repository to check the map has the new marker.
$map = $maps->get($command->mapId());
$map->hasSameState(new Map('Best place', new Marker(/* … */))) // should return true;

```

### Do not deal with randomness

Randomness makes your code unpredictable. To simply test a piece of code you should be able to predict its result. To ease unit testing your code should avoid using randomness as much as possible.

The following example shows a piece of code that uses randomness.

```php
final class HashedPassword
{
   // ... 

   public function __construct(string $hash)
   {
       $this->hash = $hash;
   }


   public static function fromString(string $password): self
   {
       $hash = \password_hash($password, PASSWORD_BCRYPT);

       return new self($hash);
   }

   // ...
}

class HashedPasswordTest extends TestCase
{
    /** @test */
    function it builds a password from a string()
    {
        $this->assertEquals(
            $this::fromString('Password1'),
            new HashedPassword('$2y$10$JqfiXNdcuWErfiy5pAJ4O.wKsfic14RsVnVbP/rsdMJJyA9Hg9RCu')
        );
    }
}
```

When we run `HashedPasswordTest` we get an error because the `password_hash` generates a random salt to hash the password. The problem is that the `password_hash` function cannot return the same hash for a given password. Each time you call this function a different hash will be returned.

```bash
-Password Object &000000006e7168e60000000023b11bb2 (
-    'hash' => '$2y$10$JqfiXNdcuWErfiy5pAJ4O.wKsfic14RsVnVbP/rsdMJJyA9Hg9RCu'
+Password Object &000000006e7168210000000023b11bb2 (
+    'hash' => '$2y$10$b/9GX4grnt4gH5cm8FzzSuUNGGQUiA/w.5HdKNEsW3dHtSUeTMXgK'
```

The simplest solution would be to hardcode the salt to make sure the `hash_password` returns the same hash every time but this is not a good design. This would weaken the password generation because we need to test it. Another way would be to extract the hash generation in another place.


```php
final class HashedPassword
{
   // ...
   public static function fromString(string $password, PasswordEncryptor $passwordEncryptor): self
   {
       $hash = $passwordEncryptor->hash($password);

       return new self($hash);
   }
   // ...
}
```

The `PasswordEncryptor` interface makes test doubles creation possible. Now, we just need to create a fake object to test this method.

```php
final class FakePawssordEncryptor implements PasswordEncryptor
{
    public function hash(): string
    {
        return '$2y$10$JqfiXNdcuWErfiy5pAJ4O.wKsfic14RsVnVbP/rsdMJJyA9Hg9RCu';
    }

}

class HashedPasswordTest extends TestCase
{
   /** @test */
   function it builds a password from a string()
   {
        $fakePasswordEncryptor = new FakePasswordEncryptor();

        $this->assertEquals(
            this::fromString('Password1', $fakePasswordEncryptor),
            new HashedPassword('$2y$10$JqfiXNdcuWErfiy5pAJ4O.wKsfic14RsVnVbP/rsdMJJyA9Hg9RCu')
        );
   }
}
```

### Avoid actual datetimes

With actual datetimes, we have the same problem as with randomness, neither can be predicted.

The following example shows you that actual datetimes are not predictable like `hash_password` in the previous section.

```php
final class Map
{
   // ...
   public function __construct(\DateTimeImmutable $markerAddedAt = null, Marker ...$makers)
   {
       // ...
   }

   public function addMarker(string $name, array $location): void
   {
       // ...
       $this->markerAddedAt = new \DateTimeImmutable('now');
   }
}

class MapTest extends TestCase
{
    /** @test */
    function it adds marker to the map()
    {
        $map = new Map('Map name');
        $map->addMarker('Bubar', [47.21725, -1.55336]);
        
        $this->assetTrue(
            $map->hasSameState(
                new Map(
                    new Marker('Bubar', [47.21725, -1.55336]), 
                    new \DateTimeImmutable('now')
                )
            )
        );
    }
}
```

When we run `MapTest` we get an error because we can predict to the millisecond when the marker was added to the map.

```bash
-Map Object &000000003acad975000000006b83e943 ()
+Map Object &000000003acad936000000006b83e943 (
+    'markerAddedAt' => DateTimeImmutable Object &000000003acad946000000006b83e943 (
+        'date' => '2021-04-18 17:36:02.919004'
+        'timezone_type' => 3
+        'timezone' => 'UTC'
+    )
+)
```

To prevent this kind of problem, a good idea is to abstract time by introducing an interface that is responsible for time management.

```php
final class Map
{
  // ...
  public function addMarker(string $name, array $location, Clock $clock): void
  {
      // ...
      $this->markerAddedAt = new $clock->now();
  }
   // ...
}
```

Now, thanks to the `Clock` interface we will be able to create test doubles and easily test this method.

## Coupling might be your worst enemy

> Coupling is the degree of interdependence between software modules; a measure of how closely connected two routines or modules are; the strength of the relationships between modules.
>
> [Wikipedia](https://en.wikipedia.org/wiki/Coupling_(computer_programming))

As you have seen in the previous sections, objects should depend on abstractions instead of concrete implementations. Abstractions (e.g. interfaces) ease testing because your code is more modular. You can use test doubles to reduce the complexity and facilitate testing. Their goal is to mimic the behavior of real objects to replace a subpart of an algorithm.

The following example shows that hardcoding object dependencies won’t help to create test doubles.

```php
class MyClass
{
   public function __construct(ConcreteImplementation $concreteImplementation)
   {
       // Here we can only use these concrete implementations, if they use IO for instance you won't be able to test it.
       $this->concreteImplementation = $concreteImplementation;
       $this->anotherConcreteImplementation = new AnotherConcreteImplementation();
      
       // Singleton pattern does not help because it hides object dependencies and makes them hard coded.
       $this->connection = Connection::getInstance();
   }
}
```

The solution is to use the dependency inversion pattern to remove hard coded dependencies introducing abstractions as much as possible.

> High-level modules should not depend on low-level modules. Both should depend on abstractions (e.g., interfaces). Abstractions should not depend on details. Details (concrete implementations) should depend on abstractions.
>
> [Wikipedia](https://en.wikipedia.org/wiki/Dependency_inversion_principle)

In the following example, all class dependencies are interchangeable. So, you can easily create test doubles like fake, stub, or mocks to make sure your objects meet business expectations.

```php
class MyClass
{
   public function __construct(
       ImplementationInterface $concreteImplementation,
       AnoherImplementationInterface $anotherConcreteImplementation,
       ConnectionInterface $connection
   ) {
       $this->concreteImplementation = $concreteImplementation;
       $this->anotherConcreteImplementation = $anotherConcreteImplementation;
       $this->connection = $connection;
   }
}
```

**Caution:** That does not mean you should use interfaces everywhere! Knowing when to introduce new abstractions might be hard at the beginning, there is no magic recipe!

Thanks to my proofreaders [@LaureBrosseau](https://twitter.com/LaureBrosseau) and [@jjanvier_](https://twitter.com/jjanvier_).
