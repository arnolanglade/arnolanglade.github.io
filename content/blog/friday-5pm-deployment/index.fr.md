---
title: "Le déploiement du vendredi 17h : pourquoi les grosses releases sont risquées"
date: "2026-04-21"
url: "deploiement-vendredi-17h"
image_credit: "sincerelymedia"
description: "Pourquoi attendre avant de déployer augmente le risque. Retour d’expérience sur un déploiement un vendredi 17h et l’importance de livrer souvent."
keywords: "déploiement logiciel,mise en production,continuous delivery,livrer souvent,déploiement en production,risque en production,déploiement logiciel équipe,release logiciel,delivery software,"
tags: [software-mindset-series]
---

Il y a quelques années, j’ai attendu deux semaines avant de déployer une fonctionnalité.

Deux semaines de travail.
Deux semaines de commits.
Deux semaines sans mise en production.

Tout semblait prêt.

C’était un vendredi, vers 17h.
Confiant, j’ai déclenché le déploiement.

Quelques minutes plus tard, la production ne fonctionnait plus.

Grosse régression.
Grosse pression.

Il a fallu comprendre ce qui s’était passé et réparer le système en urgence.

Avec le recul, ce n’était pas vraiment une surprise. 
Pendant deux semaines, nous avions travaillé en mode tunnel, concentrés sur l’objectif de terminer la fonctionnalité.

Dans ce contexte, on pense surtout à finir… pas à livrer par petits incréments.

## Le problème des grosses mises en production

Quand on attend trop longtemps avant de livrer, les changements s’accumulent.

Une fonctionnalité devient plusieurs fonctionnalités.
Quelques commits deviennent des dizaines.
Une simple modification devient un ensemble de changements difficiles à comprendre.

Et quand quelque chose casse en production, tout devient plus compliqué.

Il faut analyser beaucoup plus de code.
Comprendre ce qui a changé devient plus difficile.
Trouver l’origine du problème prend du temps.

Plus une mise en production est grosse, plus elle est risquée.

## Livrer petit pour apprendre vite

À l’inverse, quand on livre souvent, chaque mise en production contient peu de changements.

Si un problème apparaît, il est beaucoup plus facile de comprendre d’où il vient.

On sait que l’erreur se trouve probablement dans les derniers commits.

Et surtout, on peut corriger rapidement.

C’est pour ça que j’essaie de livrer le plus souvent possible.

Pas forcément des fonctionnalités complètes.
Mais des incréments stables.

Des petites évolutions qui peuvent partir en production à tout moment.

## Une production qui devient un outil de feedback

Quand une équipe livre rarement, la production devient un endroit un peu stressant.

On hésite à déployer.
On attend le bon moment.
On accumule les changements.

À l’inverse, quand les mises en production sont fréquentes, la production devient simplement une étape normale du travail.

Les développeurs savent que leurs changements peuvent être déployés rapidement.

Les problèmes sont détectés plus tôt.

Et l’équipe gagne en confiance.

## Un changement de mindset

Dans certaines équipes, merger une pull request est déjà perçu comme une réussite.

Mais en réalité, une fonctionnalité n’existe vraiment que lorsqu’elle est en production.

C’est un changement de perspective important.

Le code dans un repository ne crée pas de valeur. Seul le code en production peut en créer.

## Livrer pour réduire le risque

On pense souvent que livrer souvent est risqué.

En réalité, c’est l’inverse.

Les grosses mises en production sont beaucoup plus dangereuses.

Parce qu’elles concentrent trop de changements en même temps.

Livrer régulièrement permet au contraire de réduire le risque.

Chaque déploiement devient plus petit.
Plus simple à comprendre.
Plus simple à corriger.

Et petit à petit, la mise en production cesse d’être un moment de stress.

Elle devient simplement une habitude.
