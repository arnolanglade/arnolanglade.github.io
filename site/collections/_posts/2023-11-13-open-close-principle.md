---
title: "Open-Closed principle: Enhancing code modularity"
description: Unlock the potential of the Open-Closed Principle in programming. Discover how to enhance code modularity and simplify maintenance using this SOLID concept. Learn to reduce complexity and write more flexible code.
date: 2023-11-13
image: open-close-principle.webp
alt: "Open-Closed principle: Enhancing code modularity"
image_credit: madze
keywords: open-closed principle,SOLID principles,software engineering,design patterns,strategy pattern,object-oriented programming,programming principles,development best practices
tags: [OOP, SOLID]
---

Have you missed my last blog post about the [pitfalls of inheritance](/oop-inheritance-pitfalls.html)? I explain how it could be a bad idea to use it too much. Applying composition prevents this problem; it is better to work with small classes to easily assemble. In this blog post, I will talk about the open-closed principle. This principle facilitates composition and helps avoid relying too much on inheritance.

This principle is one of the SOLID principles, and I think it is super important because it allows you to write more flexible code. I wanted to explain it because its definition is quite simple, but it is not necessarily easy to grasp.

> The open closed principle states "software entities (classes, modules, functions, etc.) should be open for extension, but closed for modification"; that is, such an entity can allow its behaviour to be extended without modifying its source code.
>
> [Wikipedia](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle)

The first time I read the definition of this principle, I understood that I should not have to modify my code to add additional behavior. This part of the definition “open for extension” was a bit confusing. What did it mean? Does it refer to OOP inheritance?  No, it doesn't refer to OOP inheritance. I have written a blog post about OOP inheritance. It explains why extending a class to change its behavior may seem simple, but is it a good idea? It introduces a lot of coupling in your codebase and between your team.

Before digging into the principle, let's consider a scenario to illustrate the following example: a class called 'DiscountCalculator' is in charge of calculating discounts based on the products in the basket. We apply a 20% discount to products with the category 'sport,' a 50% discount to products with the category 'home,' and a 10% discount to products with the category 'food.

```ts
class Product {
   constructor(
       public name: string,
       public category: string,
       public price: number
   ) {}
}

class Basket {
   constructor(public products: Product[]) {}
}

class DiscountCalculator {
   calculate(basket: Basket): number {
       let totalDiscount = 0;


       for (const product of basket.products) {
           switch (product.category) {
               case 'sport':
                   totalDiscount += product.price * 0.2; // 20% discount
                   break;
               case 'home':
                   totalDiscount += product.price * 0.5; // 50% discount
                   break;
               case 'food':
                   totalDiscount += product.price * 0.1; // 10% discount
                   break;
           }
       }
       
       return totalDiscount;
   }
}

// Example usage:
it.each([
   ['Football', 'sport', 100, 20],
   ['Couch', 'home', 200, 100],
   ['Banana', 'food', 10, 1],
])('calculates discounts for %s category', (productName, category, price, expectedDiscount) => {
   const product = new Product(productName, category, price);
   const basket = new Basket([product]);
   
   expect(new DiscountCalculator().calculate(basket)).toBe(expectedDiscount);
});
```

This code does not follow the open-close principle because we need to modify this `DiscountCalculator` class every time we want to add or remove a discount rule. The problem is that`DiscountCalculator` may become really large if the business asks us to add a lot of discount rules. Large objects are hard to understand, so it won't facilitate its maintenance and testability.

Let’s refactor this code to enhance its modularity and align it with the Open-Closed principle. We will use the strategy pattern to rewrite the calculator to remove the hard-coded rules. First, we will introduce a new interface that specifies how a discount works. This interface has two methods: the first one is `isApplicable`, which determines if a discount can be applied to a product, while the second one `calculate` calculates the amount of the discount.

```ts
interface Discount {
   isApplicable(product: Product): boolean
   calculate(product: Product): number;
}

class SportCategoryDiscount implements Discount {
   isApplicable(product: Product): boolean {
       return product.category === 'sport';
   }
   
   calculate(product: Product): number {
       return product.price * 0.2;
   }
}

class HomeCategoryDiscount implements Discount {
   isApplicable(product: Product): boolean {
       return product.category === 'home';
   }
   
   calculate(product: Product): number {
       return product.price * 0.5;
   }
}

class FoodCategoryDiscount implements Discount {
   isApplicable(product: Product): boolean {
       return product.category === 'food';
   }
   
   calculate(product: Product): number {
       return product.price * 0.1;
   }
}
```

Then, we need to update the calculator. It will determine whether a discount is applicable to a product and calculate the discount amount. With this approach, you can easily add or remove discount rules as needed.

```ts
class DiscountCalculator {
   constructor(private discounts: Discount[]) {}
    
   calculateDiscount(basket: Basket): number {
       let totalDiscount = 0;
       
       basket.products.forEach((product) => {
           this.discounts.forEach((discount) => {
               if(discount.isApplicable(product)) {
                   totalDiscount += discount.calculate(product);
               }
           });
       });
       
       return totalDiscount;
   }
}

// Example usage:
it.each([
   ['Football', 'sport', 100, 20],
   ['Couch', 'home', 200, 100],
   ['Banana', 'food', 10, 1],
])('calculates discounts for %s category', (productName, category, price, expectedDiscount) => {
   const product = new Product(productName, category, price);
   const basket = new Basket([product]);
   
   expect(new DiscountCalculator([
       new SportCategoryDiscount(),
       new HomeCategoryDiscount(),
       new FoodCategoryDiscount(),
   ]).calculate(basket)).toBe(expectedDiscount);
});
```

We don't need to over-engineer to apply the open-close principle. With the right design pattern, it is quite simple. Now, the discount calculator is more flexible. We didn't introduce a lot of new code but we divided the class into smaller ones. Small classes are easier to test and understand, and it will facilitate the maintenance and the evolution of your application.

