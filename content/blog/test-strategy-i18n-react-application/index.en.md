---
title: "Testing a React application: Secure your tests from internationalization impact"
date: 2023-12-11
image_credit: claybanks
description: Learn how to prevent test suite breaks caused by translation changes through an innovative solution, ensuring resilience and flexibility in your testing approach.
keywords: I18n,localization,React-Intl,internationalization,Lokalise,testing,React testing,Jest,React Context,React,Typescript,Javascript
tags: [react, testing]
---

In my previous company, we automated the translation process. We used Lokalise, a cloud-based localization and translation management system. The developers imported all translation keys into the system, while the OPS team was responsible for translating all the keys.

{{< image src="translation-management-workflow.svg" alt="Translation management workflow with Lokalize" >}}

This process is excellent because you don't have to wait for translations. As a developer, you add the new translation key and provide the default language. The OPS team is notified when a new key is imported into the tool. They don't need a developer to provide translations; they are highly autonomous. Afterward, the developers need to pull the translations into the codebase and deploy the application.

Let’s consider an example: a React Application that uses the [React-Intl](https://github.com/formatjs/formatjs) as its internationalization system. This library provides a component called `FormattedMessage` that finds the translation for a given key and locale. This component must be used within a React Context called `IntlProvider`.

```tsx
const translations = { key: 'translation' };


<IntlProvider locale="en" messages={translations}>
  <FormattedMessage id="key" />
</IntlProvider>;
```

I like wrapping the `IntlProvider` in a custom provider that allows configuring React Intl for the entire application and provides additional features like locale switching. To keep this example simple, I hardcoded the locale.

```tsx
function AppIntlProvider({ children }: { children: ReactElement }) {
  const translations = { key: 'translation' };
 
  return (
    <IntlProvider
      messages={translations}
      locale="en"
      defaultLocale="en"
    >
      {children}
    </IntlProvider>
 );
}
```

Now let's go back to the testing problem. The following example is a test that checks if the `onClick` callback is called when the button with the label “OK” is clicked.`

```tsx
function MyComponent({ onClick }: { onClick: () => void }) {
  return (
    <div>
      // ...
      <Button onClick={onClick}>
        <FormattedMessage id="validate" />
      </Button>
    </div>
  );
}

//const translations = { validate: 'OK' };

it('validate something', () => {
  const onClick = jest.fn();
  render(
    <MyComponent onClick={onClick} />,
    {
      wrapper: AppIntlProvider,
    },
  );
 
  userEvent.click(screen.getByText('OK'));
 
  expect(onClick).toHaveBeenCalled();
});
```

What happens if an OPS changes the translation of the 'validate' key from 'OK' to 'GO' for any reason? Your test will break even if the code and the test have not changed. That is a shame. Should translations break your test suites? I would like to answer this question with a no.
The solution that I use to prevent this problem is to override each translation that the test needs. I added an extra prop to the custom React Intl provider called overriddenTranslations that lets me override the translations my test needs.

```tsx
function AppIntlProvider(
  { children, overriddenTranslations }:
  { children: ReactElement, overriddenTranslations?: Partial<Translations> },
) {
  const translations: Translations = { key: 'translation' };
 
  return (
    <IntlProvider
      messages={ { ...translations, ...overriddenTranslations } }
      locale="en"
      defaultLocale="en"
    >
      {children}
    </IntlProvider>
  );
}
```

Now, we only need to override the translation for the key 'validate.' Its value will remain 'OK' in the test context.

```tsx
// const translations = { validate: 'GO' };

it('validate something', () => {
  const onClick = jest.fn();
  render(
    <MyComponent onClick={onClick} />,
    {
      wrapper: (children) => (
        <AppIntlProvider overriddenTranslations={ { validate: 'OK' } }>
          {children}
        </AppIntlProvider>
      ),
    },
  );
  
  userEvent.click(screen.getByText('OK'));
  
  expect(onClick).toHaveBeenCalled();
});
```

Overriding a translation makes the test more resilient; even if you change the translation, the test will still pass (be green). In this specific context, it allows the OPS team to change any translation without breaking the test suite.
