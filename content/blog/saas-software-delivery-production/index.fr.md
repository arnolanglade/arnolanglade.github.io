---
title: "Merger du code ne veut pas dire livrer"
date: "2026-05-05"
url: "saas-delivery-logiciel-production"
image_credit: "simonkadula"
description: "Passer au SaaS change le delivery : pourquoi merger du code ne suffit plus et comment livrer en production de manière fiable et régulière."
keywords: "saas delivery logiciel,mise en production logiciel,livraison continue,ci cd logiciel,déploiement logiciel,feedback loop développement,on premise vs saas,livrer en production,cycle de livraison logiciel,engineering delivery"
tags: [software-mindset-series]
---

Au début, on ne se rend pas vraiment compte de ce que le passage au SaaS implique.

Sur le papier, cela ressemble surtout à un changement d’infrastructure. Mais en réalité, c’est un changement beaucoup plus profond. Le mindset évolue, les contraintes changent, et surtout la manière de livrer du logiciel n’est plus la même.

On ne se contente plus de livrer du code. Il faut livrer en production, de manière fiable, et à tout moment.

# Quand livrer n’est pas vraiment livrer

Dans un contexte on-premise, la mise en production est souvent un moment à part.

On prépare une version pendant de longs mois. On la valide, parfois sur plusieurs semaines, puis on la met à disposition des clients et partenaires.

Dans ce modèle, il est possible de travailler longtemps sans réellement livrer en production.

Une pull request mergée peut donner le sentiment que le travail est terminé. Une fois le code sur la branche main, on considère souvent que le travail est fait.

Mais en réalité, la valeur n’existe qu’à partir du moment où le code est en production.

# Le choc du passage au SaaS

Quand une équipe passe à un modèle SaaS, ce fonctionnement ne tient plus.

La production devient le centre du système. Chaque modification peut avoir un impact immédiat sur les utilisateurs.

On ne peut plus attendre des semaines avant de livrer. On ne peut plus se permettre des déploiements risqués. Et surtout, on ne peut plus considérer la mise en production comme une étape secondaire.

Ce changement impose un nouveau mindset.

Merger une pull request ne suffit plus. Ce qui compte, c’est ce qui est réellement en production.

# Une nouvelle manière de travailler

Dans ce contexte, les équipes doivent adapter leur manière de développer.

Les changements doivent être :

* plus petits
* plus fréquents
* plus maîtrisés

Chaque commit doit pouvoir partir en production sans mettre le système en danger.

Cela implique plusieurs choses :

* des tests fiables
* une CI rapide
* un système de déploiement automatisé
* la capacité à revenir en arrière rapidement en cas de problème

Sans ces éléments, livrer devient risqué.
Et si livrer devient risqué, les équipes livrent moins souvent.

# La production comme outil de feedback

Dans un environnement SaaS, la production n’est plus simplement la dernière étape.

Elle devient un outil de feedback.

Les équipes peuvent observer rapidement l’impact de leurs changements, détecter les problèmes plus tôt et corriger plus vite. Le cycle de feedback devient plus court.

C’est souvent ce qui permet d’améliorer la qualité du produit tout en accélérant le delivery.


# Un changement de posture

Passer de on-premise à SaaS, ce n’est pas seulement un changement technique.

C’est un changement de posture.

On ne cherche plus seulement à produire du code correct, mais à livrer régulièrement, en production, de manière fiable.

Le travail n’est plus terminé quand le code est mergé. Il est terminé quand il est en production… et qu’il fonctionne.

# En conclusion

Le passage au SaaS met en lumière un point essentiel.

Ce qui compte, ce n’est pas le code écrit, mais le code qui tourne en production. Et tant qu’un changement n’est pas en production, il ne crée aucune valeur.

Pour y arriver sereinement, il faut adapter toute la manière de travailler : les pratiques, les outils, mais aussi le mindset de l’équipe.

C’est souvent à ce moment-là que les équipes commencent réellement à transformer leur façon de livrer.
