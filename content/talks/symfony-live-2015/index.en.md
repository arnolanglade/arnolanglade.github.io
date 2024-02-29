---
title: Developing with the Sylius ResourceBundle
conference:
  title: Symfony live Paris 2015
  link: https://live.symfony.com/2015-paris
description: "Talk at Symfony Live Paris: I present the ResourceBundle that eases CRUD for Symfony applications."
abstract: "During its development, the Sylius team realized that they were duplicating a lot of code to manage their CRUDs. Not wanting to reinvent Symfony or use an admin generator, they decided to create a simple and flexible bundle: SyliusResourceBundle. I will present how to manage your CRUDs with this bundle by writing the minimum amount of code and, most importantly, without duplicating it! It was designed to support multiple types of drivers (DoctrineORM, PHPCR). Moreover, it allows for the rapid construction of an API thanks to the FOSTRestBundle. I will highlight all the components used by this bundle, such as Doctrine. It facilitates configuration through ResolveDoctrineTargetEntitiesPass and the creation of MappingDriver. It also uses the EventDispatcher: events are raised when an action is executed on a resource. It also brings new FormType or FormExtension like the CollectionExtension, which allows managing your form collections (including JS)."
keyword: "sylius,resource bundle,crud,symfony,rad"
video: O8jzsNVFQHg
date: 2015-03-01
slideshare: p8KjWf2PyoB94R
---

## Resources

{{< external-link href=https://sylius.com/blog/syliusresourcebundle-how-to-develop-your-crud-apps-faster/ label="Bundle documentation" >}}

{{< external-link href="https://github.com/Sylius/SyliusResourceBundle" label="Github repository" >}}

{{< external-link href="https://sylius.com/" label="Sylius website" >}}
