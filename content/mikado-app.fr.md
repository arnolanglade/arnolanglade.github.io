---
title: "La MikadoApp"
slug: "mikado-app"
aliases:
  - "mikadao-app"
description: "La MikadoApp est un outil open source pour simplifier la création et le partage du graphe Mikado"
image:
  src: "project/mikado-game.png"
  alt: "Jeu du Mikado"
menus:
  main:
    name: "MikadoApp"
    weight: 5
  footer:
    name: "MikadoApp"
---

## La méthode Mikado

La méthode Mikado tire son nom du jeu du Mikado, où l'objectif est de retirer des bâtonnets sans faire bouger les autres. La méthode Mikado a la même philosophie. Elle vise à apporter de petites améliorations incrémentales à un projet sans casser la base de code existante.

Ola Ellnestam et Daniel Brolund ont développé la méthode Mikado en s'appuyant sur leur expérience dans la résolution de la dette technique dans des systèmes legacy complexes. Ils ont publié un livre intitulé [The Mikado Method](https://www.manning.com/books/the-mikado-method)

Cette méthode simplifie le refactoring. Vous pouvez améliorer continuellement votre base de code au lieu d'empiler beaucoup de changements qui ne peuvent pas être mergés parce que les suites de tests sont cassées. Il vaut mieux merger régulièrement de petits changements qui améliorent la qualité de votre base de code. Cette méthode est idéale pour le développement brownfield. Elle vous permet d'ajouter de nouvelles fonctionnalités ou de modifier les existantes sans casser le reste de l'application. De plus, elle facilite l'amélioration de l'architecture de l'application tout en permettant la livraison de nouvelles fonctionnalités en parallèle.

Pour plus d'informations, jetez un œil à mon article de blog sur la [Méthode Mikado](/mikado-method.html)

## Essayez la MikadoApp

Essayez l'application Mikado en ligne. Pour le moment, je n'utilise que le plan gratuit de Vercel, ce qui signifie que l'application peut être lente.

{{<external-link href="https://mikado-method-teal.vercel.app" label="Essayez l'appli Mikado" >}}

Ce projet est open source, alors n'hésitez pas à contribuer à l'application pour l'améliorer ! Soumettez une issue pour les bugs et partagez vos idées pour améliorer l'application. Les pull requests sont également très bienvenues. Le code source est disponible sur
GitHub.

{{<external-link href="https://github.com/arnolanglade/mikado-app" label="Sources sur GitHub" >}}

## Comment utiliser la MikadoApp

Prenons un exemple : MySQL ne correspond pas aux besoins du projet ; vous voulez migrer votre application vers PostgreSQL.

Sur la page d'accueil de l'appli Mikado, entrez votre objectif. Expliquez ce que vous voulez faire et cliquez sur le bouton « Start » pour commencer à travailler.

{{< asset-image src="/project/mikado-app/describe-objective.png" alt="Décrire l'objectif" >}}

Ensuite, vous arrivez sur la page du graphie Mikado. Vous pouvez diviser votre objectif en petites étapes appelées prérequis. Pour réaliser la migration de la base de données, nous devons d'abord installer la base de données et mettre à jour les repositories à cause de l'utilisation de requêtes SQL spécifiques à MySQL.

Cliquez sur le bouton 'Add a prerequisite' pour ouvrir le formulaire d'ajout de prérequis. Ensuite, décrivez les actions requises pour compléter le prérequis. Enfin, cliquez sur le bouton « Add » pour ajouter le prérequis au Graphe Mikado :

{{< asset-image src="/project/mikado-app/add-prerequisite.png" alt="Ajouter un nouveau prérequis" >}}

Vous pouvez créer autant de prérequis que vous le souhaitez. N'oubliez pas que les petites étapes sont plus faciles à réaliser ! Comme vous pouvez le voir dans la capture d'écran suivante, la bulle du prérequis a un fond orange, indiquant que les prérequis ont le statut « À faire » :

{{< asset-image src="/project/mikado-app/prerequisite-list.png" alt="Liste des prérequis" >}}

Après avoir ajouté des prérequis, sélectionnez-en un dans la liste et cliquez sur le bouton « Start exploring » pour commencer à expérimenter des choses pour le résoudre. La couleur de fond du prérequis change en bleu, indiquant que le statut du prérequis est maintenant « En expérimentation », ce qui signifie que vous travaillez activement dessus.

Maintenant, vous avez deux choix : le premier est de cliquer sur le bouton « Add a prerequisite » pour diviser le prérequis en étapes plus petites.

{{< asset-image src="/project/mikado-app/prequisite-buble.png" alt="Node du prérequis dans le graphe" >}}

La deuxième option est de cliquer sur « Commit your changes » lorsque vous avez terminé et de passer au suivant sur la liste.

{{< asset-image src="/project/mikado-app/prerequisite-completed.png" alt="Le prérequis is fini" >}}

Continuez à résoudre tous les prérequis jusqu'à la fin. Lorsque tous les prérequis sont terminés, votre objectif est atteint !

{{< asset-image src="/project/mikado-app/objective-completed.png" alt="L'objectif est fini" class="mb-0" >}}
