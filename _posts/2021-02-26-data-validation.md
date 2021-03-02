---
title: Data validation
permalink: /:title:output_ext
layout: post
date: 2021-02-26
image: data-validation.jpg
alt: Data validation
---

# Data validation

![Data validation](assets/img/posts/data-validation.jpg)
[@heapdump](https://unsplash.com/@heapdump)

## Domain validation
In my previous [blog post](http://arnolanglade.github.io/command-handler-patterns.html), I spoke about command and command handler design patterns. I got several questions about data validation and how to give feedback to users. Let’s take the example of my previous blog post: an account creation. To create an account, my business expert expects that I provide a username with at least three characters and a password with at least eight characters, an uppercase letter, a lowercase letter, and a number.

How to make sure the username and password will match the rules given by our business expert? Value object will help us to achieve that. I **strongly recommend you** to wrap those properties into value objects which cannot be instantiable if data provided by users are wrong. It is a good way to introduce new types in your codebase and make it clearer and business-focused.

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

Then we are going to modelize an account aggregate with username and password properties.

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

## Superficial validation
Thanks to the domain validation we will be able to give feedback to users if they provide invalid data. As I explained in my previous [blog post](http://arnolanglade.github.io/command-handler-patterns.html) we create a command `CreateAnAccount` to represent the account creation user intent. I will show you how to use those value objects to validate command data. For that, we will use the Symfony validator component, and to be more precise we will only use the callback constraint. First, thanks to annotation will configure the validator to call a static method to validate command properties.

```php
final class CreateAnAccount implements Command
{
    /** @Assert\Callback({"Domain\Account\UseCase\ValidationRule\Superficial\UsernameShouldBeValid", "validate"}) */
    private string $username;
    /** @Assert\Callback({"Domain\Account\UseCase\ValidationRule\Superficial\PasswordShouldBeValid", "validate"}) */
    private string $password;
}
```

Then, we need to create those static methods to be able to add violations if command properties are wrong. Don’t hesitate to have a look at the [validator documentation](https://symfony.com/doc/current/validation.html) if you are not familiar with it. We just need to instantiate our value objects and check if they throw exceptions to catch them and turn them into violations.

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

For more complex use cases you can call methods on value objects to make sure the given data are valid like the following example.

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

Then, you just need to serialize those violations and give them to your front application to print errors to users. That is what I call superficial validation. It makes sure that all domain objects (value objects, aggregates, and so on) will be instantiated without throwing any exception.

## Business validation
Keep in mind that domain validation only works with a single account because account aggregate only represents the account of a single user. For instance, an account cannot validate if a username is unique because it needs to be aware of the rest of the created account. To achieve that we will still use the Symfony validator with a custom validation constraint. It allows us to use all application services (like repositories for instance) to apply the rest of the business rules defined by our business expert.

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

As I said previously, superficial validation makes us sure that all domain objects are instantiable, that's why we need to apply those business constraints after the superficial ones.


```php
/**
 * @Assert\GroupSequence({"CreateAnAccount", "Business"})
 */
final class CreateAnAccount implements Command
{
    /** 
     * @Assert\Callback({"Domain\Account\UseCase\ValidationRule\Superficial\UsernameShouldBeValid", "validate"})
     * @Domain\Account\UseCase\ValidationRule\UsernameShouldBeUnique(groups={"Business"})
     */
    private string $username;
    
    // ...
}
```

`UsernameShouldBeUnique` will be applied after `UsernameShouldBeValid` thanks to the [GroupSequence](https://symfony.com/doc/current/validation/sequence_provider.html).

## Conclusion
During the blog post writing, I realized that superficial validation and business validation might not be the right words to describe those concepts but the important thing is what they do. Superficial validation makes me sure I can instantiate all my domain objects to make sure that business validation can use them to apply rules which need to be aware of what happens in the whole application.

My commands are not objects but simple DTOs because DTOs are easily buildable thanks to the Symfony Serializer component. Then I use Symfony validator to validate commands because with this library I can easily apply domain validation on command properties thanks to the callback constraint and I can easily use application services to apply the rest of the data validation thanks to the custom constraints.

I hope it answers Baptiste Langlade’s [question](https://twitter.com/Baptouuuu/status/1364945053236494336) on Twitter (this is not my brother by the way ;)).

Thanks to my proofreader [@LaureBrosseau](https://twitter.com/LaureBrosseau).
