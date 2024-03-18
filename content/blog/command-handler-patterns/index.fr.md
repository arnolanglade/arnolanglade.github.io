---
author: "Arnaud Langlade"
title: "Le design pattern Command and command handler"
url: "command-handler-patterns"
date: "2024-04-02"
image_credit: redaquamedia
description: "Découvrez le design pattern command et command handler dans le développement logiciel. Les commandes représentent les intentions des utilisateurs, prises en charge par le command handler. Apprenez ces patterns à travers des exemples concrets et bien plus, comme par exemple la validation de commande ou l’utilisation d’un command bus"
keywords: "design patterns,software,software architecture,command,command handler,command bus"
tags: [
    "command-bus",
    "design-patterns",
]
---

Ce modèle est vraiment intéressant et peut vous aider à gérer vos cas d'utilisation (use cases). Une `command` représente l'intention de l'utilisateur, tandis que le `command handler` réalise les actions nécessaires pour accomplir le cas d'utilisation. Approfondissons un peu ces deux concepts.

## Qu'est-ce qu'une commande ?

Une commande est un objet qui encapsule toutes les informations nécessaires pour exécuter une action. Ce design pattern sert à représenter les intentions des utilisateurs, et la commande est ensuite donnée à un command handler.

Généralement, une commande est conçue comme un Data Transfer Object (DTO), c'est-à-dire un objet sans comportement propre (une structure de données). La règle de conception la plus importante est que la commande doit être facilement sérialisable, ce qui permettra de l’envoyer dans une file d'attente orchestrée par des outils comme RabbitMQ ou pub-sub pour un traitement asynchrone.

## Qu'est-ce qu'un command handler

Un command handler est simplement un callable qui réalise toutes les actions nécessaires pour satisfaire l'intention d'un utilisateur. Comme vous pouvez le comprendre, ce design pattern est idéal pour gérer vos cas d'utilisation métier (business use cases).

## Comment cela fonctionne-t-il ?

{{< image src="explain-command-handler.png" alt="Le design pattern Command and command handler" >}}

Ce pattern suit quelques règles essentielles. La première stipule qu'une commande doit être traitée par un unique command handler car il existe une seule façon pour traiter un cas d'utilisation spécifique. La seconde règle précise que le command handler doit recevoir une commande valide. La validation de la commande garantit que les données fournies par l'utilisateur sont correctes, évitant ainsi l'échec de l’exécution de la commande. Cela permet également de fournir rapidement un retour à l'utilisateur concernant les données qu'il a soumises.

La commande est simplement un DTO qui transporte des données, tandis que le command handler est chargé d'exécuter toutes les actions nécessaires pour réaliser les cas d'utilisation.

## Comment l'utiliser ?

Considérons un exemple simple : la création d’un compte. Notre expert métier s'attend à ce que les utilisateurs fournissent un email et un mot de passe pour créer un compte pour se connecter sur l’application. Nous allons concevoir une commande nommée `CreateAnAccount`  et son handler, `CreateAnAccountHandler`.

Tout d'abord, nous devons créer une commande nommée `CreateAnAccount` pour représenter l'intention de l'utilisateur.

```php
final class CreateAnAccount
{
   public readonly string $username;
   public readonly string $password;
   
   public function __construct(string $username, string $password) 
   {
       $this->username = $username;
       $this->password = $password;
   }
}
```

Ensuite, il est nécessaire de créer un command handler pour prendre en charge ce cas d'utilisation. Le command handler peut être une fonction ou un objet invocable. Il ne doit retourner aucun résultat (void) afin d'être traité de manière asynchrone, puisque nous ne connaissons pas le moment où son traitement sera fini et qu'un résultat instantané ne peut être garanti. En utilisant les données fournies par la commande, nous effectuons toutes les actions requises pour adresser le cas d'utilisation. Dans notre exemple, nous constituons un agrégat `Account` que nous passerons ensuite au repository `Account`.

```php
final class CreateAnAccountHandler
{
   private Accounts $accounts;

   public function __construct(Accounts $accounts)
   {
       $this->accounts = $accounts;
   }

   public function __invoke(CreateAnAccount $createAnAccount): void
   {
       $account = Account::create(
           $createAnAccount->username(),
           $createAnAccount->password()
       );

       $this->accounts->add($account);
   }
}
```

Pour finir, assemblons ces morceaux de code dans un contrôleur (cet exemple est fait avec le Framework Symfony). Ce contrôleur reçoit des données encodées en JSON pour créer une commande, qui est ensuite validée et passée au handler.

```php
final class CreateAnAccount
{
    // ...
    
    public function __invoke(Request $request): Response
    {
        $command = $this->serializer->deserialize(
            $request->getContent(),
            CreateAnAccount::class,
            'json'
        );
        
        $violations = $this->validator->validate($command);
        
        if (0 < $violations->count()) {
           throw new BadRequestHttpException(/*json encoded violation*/);
        }
        
        ($this->createAnAccountHandler)($command);
        
        return new JsonResponse(null, Response::HTTP_CREATED);
    }
}
```

**Astuce :** Pour faciliter la création de commandes, vous pouvez utiliser des bibliothèques comme le composant Serializer de Symfony. Cela simplifie la création d'objets à partir d'un set de données (tel que JSON), la rendant ainsi plus aisé et rapide

```php
$createAccount = $serializer->deserialize(
    '{“username”:”arnaud”, “password”:“password”}',
    CreateAnAccount::class,
    'json'
);
```

**Astuce :**  Afin d'éviter de réinventer la roue, vous pouvez vous appuyer sur des bibliothèques telles que le composant `Validator` de Symfony pour effectuer la validation de la commande.

```php
$violation = $validator->validate($createAccount);
```

J'ai écrit un article de blog expliquant comment valider une commande :

{{< page-link page="how-to-validate-a-command" >}}

## Comment simplifier cela

Pour simplifier ce contrôleur, vous pouvez utiliser un command bus qui sera responsable de déterminer le bon command handler pour une commande donnée. Pour plus d'informations sur ce design pattern, j'ai écrit un article de blog expliquant comment cela fonctionne :

{{< page-link page="command-bus-design-pattern" >}}

L'exemple suivant est construit avec [Symfony Messenger](https://symfony.com/doc/current/components/messenger.html).

```php
public function __invoke(Request $request): Response
{
    $command = $this->serializer->deserialize(
        $request->getContent(),
        CreateAnAccount::class,
        'json'
    );
    
    $this->commandBus->handle($command);
    
    return new JsonResponse(null, Response::HTTP_CREATED);
}
```

Où se situe la validation de la commande dans cet exemple ? Les command buses sont souvent construits de middlewares, ce qui les rend facilement configurables. Afin de s'assurer que toutes les commandes sont valides avant de les donner à un command handler, il est nécessaire d'ajouter un middleware au command bus dédié à la validation des commandes.

```php
class ValidationMiddleware implements MiddlewareInterface
{
    // …

    public function handle(Envelope $envelope, StackInterface $stack): Envelope
    {
        $message = $envelope->getMessage();        
        $violations = $this->validator->validate($message, null, $groups);
        if (\count($violations)) {
            throw new ValidationFailedException($message, $violations);
        }

        return $stack->next()->handle($envelope, $stack);
    }
}
```

**Astuce :** Jetez un œil à ce blog post si vous devez gérer les permissions des utilisateurs. Ajouter un middleware au command bus peut renforcer la sécurité de votre application.

{{< page-link page="how-to-handle-user-permissions-through-command-bus-middleware/" >}}

## Pour finir

Dans de nombreuses applications, j'ai vu beaucoup de classes nommées managers ou services (par exemple, `AccountService`, `AccountManager`) qui regroupent toute la gestion des cas d'utilisation dans une seule classe. Bien que cette approche puisse être efficace au départ, au fur et à mesure que le développement progresse, ces classes ont tendance à devenir de plus en plus grandes et à devenir un "god object". Cela rend la maintenance difficile, réduit la lisibilité et peut rapidement se transformer en objet fourre-tout. Je pense que l'adoption de es pattern peut résoudre ces problèmes
