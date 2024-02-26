---
title: Use composition instead of props drilling
date: 2023-05-22
image_credit: xavi_cabrera
url: react-composition-instead-of-props-drilling
aliases:
    - "use-composition-instead-of-props-drilling.html"
    - "use-composition-instead-of-props-drilling"
description: "Adding too many props will make your components complex, hard to understand and maintain. Instead opt for several small components and apply composition. Learn how in this blog article."
keywords: "react,reactjs,composition,javascript,typescript,react composition,react props drilling,react component props,react component testing"
tags: [react, testing]
---

In this blog post, I would like to speak about how composition can improve your React codebase. It’s easy to add a lot of props to your component to make them configurable but it’s not a good idea.

Let’s take an example. You are working on an e-Commerce webshop. A `ProductList` is used in the shop and the shop administration displays a list of products. In the shop administration, the component displays the product information and some calls to action (like product deletion and categorization for example) to manage products. In the shop you only need to display the product information, so, you don’t want to display the calls to action.

As we can see in the next example, most of the `ProductList` props are used to render and configure the checkbox or the button.

```tsx
export function ProductList({
 products,
 displayCheckbox,
 displayAction,
 actionLabel,
 onCheckboxClick,
 onActionClick,
}) {
 return (
   <ul>
     {products.map(product => (
       <li>
         {displayCheckbox &&
           <input type="checkbox" onclick={onCheckboxClick} /> : null}
         {product.label}
         {displayAction &&
           <button onclick={onActionClick}>{actionLabel}</button> : null}
       </li>
     )}
   </ul>
 );
}


```


This component is used in the `AdminShop`and `Shop` pages to display the product list to the customer or the shop owner.

```tsx
// Display to shop owner
export function AdminShop() {
 const [products, setProducts] = useState([]);


 useEffect(() => {
   setProducts(getAllProducts())
 }, []);


 return (
   <ProductList
     products={products}
     displayCheckbox={true}
     displayAction={true}
     actionLabel="delete"
     onCheckboxClick={/* callback */}
     onActionClick={/* callback */}
   />
 );
}


// Display to customers
export function Shop() {
 const [products, setProducts] = useState([]);


 useEffect(() => {
   setProducts(getProductsAvailableforSale())
 }, []);


 return (
   <ProductList
     products={products}
     displayCheckbox={false}
     displayAction={false}
   />


 );
}
```

The `ProductList`  has to display elements depending on the given props. This big component will help mutualize the code but it will introduce complexity. Adding too many props will make your components complex, and hard to understand and maintain. Composition will help us to get rid of those props.

**Note:** The `ProductList` component only has 3 props because I wanted to keep the example simple but guess what happens when your components have tens of props to configure them?

How can composition help us? It’s like playing Lego. You need several bricks from different sizes and colors to create something. The big `ProductList` component can be split into several small components used to build the product list depending on business cases.


```tsx
export function ProductList({children}) {
 return (
   <ul>{children}</ul>
 );
}


export function Product({label, checkbox, action}) {
 return (
   <li>
     {checkbox}
     {label}
     {action}
   </li>
 );
}


export function ProductCheckbox({onClick}) {
 return <input type="checkbox" onClick={onClick}/>;
}


export function ProductAction({onClick, actionLabel}) {
 return <button onClick={onClick}>{actionLabel}</button>;
}
```

In the previous code example, we created 4 new components: `ProductList`, `Product`, `ProductCheckbox` and `ProductAction`. They are like Lego bricks and we can assemble them to create the product list with or without the call to action.

**Note:** It’s not mandatory to create a dedicated component for the checkbox and the button. It can be useful to wrap generic components into more business-oriented ones. It helps to make things clearer. It’s another way to apply composition.

```tsx
// Display to shop owner
export function AdminShop() {
 const [products, setProducts] = useState([]);


 useEffect(() => {
   setProducts(getAllProducts())
 }, []);


 return (
   <ProductList>
     {products.map(product => 
       <Product
         label={product.label}
         checkbox={<ProductCheckbox onClick={/* callback */} />}
         action={<ProductAction onClick={/* callback */} actionLabel={"delete"} />}
       />
     )}
   </ProductList>
 );
}


// Display to customers
export function Shop() {
 const [products, setProducts] = useState([]);


 useEffect(() => {
   setProducts(getProductAvailableforSale())
 }, []);


 return (
   <ProductList>
     {products.map(product => <Product label={product.label} />)}
   </ProductList>
 );
}
```

Small components are easier to test. They help build more stable applications and are easier to maintain. Your codebase will be less complex to understand. It will decrease your and your teammates’ mental load because you won’t have any components with complex API and logic. 

Thanks to my proofreader [@LaureBrosseau](https://www.linkedin.com/in/laurebrosseau).
