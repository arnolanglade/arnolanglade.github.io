---
title: How to handle user permissions through command bus middleware
description: "Applying user permissions might be very complex and can lead to introducing a lot of accidental complexity to your application. Adding a middleware to your command bus can solve this issue."
date: 2022-09-26
image: how-to-handle-permissions-through-command-bus-middleware.webp
image_credit: kellysikkema
keywords: "software,software architecture,design patterns,command bus,permissions,security,bus,middleware"
tags: [command-bus]
---

Applying user permissions might be very complex and can lead to introducing a lot of accidental complexity to your application. In this blog post, I want to share with you how to do it by simply adding a middleware to your command bus.

**Note:** If you're not familiar with this pattern, please have a look at this [blog post](http://arnolanglade.github.io/command-bus-design-pattern.html), it explains what a command bus and a middleware are.

Let’s imagine a basic use case: an application with two kinds of users: regular ones and admins. We want to allow certain actions only to admin users.

{% include training-link.html %}

First, I will introduce an interface `OnlyPerformedByAdministrator` that will be implemented by the command restricted to the admin users.

```php
interface OnlyPerformedByAdministrator
{
    public function username(): string;
}

class CreateNewProduct implements OnlyPerformedByAdministrator
{
    // ...
    public function username(): string
    {
        return $this->username;
    }
}
```

Then, we will add a `CheckAccessPermission` middleware to the command bus that will check if the user can execute an action. If he/she can’t, an `AccessDenied` exception will be thrown. It will be caught later in the execution flow to be turned into something that will be understandable to the user.

```php
final class AccessDenied extends \Exception
{
}

class CheckAccessPermission implements Middleware
{
    public function __construct(private Users $users) {}

    final public function handle(Command $command, Middleware $next): void
    {
        $user = $this->users->get(new Username($command->username()));
        if ($command instanceof OnlyPerformedByAdministrator && !$user->isAdmin()) {
            throw new AccessDenied();
        }

        $next->handle($command);
    }
}
```

This middleware will stop the command processing if an error is raised. We need to catch this exception to return a 403 HTTP response in the web controller, or to return a status code greater than 0 in the CLI command.

```php
final class WebToggleCartographerPremiumStatus
{
    public function __construct(private CommandBus $commandBus) {}
    
    public function __invoke(Request $request): Response
    {
        try {
            $this->commandBus->handle(new CreateNewProduct(/** ... */));
        } catch (AccessDenied) {
            throw new Response(403, 'Access denied');
        }

        return new Response(200);
    }
}
```

## Why do I handle permissions with a middleware?

I decided to add a middleware to the command bus because it ensures that permissions are checked no matter where commands are dispatched. For example: from the web controller or a CLI command. Moreover, I don't depend on a security library or any framework configuration. All permission business rules are coded in the domain.

Thanks to my proofreader [@LaureBrosseau](https://www.linkedin.com/in/laurebrosseau).
