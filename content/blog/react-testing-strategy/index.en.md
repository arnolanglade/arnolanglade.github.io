---
title: Three types of React components for an effective testing strategy
date: 2024-01-15
image_credit: roman_lazygeek
url: react-testing-strategy
aliases:
    - "react-testing-strategy.html"
description: Discover an effective strategy for testing React components by categorizing them into UI, Business, and Page components. Learn how to organize your codebase to facilitate testing for maintainable code.
keywords: react,reactjs,software testing,testing strategies,code maintainability,react testing,react architecture
tags: [react, testing]
---

Automated tests are crucial for building robust software. They allow you to enhance existing features or add new ones without pressure because they ensure the application works without regression.

I did not feel comfortable when I first started working with React. Applying a strong test strategy was complicated, and it was painful for me as a TDD practitioner. I am not efficient without tests as I use them to design code step by step.

After making several mistakes, I found a way to organize my React applications to make me comfortable with testing. Now, I categorize React components into three groups: page components, business components, and UI components. In the following sections, I will explain what they are and how to test them.

## UI components (design system)

UI components are dumb components, meaning they don’t have any business logic. Their only purpose is to represent UI elements, such as buttons, typography, or dropdowns. You can create these components from scratch to brand your own design system or use existing libraries like [Material UI](https://mui.com/).

```tsx
function Dropdown({label}) {
  const [isOpened, setIsOpened] = useState<boolean>(false)
  return (
    <>
      <button onClick={() => setIsOpened(true)}>{label}</button>
      {isOpened && <p>dropdown content</p> ? null}
    </>
  )
}
```

```tsx
it("shows the content of the dropdown when I click on it", () => {
  render(<Dropdown label="open me" />)
    
  fireEvent.click(screen.getByText('open me'))
  
  expect(screen.getByText('dropdown content')).toBeInTheDocument()
})
```
If your application is internationalized, you should not translate these types of components. Here, we only want components to build a UI no matter the context of their usage. If, for any reason, you need to create your own design system, it is better to avoid coupling your design to the translation system and let each project choose the library that matches their needs.
## Business components
Business components are also dumb components. Their goal is to render a sub-part of a page without any business orchestration, meaning no side effects like HTTP calls. They are built with UI components or other business components.

```tsx
// translations: {available: 'Product available'}
function Product({product}) {
  const {translate} = useIntl()
  return (
    <div>
      <p>{product.name} {product.stock > 0 ? translate('available') : ''}</p>
      <p>{product.description}</p>
    </div>
  )
}
```

```tsx
it("shows to the customer if the product is in stock", () => {
  render(<Product product={ {name: 'TV', description: 'super TV', stock: 10} } />)

  expect(screen.getByText('Product available')).toBeInTheDocument()
})
```

We only use those components in a single application as they are business-oriented. There's no need to share them, so we can translate them. Testing these components can be a bit challenging due to the translation system; translations can change and break your tests. I’ve written a blog post about how to test an application that is localized:

{{< page-link page="test-strategy-i18n-react-application" >}}

## Page components

Page components are a kind of controller. They delegate the orchestration of business logic to a custom hook. The hook is responsible for handling all side effects and managing the current state of the page. We can retrieve data from the hook to pass to the business components for rendering the page.

I've written a blog post to explain how a custom hook helps improve testability. Take a look at it to understand how it can enhance your code quality and help decouple concerns:

{{< page-link page="how-to-use-custom-react-hook-to-increase-application-testability" >}}

We can call them screen components as well. This term makes more sense, particularly in a mobile application.

```tsx
const useProductPage = () => {
  const [product, setProduct] = useState()
  useEffect(() => {
    setProduct({name: 'TV', description: 'super TV', stock: 10})
  }, [])
    
  return {
    product
  }
}

function ProductPage() {
  const {product} = useProductPage()
  return (
    <Product product={product} />
  )
}
```

```tsx
it("shows product information to the customer", () => {
  render(<ProductPage />)
  
  expect('TV').toBeInTheDocument()
  expect('super TV').toBeInTheDocument()
  expect('available').toBeInTheDocument()
})
```

**Caution:** Depending on which libraries you are using in your project, Jest may not be the best tool for testing pages. If you use a library that can only be rendered in the browser context, you should consider using tools such as [cypress](https://www.cypress.io)

## The big picture

The purpose of having these different types of components is to isolate responsibilities. As you can see in the following diagram, there are three responsibilities: rendering the user interface (view), bridging the gap between the view and the business logic (orchestrator), and handling the business logic (business logic).

{{< image src="big-picture.svg" alt="Big picture" >}}

Business and UI components are responsible for rendering the user interface. The custom hook contains the business logic, retrieving or sending data to the server and managing the state of the page. The page component acts as a bridge between the hook and the view.

Now, new React frameworks provide server-side rendering (SSR), allowing you to render your page on the server side. This is an excellent way to improve performance as it prevents querying the API to retrieve data.

How can we apply what I explained in the previous section to an application that uses SSR? Since the page component is initialized with all the data, the hook won’t need to query the data anymore.

{{< image src="big-picture-with-ssr.svg" alt="Big picture with SSR" >}}

Lastly, coupling will prevent you from easily testing your code. The solution to avoid this kind of problem is to apply the Dependency Inversion Principle from the SOLID principles. It will help you make your code more modular and easy to test. I’ve written a blog post to explain how to apply it to a React application:

{{< page-link page="how-to-reduce-coupling-in-your-react-app" >}}
