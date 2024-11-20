---
title: Le design pattern Command Bus
date: 2024-11-25
image_credit: rockstaar_
url: command-bus-design-pattern
aliases:
    - "command-bus-design-pattern.html"
description: "Explorez le design pattern de bus de commande (command bus) : un guide complet pour comprendre son rôle dans l'architecture logicielle, ses avantages et comment il fonctionne avec le bus d'événements (event bus) pour rendre votre application plus modulaire et évolutive"
keywords:  "command bus design pattern,event bus design pattern,software architecture,command bus,event bus,middleware design pattern,bus de command, bus d'évènement,middleware en conception logicielle,gestion des commandes et des événements"
tags: [command-bus, design-patterns, software-architecture]
---

## Qu'est-ce qu'un bus ?

Commençons par les bases, qu'est-ce qu'un bus ? En informatique, un bus est un système qui connecte plusieurs composants et facilite le transfert de données entre eux. Dans le contexte logiciel, ces composants sont appelés middleware. Un middleware reçoit une requête, la traite, puis renvoie une réponse. Comme illustré dans le schéma ci-dessous, le principal avantage de l'utilisation d'un bus est qu’il est facilement personnalisable. Vous pouvez ajouter autant de middlewares que nécessaire.

{{< image src="bus.png" alt="A bus" >}}

Dans les sections suivantes, j'expliquerai ce qu'est le bus de commande (command bus), qui est souvent associé à un bus d'événement (event bus). Bien que l'utilisation d'un bus d'événement ne soit pas obligatoire, nous verrons comment cela améliore la modularité des applications et les rend plus facile à faire évoluer. Le but de ces bus est de router une commande ou un événement vers le(s) gestionnaire(s) approprié(s) (handler). Les événements et les commandes sont des objets conçus pour encapsuler les informations nécessaires pour effectuer une action (une commande) ou pour informer de ce qui s'est produit au sein du système (un événement).

## Le bus de commande (Command Bus)

**Rappel rapide sur le Command & Command Handler :** Une commande représente l'intention d'un utilisateur. Les données portées par la commande doivent être valides. Elle doit être traitée par un seul handler, qui est un “callable” qui effectue toutes les actions nécessaires pour valider le cas d'utilisation.

**Remarque :** Je vous recommande l'article de blog que j'ai écrit sur ces design patterns si vous n'êtes pas familier avec eux. Cela vous aidera à comprendre la suite de cet article :

{{< page-link page="command-handler-patterns" >}}

Maintenant, nous allons construire un bus de commande avec l'architecture décrite dans la section précédente. La seule différence est que le bus de commande retournera void. Comme les commandes peuvent être traitées de manière asynchrone, nous ne pouvons pas prévoir quand le traitement sera terminé donc ne pouvons pas attendre de résultat de la part du bus de commande.

{{< image src="command-bus.png" alt="A command bus" >}}

Regardons les middleware les plus couramment utilisés dans la construction d'un bus de commande. Le plus utilisé et probablement le plus utile est le 'middleware de logging'. Ce middleware rend votre application observable et facilite à la fois le débogage et la chasse aux bugs.

Le 'middleware de validation' assure la validité de la commande avant de la passer au handler et bloque son exécution si les données sont invalides. Cet middleware est assez utile car il évite une validation de la commande manuelle.

{{< training-link >}}

Lorsque votre application utilise une base de données, le 'middleware de transaction' exécute le handler au sein d'une transaction SQL pour s'assurer que toutes les modifications sont correctement enregistrées en base de données. En cas d'erreur, la transaction est annulée.

Enfin, le ‘middleware de recherche de handler’ joue le rôle d'identifier et d'exécuter le handler approprié pour la commande.

## Le bus d'événement (Event Bus)

Un événement correspond à un fait qui s'est produit dans l'application. À la différence d'une commande, un événement peut être pris en charge par plusieurs handlers. Grâce aux événements, il est facile d'améliorer les fonctionnalités existantes ou d'en créer de nouvelles. Les équipes peuvent observer ce qui se passe dans le système et agir en fonction des besoins. Cette approche facilite l'évolution de l'application sans ajouter de complexité accidentelle tout en offrant aux équipes la possibilité de travailler de manière autonome.


**Astuce :** Je vous encourage à vous concentrer principalement sur les événements orientés métier plutôt que sur les événements techniques. Les événements orientés métier fournissent une description claire de ce qui s'est passé du point de vue du métier. Par exemple, `NewAccountHasBeenCreated` est bien plus intuitif que `ResourceCreated` avec une propriété de ressource définie sur 'Compte'.

Même si le bus d'événements est conçu de manière similaire au bus de commandes, tous les middlewares ne sont pas indispensables. Par exemple, le middleware de validation n’est pas nécessaire, car les événements sont générés par des agrégats. Ces agrégats garantissent les invariants (règles métier), ce qui signifie que les événements sont toujours créés avec des données valides.

Le middleware transactionnel n'est pas indispensable, car les événements peuvent être pris en charge dans la transaction ouverte lors du traitement de la commande (cela dépend aussi de la configuration de votre bus). Toutefois, selon vos besoins métiers, vous pourriez choisir de traiter les événements en dehors de cette transaction.  Considérons un scénario simple : Après la création d'un compte, un événement `AccountCreated` est dispatché, suivi de l'envoi d'un email de bienvenue lors du traitement de l'événement `AccountCreated`. Si l'envoi de l’email échoue, devrions-nous annuler la création du compte ? Pas sûr ! Dans ce cas, vous devez discuter avec votre chef de produit pour décider comment traiter cet événement.

Maintenant, je vais partager avec vous deux méthodes pour dispatcher des événements dans le bus d'événement.

{{< image src="event-bus.png" alt="A event bus" >}}

**Solution 1:** Les événements peuvent être collectés à partir de votre repository. Si aucune erreur ne s'est produite pendant la persistance de l'agrégat, ils peuvent ensuite être dispatchés.

**Solution 2:** L'autre solution consiste à collecter les événements à partir du command handler. Le handler peut les retourner, puis le middleware ‘middleware de recherche de handler’ les récupère et les dispatche.

Comme je l'ai expliqué plus tôt, un événement informe quelque chose qui s’est passé au sein de l'application. Les événements doivent être dispatchés à la fin de la transaction. Vous ne devriez pas les dispatcher tant que la transaction n’est pas fini parce que si quelque chose tourne mal, vous dispatcherez des événements qui n'ont pas de sens. Pour illustrer ce que je viens de dire, prenons le même exemple qu'auparavant : la création de compte. Si vous dispatchez un événement `AccountCreated` avant que la transaction soit validée et qu'une erreur survient après que l'événement a été dispatché, vous enverrez un email aux utilisateurs, mais ils n'auront pas de compte.


**Note:** Dans mon précédent [article de blog](https://www.arnaudlanglade.com/fr/command-handler-patterns/) sur le pattern des commandes et des command handlers, j'ai dis qu'un command handler devait retourner void. L'idée ici est que seul le bus de commandes doit retourner void. Seul le “handler finder middleware” doit être conscient du résultat de l'exécution du handler.

J'ai écrit plusieurs articles sur comment gérer une commande, valider ses données, gérer les permissions des utilisateurs, etc. Jetez un œil à ces articles :

{{< page-link page="tags/command-bus/" >}}

