---
title: How to validate a command?
permalink: /:title:output_ext
description: Domain validation ensures your aggregate cannot be built in an invalid state but that is not enough to give good feedback to the end users. Validating commands is the best to prevent their processing if data given by users are wrong.
layout: post
date: 2021-03-04
image: data-validation.webp
alt: How to validate a command?
tags: [oop, design-patterns]
keywords: "oop,design patterns,software,software architecture,command,command handler,command bus,data validation,domain validation"
related_posts: ["Command and command handler design pattern", "The command bus design pattern", "How to handle user permissions through command bus middleware"]
---

# How to validate a command?

![Command validation](assets/img/posts/data-validation.webp)
[@heapdump](https://unsplash.com/@heapdump)

In my previous [blog post](http://arnolanglade.github.io/command-handler-patterns.html), I talked about command and command handler design patterns. I got several questions about data validation and how to give feedback to users. We are going to talk about several kinds of data validation in this blog post. We will start with domain validation, this validation ensures we can build our domain objects in a good state depending on business rules. Then, we will talk about command validation and how we can use it to give feedback to users when they submit data to the application.

Let’s take the same example I used in my previous blog post: an account creation. To create an account, my business expert expects that I provide a username and a password. The username should have at least three characters and should be unique. The password should have at least eight characters, an uppercase letter, a lowercase letter, and a number.

## Domain validation

How to make sure the domain objects follow the business rules? Value object will help us to achieve that. I **strongly recommend you** to wrap all primitives into value objects. It is a good way to introduce new types in your codebase, make it clearer and business-focused. And don't forget, value objects **cannot** be built in a wrong state.

```php
final class Username
{
    private string $username;

    public function __construct(string $username)
    {
        if (\strlen($username) < 3) {
            throw new \InvalidArgumentException('The username is too short, it should contain at least 3 characters');
        }

        $this->username = $username;
    }
}

final class Password
{
    private string $password;

    public function __construct(string $password)
    {
        if (1 !== \preg_match('#(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}#', $password)) {
            throw new \InvalidArgumentException(
                'The password must contain at least 8 characters, an uppercase letter, lowercase letter and a number'
            );
        }

        $this->password = $password;
    }
}
```

Then we are able to modelize the `Account` aggregate using the `Username` and `Password` value objects.

```php
final class Account
{
    private Username $username;
    private Password $password;

    public function __construct(
        Username $username,
        Password $password
    ) {
        $this->username = $username;
        $this->password = $password;
    }
}
```

Now, we are sure that as developers we cannot instantiate the `Account` aggregate in a wrong state. In the next section, we are going to see how to use the domain objects to give users feedback about their data.

## Command validation

As I explained in my previous [blog post](http://arnolanglade.github.io/command-handler-patterns.html), an account creation is represented by a `CreateAnAccount` command with two properties: the username and the password. We need to validate them to create the account aggregate without any errors and tell users if they provided valid data to perform this action. The command validation will be done by the Symfony validator. Don’t hesitate to have a look at the [validator documentation](https://symfony.com/doc/current/validation.html) if you are not familiar with it.

First, we will use the callback constraint to make sure the username and password follow the patterns given by the business expert. Thanks to annotation we will configure the validator to call a static method to validate command properties. I will call them “static validators“ in this blog post.


```php
final class CreateAnAccount
{
    /** @Assert\Callback({"Domain\Account\UseCase\ValidationRule\Superficial\UsernameShouldBeValid", "validate"}) */
    private string $username;
    /** @Assert\Callback({"Domain\Account\UseCase\ValidationRule\Superficial\PasswordShouldBeValid", "validate"}) */
    private string $password;
}
```

Then, it is time to create those static validators. We just need to instantiate our value objects and check if they throw exceptions to catch them and turn them into violations.

```php
final class UsernameShouldBeValid
{
    public static function validate(string $username, ExecutionContextInterface $context): void
    {
        try {
            new Username($username);
        } catch (\InvalidArgumentException $e) {
            $context->buildViolation('account.usernameShouldBeValid')
                ->addViolation();
        }
    }
}

final class PasswordShouldBeValid
{
    public static function validate(string $password, ExecutionContextInterface $context): void
    {
        try {
            new Password($password);
        } catch (\InvalidArgumentException $e) {
            $context->buildViolation('account.passwordShouldBeValid')
                ->addViolation();
        }
    }
}
```

For more complex use cases you can call any methods on value objects, but you need to keep in mind that you cannot inject services into those static validators.

```php
public static function validate(BookFlightTicket $flightTicket, ExecutionContextInterface $context): void
{
    if (
    !Date::fromString($flightTicket>departureDate)->laterThan(
        Date::fromString($flightTicket>arrivalDate)
    )
    ) {
        $context->buildViolation('flightTicket.dateShouldBeValid')
            ->addViolation();
    }
}
```

The first step is done! Thanks to those static validators, we apply domain validation on command properties to ensure we can instantiate domain objects. But, domain validation only works with a single account because the account aggregate only represents the account of a single user. For instance, an account cannot validate if a username is unique because it needs to be aware of the rest of the created account.

To check if a username is used by another user we will need to ask the repository if an account already exists with the given username. That’s why we will need to create a custom validation constraint because those constraints are declared as services, and they can depend on other application services.


```php
/** @Annotation */
final class UsernameShouldBeUnique extends Constraint
{
}

final class UsernameShouldBeUniqueValidator extends ConstraintValidator
{
    private Accounts $accounts;

    public function __construct(Accounts $accounts)
    {
        $this->accounts = $accounts;
    }

    public function validate($username, Constraint $constraint): void
    {
        if (!$constraint instanceof UsernameShouldBeUnique) {
            throw new UnexpectedTypeException($constraint, UsernameShouldBeUnique::class);
        }

        try {
            $this->accounts->getByUsername(new Username($username));

            // an exception is thrown if an account does not exist so we don’t add violation
            $this->context->buildViolation('account.usernameShouldBeUnique')
                ->addViolation();
        } catch (UnknownAccount $exception) {
        }
    }
}
```

Finally, we need to configure the validator to apply this new constraint to the username property.


```php
/**
 * @Assert\GroupSequence({"CreateAnAccount", "Business"})
 */
final class CreateAnAccount
{
    /** 
     * @Assert\Callback({"Domain\Account\UseCase\ValidationRule\Superficial\UsernameShouldBeValid", "validate"})
     * @Domain\Account\UseCase\ValidationRule\UsernameShouldBeUnique(groups={"Business"})
     */
    private string $username;
    
    // ...
}
```

**Caution:** we need to apply static validators before applying custom constraints because we need to be sure we can instantiate all domain objects without raising any error. For instance, the instantiation of `Username` in `UsernameShouldBeUniqueValidator` must not raise any error because the goal of this constraint is not to check if the username contains at least three characters but if the username is already used. It can be done with [GroupSequence](https://symfony.com/doc/current/validation/sequence_provider.html). This validator feature allows adding groups to constraints and defining the validation constraint execution order.

Now, this is the end of the story! If commands are invalid, we just need to serialize violations, give them to your front application, and print errors to users.

## Last word

This might not be the only way to validate data but it worked on my previous project. Even if I use a service to validate my command I try to use as many domain objects as possible to avoid reinventing the wheel. I hope it answers Baptiste Langlade’s [question](https://twitter.com/Baptouuuu/status/1364945053236494336) on Twitter. If you wonder, Baptiste is not my brother ;).

Thanks to my proofreaders [@LaureBrosseau](https://twitter.com/LaureBrosseau) and [@jjanvier_](https://twitter.com/jjanvier_).
