---
title: "Construire moins pour livrer mieux : le vrai coût des fonctionnalités inutiles"
date: "2026-04-14"
url: "fonctionnalites-inutiles-complexite-logiciel"
image_credit: "glencarrie"
description: "Les fonctionnalités inutiles peuvent ralentir toute une équipe. Découvrez comment la complexité produit s’accumule et pourquoi comprendre le besoin est essentiel."
keywords: "fonctionnalités inutiles,complexité logiciel,dette fonctionnelle,complexité produit,delivery logiciel,architecture logiciel,comprendre le besoin utilisateur,pourquoi trop de fonctionnalités ralentissent un produit,complexité logiciel et fonctionnalités inutiles,comment éviter de développer des fonctionnalités inutiles,comprendre le besoin avant de coder,réduire la complexité d’un logiciel,Event Storming,Example Mapping,complexité technique,dette technique,feature creep,product engineering,delivery software,"
tags: [software-mindset-series]
---


Quand un produit grandit, les équipes pensent souvent que leur problème vient de la complexité technique.

On accuse souvent la dette technique, la complexité du code ou le manque de tests.

Mais il existe une autre cause, plus discrète.

Certaines fonctionnalités n’apportent presque aucune valeur…
mais elles continuent pourtant à peser sur tout le système.

Avec le temps, j’ai réalisé que ce ne sont pas forcément les fonctionnalités les plus complexes qui posent problème.

Ce sont souvent celles qui n’auraient peut-être jamais dû être développées.

## Une fonctionnalité inutile peut coûter très cher

Sur un projet, je suis arrivé dans une équipe qui maintenait un logiciel déjà en production.

Parmi les nombreuses fonctionnalités du produit, il y en avait une qui semblait importante. Elle avait été développée avant mon arrivée et faisait partie du système depuis plusieurs années.

Mais au fil des échanges avec les équipes commerciales et le support, un constat revenait régulièrement : très peu de clients l’utilisaient vraiment.

Certains ne la comprenaient pas. D’autres ne voyaient tout simplement pas l’intérêt de l’utiliser.

Le problème, c’est que cette fonctionnalité n’était pas isolée.

Elle était couplée au core domain, la partie du système qui apportait réellement de la valeur aux clients et générait du revenu.

Chaque évolution du métier nous obligeait à vérifier si cette fonctionnalité allait être impactée.

Elle n’apportait presque rien mais elle ralentissait toutes les évolutions.

On pourrait se dire qu’il suffit de la supprimer.

Mais dans la réalité, supprimer une fonctionnalité est rarement une décision simple.

Elle est peut-être utilisée par quelques clients.
Elle apparaît peut-être dans la documentation.
Elle a peut-être même été vendue dans certaines offres.

La supprimer devient souvent une décision difficile à prendre.

Tout le monde n’a pas la capacité de Google à supprimer des produits entiers du jour au lendemain.

Alors la fonctionnalité reste.

Et petit à petit, elle devient une contrainte supplémentaire pour l’équipe.

**Une fonctionnalité inutile n’est jamais gratuite.
Elle ajoute de la complexité, même si personne ne l’utilise.**

## Une fonctionnalité en production ne disparaît jamais vraiment

On sous-estime souvent une chose : une fonctionnalité ne s’arrête pas le jour où elle est livrée.

Une fois en production, elle doit être :

* maintenue
* testée
* prise en compte dans les évolutions futures
* comprise par les nouveaux développeurs

Chaque nouvelle feature doit cohabiter avec les anciennes.

Petit à petit, le système devient plus difficile à faire évoluer.

C’est ce qu’on appelle souvent la dette technique, mais il existe aussi une autre forme de dette : la dette fonctionnelle.

Des fonctionnalités peu utilisées qui continuent pourtant à peser sur le système.

## Toutes les fonctionnalités ne méritent pas d’être complexes

Quand une équipe passe plusieurs semaines à développer une fonctionnalité très aboutie, elle prend un risque.

Celui de construire quelque chose de complexe… pour un besoin qui n’existe peut-être pas. Plus une fonctionnalité est complexe, plus elle sera coûteuse à maintenir.

C’est pour ça que je préfère commencer par une version simple. Une version qui permet de valider l’idée, d’observer l’usage et d’apprendre.

Si la fonctionnalité est utile, on pourra l’améliorer.

Si elle ne l’est pas, on aura perdu beaucoup moins de temps.

## Le vrai problème n’est pas technique

Dans la plupart des cas, le problème n’est pas la qualité du code.

Il vient plutôt d’un manque de compréhension du besoin.

Quand une équipe développe une solution avant d’avoir bien compris le problème, elle prend le risque de construire quelque chose d’inutile.

Et une fonctionnalité inutile est rarement neutre.

Elle augmente la complexité du système.
Elle ralentit les évolutions futures.
Et elle finit par peser sur toute l’équipe.

## Comprendre avant de construire

Avec le temps, j’ai appris qu’il vaut mieux investir du temps avant d’écrire du code.

Comprendre le métier. Comprendre les besoins. Et surtout développer de l’empathie pour les utilisateurs.

Des ateliers comme Event Storming ou Example Mapping sont très utiles pour ça.

Ils permettent d’aligner les équipes produit et techniques sur ce que l’on veut réellement construire.

Et souvent, ils révèlent que la solution imaginée au départ n’est pas la bonne.

## Construire moins pour livrer mieux

Une équipe ne ralentit pas seulement à cause de la dette technique.

Avec le temps, la complexité du système augmente.
Complexité technique, fonctionnelle, mais aussi organisationnelle.

Plus le produit grandit, plus il y a de fonctionnalités, de cas particuliers, d’intégrations, d’équipes impliquées.

C’est souvent un bon signe : cela veut dire que le produit est utilisé et que l’entreprise se développe.

Mais cette croissance a un coût.

Chaque nouvelle fonctionnalité ajoute un peu plus de complexité au système. Et petit à petit, faire évoluer le logiciel devient plus difficile.

Dans ce contexte, la question la plus importante n’est pas seulement : **“Comment allons-nous construire cette fonctionnalité ?”**

Mais plutôt : **“Est-ce qu’on doit vraiment la construire ?”**

Comprendre le métier, les objectifs business de l’entreprise et se mettre à la place des personnes qui vont utiliser le logiciel devient alors essentiel.

Parce qu’avant de réfléchir à la solution il faut surtout s’assurer que l’on résout le bon problème.

**Construire moins, mais construire les bonnes choses, est souvent le moyen le plus sûr de livrer mieux.**
