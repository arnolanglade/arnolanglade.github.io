---
title: Développer avec le Sylius ResourceBundle
conference:
  title: Symfony live Paris 2015
  link: https://live.symfony.com/2015-paris
description: "Conférence à Symfony Live Paris : je présente le ResourceBundle qui facilite le CRUD pour les applications Symfony."
abstract: "Au cours de son développement Sylius, l'équipe s’est rendu compte qu’elle dupliquait énormément de code pour gérer ses CRUDs. Ne voulant pas réinventer Symfony ou utiliser un admin generator, elle décida de créer un bundle simple et flexible: SyliusResourceBundle. Je présenterai comment gérer ses CRUDs avec ce bundle en écrivant le minimum de code et, surtout, sans en dupliquer! Il a été pensé afin de pouvoir supporter plusieurs types de drivers (DoctrineORM, PHPCR). De plus, il permet de construire rapidement une API grâce au FOSTRestBundle. Je mettrai en avant l’ensemble des composants utilisés par ce bundle comme Doctrine. Il facilite la configuration le ResolveDoctrineTargetEntitiesPass ainsi que la création de MappingDriver. Il utilise aussi l’EventDispatcher: des évènements sont soulevés lorsque une action est exécutée sur une ressource. Il apporte aussi de nouveaux FormType ou FormExtension comme la CollectionExtension qui permet de gérer ses forms collection (js inclus)."
keyword: "sylius,resource bundle,crud,symfony,rad"
video:
  id: O8jzsNVFQHg
  title: "Développer avec le Sylius ResourceBundle"
date: 2015-03-01
slideshare: p8KjWf2PyoB94R
---

## Resources

{{< external-link href=https://sylius.com/blog/syliusresourcebundle-how-to-develop-your-crud-apps-faster/ label="Bundle documentation" >}}

{{< external-link href="https://github.com/Sylius/SyliusResourceBundle" label="Github repository" >}}

{{< external-link href="https://sylius.com/" label="Sylius website" >}}
