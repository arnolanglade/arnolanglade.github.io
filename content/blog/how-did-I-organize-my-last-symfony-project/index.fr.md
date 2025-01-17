---
title: Symfony, Hexagonal architecture and CQRS
date: 2025-01-20
image_credit: alexkixa
url: hexgonal-architecture-and-cqrs-with-symfony
aliases:
    - "how-did-I-organize-my-last-symfony-project.html"
    - "how-did-I-organize-my-last-symfony-project"
description: "Dans cet article de blog, je vais expliquer comment j'ai organisé mes derniers projets Symfony. Ils sont principalement inspirés par l'architecture Hexagonale et CQRS."
keywords: "software,software architecture,symfony,cqrs,cqrs with symfony,php,hexagonal architecture,hexagonal architecture with symfony,port and adapters"
tags: [software-architecture, symfony]
---

Dans cet article, je vais expliquer comment j’ai organisé mes derniers projets Symfony. J’utilise principalement l’architecture hexagonale et CQRS. Gardez à l’esprit que je ne vise pas à appliquer ces architectures de manière stricte. Je me contente de reprendre les concepts qui m’aident à créer une base de code simple et bien organisée.

Regardons la racine du projet : il n’y a rien de particulièrement inhabituel. J’ai conservé tous les dossiers et fichiers générés lors de l’installation de Symfony.

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

Dans les sections suivantes, nous découvrirons comment j’ai organisé les sources de l’application en utilisant l’architecture hexagonale et comment CQRS m’a aidé à simplifier la modélisation des cas d’utilisation de lecture et d’écriture.

## Mon approche de l'architecture hexagonale

> The hexagonal architecture, or ports and adapters architecture, is an architectural pattern used in software design. It aims at creating loosely coupled application components that can be easily connected to their software environment by means of ports and adapters. This makes components exchangeable at any level and facilitates test automation.
>
> https://en.wikipedia.org/wiki/Hexagonal_architecture_%28software%29

Le principal avantage de l’architecture hexagonale est qu’elle découple le cœur de votre application des [entrées/sorties](https://press.rebus.community/programmingfundamentals/chapter/input-and-output/).

J'appelle le cœur de l'application le `Domaine`. C’est la partie de l’application où se trouve tout le code qui représente le problème que nous résolvons. Cette partie doit être sans effet de bord et ne doit pas dépendre d’outils, de frameworks ou de n’importe quelles technologies.

Les `Sorties` font référence aux outils dont l’application a besoin pour fonctionner, comme les appels réseau, les requêtes à une base de données, les opérations sur le système de fichiers, les “actual timestamps” ou la gestion de choses aléatoires. Toutes les `Sorties` se trouvent dans l'infrastructure. Les `Entrées` font référence à la manière dont le domaine est exposé au monde extérieur, par exemple via un contrôleur web ou une commande CLI. Elles se trouvent dans `UserInterface`.

**Remarque :** Consultez mon article de blog sur l’architecture hexagonale pour approfondir le sujet :  

{{< page-link page="hexagonal-architect-by-example" >}}

Sur cette base, ma première décision a été de diviser le répertoire `src` en trois zones : `Domain`, `Infrastructure` et `UserInterface`.

```bash
tree src/Domain/ -L 1
api/src/Domain/
├── Domain
├── Infrastructure
└── UserInterface
```

**Règles de couplage:**
* `Domain` ne doit **pas** dépendre de `Infrastructure` ni de `UserInterface`.
* `Infrastructure` et '`UserInterface` peuvent dépendre de `Domain`.

Je ne suis pas un grand fan de l’architecture en oignon, car je préfère garder mes projets aussi simples que possible. Avoir de nombreuses couches peut rendre la maintenance difficile, car cela nécessite de mettre toute l’équipe d’accord sur les règles de couplage et d’organisation. Même s’accorder avec soi-même peut être difficile, donc obtenir un consensus à plusieurs est souvent beaucoup plus complexe. Ici, nous suivons une règle simple : `Domain` ne doit **pas** utiliser d'entrées/sorties.

Parfois, j’ai dû créer des librairies parce que je ne trouvais aucune librairie open-source répondant à mes attentes. Pour éviter de coder directement dans le répertoire `vendor`, j’ai introduit une troisième zone appelée `Librairies` (cette zone est optionnelle). Ces librairies peuvent être utilisées à la fois dans les couches `Domain`, `UserInterface` et `Infrastructure`, mais leur utilisation ne doit pas enfreindre les règles de couplage définies pour ces zones.

```bash
tree src/Domain/ -L 1
api/src/Domain/
├── Domain
├── Infrastructure
├── Librairies
└── UserInterface
```

**Règles de couplage :** `Librairies` ne doit **pas** dépendre de `Domain`, `UserInterface` ou de `Infrastructure`.

Enfin, j'ai créé une sous-zone appelée `Application` dans la couche Infrastructure. Elle contient tout le code nécessaire pour que l’application soit opérationnelle, comme le code du framework (le noyau de Symfony et les personnalisations du framework), les data fixtures et les migrations. Dans l’exemple suivant, les dossiers `Exception` et `Security` contiennent des personnalisations du framework.

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

**Remarque :**: Avec le recul, je ne conserverais pas ce dossier dans `Infrastructure`. Tout code lié à la personnalisation du `Framework` devrait aller dans un dossier dédié, appelé framework, situé dans le dossier `Librairies`, tandis que `Fixtures` et `Migrations` peuvent rester à la racine du dossier Infrastructure.

## Se focaliser sur le métier

Un aspect très important pour moi est d’organiser la base de code autour des concepts métiers. J’évite de nommer des dossiers et des classes en fonction de patterns techniques comme  `Entity`, `ValueObject` ou `Repository`, et surtout pas `Provider`, `DataMapper` ou `Form`. Les personnes non techniques doivent pouvoir comprendre l'objectif d'une classe simplement à partir de son nom.

### Domain

```bash
tree src/Domain -L 1
api/src/Domain
├── Cartographer
└── Map
```

Puisque j'ai évité d'utiliser des termes techniques pour nommer les dossiers, il est facile d'imaginer que le projet concerne la création de cartes. Maintenant, jetons un œil à l'intérieur de `Map` :

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

Dans ce dossier, nous avons tout le code nécessaire pour concevoir l'agrégat `Map`. Comme vous pouvez le voir, je ne l'ai pas organisé par design patterns comme `ValueObject`, `Entity, ou autre.

Comme vous l'avez peut-être remarqué, l'entité `Map` a une relation one-to-many avec l'entité `Marker`. Toutes les classes nécessaires pour modéliser cette entité se trouvent dans le dossier `Marker`, qui est organisé de la même manière que le répertoire Map.

Le dossier `UseCase` contient tout le code nécessaire pour orchestrer les cas d'utilisation, tels que les commandes, leurs handlers et les validations métier.

**Astuce :* Je n'ajoute pas le suffixe "Repository" aux dépôts. À la place, j'essaie d'utiliser un concept métier pour le nom, comme `ProductCatalog` pour un agrégat `Product`. Si je ne trouve pas de concept métier adapté, j'utilise la forme plurielle du nom de l'agrégat, car un repository représente une collection d'objets.

J'organise les racines des dossiers `Infrastructure` et `UserInterface` de la même manière que pour le `Domain`.

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
tree src/InterfaceUtilisateur -L 1
api/src/InterfaceUtilisateur
├── …
├── Cartographe
└── Carte
    ├── WebAjouterMarqueur.php
    ├── CliAjouterMarqueur.php
```

## Mon approche de CQRS

> Starting with Command Query Responsibility Segregation, CQRS is simply the creation of two objects where there was previously only one. The separation occurs based upon whether the methods are a command or a query (the same definition that is used by Meyer in Command and Query Separation, a command is any method that mutates state and a query is any method that returns a value).
>
> [Greg Young](https://web.archive.org/web/20190211113420/http://codebetter.com/gregyoung/2010/02/16/cqrs-task-based-uis-event-sourcing-agh/)

L’idée principale du CQRS est la séparation des côtés lecture et écriture. Vous pouvez utiliser des modèles différents pour écrire (commandes) et lire (requêtes). J’apprécie le concept d’avoir deux modèles petits et simples, dédiés à des objectifs spécifiques : lecture ou écriture, plutôt que de s’appuyer sur un seul gros modèle.

De plus, lorsque vous liez des agrégats par leurs identifiants au lieu de références, les cas d'utilisation complexes de lecture peuvent devenir difficiles. Comment récupérer des informations provenant de plusieurs agrégats ? Il est plus simple d'interroger directement la base de données plutôt que de fusionner les données de plusieurs agrégats.

**Remarque :** Consultez mon article de blog pour comprendre la différence entre CQS et CQRS :

{{< page-link page="what-is-the-difference-between-cqs-and-cqrs-patterns" >}}

Pour gérer cela, j'ai décidé de diviser chaque sous-dossier du domaine en deux zones : `Command` et `Query`.

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

**Règles de couplage** `Command` ne doit pas dépendre de `Query` et vice-versa.

**Attention :** Utiliser le CQRS, tel que défini par Greg Young, ne signifie pas introduire une complexité inutile dans votre application. Vous n'avez pas besoin d'un bus de commandes et de requêtes, d'une architecture basée sur l'event sourcing ou de multiples bases de données pour l'appliquer. J'ai choisi de séparer les cas d'utilisation d'écriture et de lecture parce que cela rendait ma base de code plus simple et plus claire.

## Conclusion

Après des années à chercher l’architecture parfaite, j’ai réalisé qu’elle n’existe pas. Je préfère utiliser des concepts architecturaux qui rendent mon travail quotidien et celui de mes coéquipiers plus agréable. Cette organisation a été appliquée à plusieurs projets en production. L’un d’entre eux est un [projet personnel](https://mymaps.world), conçu pour créer des cartes sans dépendre de Google Maps. Les autres sont des projets professionnels utilisés quotidiennement par des utilisateurs.
