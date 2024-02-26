---
author: "Arnaud Langlade"
title: "Command and command handler design pattern"
url: "command-handler-patterns.html"
date: "2021-02-25"
image_credit: redaquamedia
description: "Discover the command design pattern in software development. Learn how commands represent user intents, handled by command handlers. Learn practical tips, examples, and insights for efficient command validation."
keywords: "design patterns,software,software architecture,command,command handler,command bus"
tags: [
    "command-bus",
    "design-patterns",
]
---

This pattern is really interesting; it can help you handle use cases. A command represents the user's intent, while the command handler performs the actions needed to achieve the use case. Let’s dig a bit into these two concepts.

## What is a command?

A command is an object used to encapsulate all the information needed to perform an action. This design pattern is used to represent user intents, and the command is given to a command handler.

A command is often designed as a Data Transfer Object (DTO), which is an object without any behavior (a data structure). The most important design rule to consider is that a command should be easily serializable. This way, it can be sent to a queue such as RabbitMQ or pub-sub to be handled asynchronously.

## What is a command handler?

A command handler is just a callable that executes all the actions needed to fulfill a user's intent. As you may understand, this design pattern is perfect for managing your business use cases.

## How does it work?

{{< image src="explain-command-handler.svg" alt="Command handler design pattern" >}}

This pattern has some rules. The first one is that a command can be handled by a single command handler because there is only a single way to handle a use case. The second rule is that a command handler should receive a valid command. Validating the command ensures that the user provides the correct data to prevent the handling from failing. It also helps to provide early feedback to the user about the data they provided.

The command is only a DTO that carries data while the command handler is responsible to handle use cases.

{{< training-link >}}

## How to use it?

Let’s consider a simple example: creating an account. Our business expert expects users to provide an email and a password to create an account for login purposes. We will create a command named `CreateAnAccount` and its handler, `CreateAnAccountHandler`.
First, we need to create a command named `CreateAnAccount` to represent the user's intent.

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

Next, we need to create a command handler to manage this use case. The command handler can be a function or an invocable object. It should return nothing (void) to be handled  asynchronously as we don’t know when it will be processed and can’t expect an instant result. Using the command data, we perform all actions needed to handle the use case. In our example, we create an account aggregate and pass it to the account repository.

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

Finally, let’s stick those pieces of code together in a controller (this example is made with a Symfony Framework). This controller receives JSON-encoded data to create a command, which is then validated and passed to the handler

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
**Tip:** : To simplify command creation, you can use libraries such as the Symfony Serializer component. It eases object creation from a set of data (e.g., JSON), making the process easier and faster.

```php
$createAccount = $serializer->deserialize(
    '{“username”:”arnaud”, “password”:“password”}',
    CreateAnAccount::class,
    'json'
);
```

Tip: To avoid reinventing the wheel, you can leverage libraries like the Symfony Validator component to validate the command.

```php
$violation = $validator->validate($createAccount);
```

I've written a dedicated blog post explaining how to validate a command:

{{< page-link page="how-to-validate-a-command" >}}

## How to simplify that?

To simplify this controller, consider using a command bus, which is responsible for finding the right handler for a given command. For more information about this pattern, I've written a dedicated blog post explaining how it works:

{{< page-link page="command-bus-design-pattern" >}}

The following example is built with [Symfony Messenger](https://symfony.com/doc/current/components/messenger.html).

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

Where is the command validation in this example? Command buses are often built with middleware, making them highly configurable. To ensure that all commands are valid before passing them to a command handler, we need to add middleware to the command bus for command validation.

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

**Tip:** Take a look at this blog post if you need to manage user permissions. Adding a middleware to the command bus can enhance the security of your application:

{{< page-link page="how-to-handle-user-permissions-through-command-bus-middleware/" >}}

## My last thoughts

In many applications,I have seen a lot of classes named managers or services (e.g., AccountService, AccountManager) that gather all use case management into a single class. While this approach might be effective initially as development progresses, these classes tend to grow larger and larger, and become a "god object." This makes maintenance challenging, reduces readability, and can quickly turn into a dump. I believe this pattern can address these issues.

Thanks to my proofreader [@LaureBrosseau](https://www.linkedin.com/in/laurebrosseau).
