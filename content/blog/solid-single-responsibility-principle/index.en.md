---
title: "SOLID principles: Understanding the single responsibility principle"
date: 2024-03-19
image_credit: designedbyflores
url: solid-single-responsibility-principle
description: The single responsibility principle (SRP) is a software engineering rule that can help developers write code that is more maintainable and testable. By following this principle, developers can break down complex problems into smaller, more manageable units of code, which makes the code easier to understand and maintain.
keywords: Single Responsibility Principle,SRP,SOLID Principles,SOLID,Code Modularity,Software Development,Object-Oriented Programming,OOP,software design,code quality
tags: [OOP, SOLID]
---

The single responsibility principle (SRP) is the first of the five SOLID principles. It may be the simplest SOLID principles to understand, but it is not always easy to apply, especially if you’re a junior developer. What does this principle say?

>There should never be more than one reason for a class to change. In other words, every class should have only one responsibility
>
>[wikipedia](https://en.wikipedia.org/wiki/SOLID)

SPR can be challenging to apply because it requires developers to break down complex problems into smaller, more manageable units of code. Identifying and isolating responsibilities can be challenging, and if done incorrectly, it can lead to poor design decisions.

Let’s take an example. The following class is in charge of importing products into an application as a PIM or an ERP.
```ts
type Product = {
  name: string
  description: string
};

class ProductImport {
  constructor(private connection: Connection) {}


  async import(filePath: string): Promise<void> {
    await this.loadProductFromCsvFile(filePath);
  }
  
  private async loadProductFromCsvFile(file: string): Promise<void> {
    const csvData: Product[] = [];
    createReadStream(file)
      .pipe(csvParser())
      .on('data', (product: Product) => csvData.push(product))
      .on('end', async () => {
      for (const data of csvData) {
        await this.saveProducts(data);
      }
    });
  }

  private async saveProducts(product: Product): Promise<void> {
    await this.connection.execute(
      'INSERT INTO products (name, description) VALUES (?, ?)',
      [product.name, product.description],
    );
  }
}
```

This `ProductImport` class does several things, it gets product data from a CSV file and imports them into a database. That means it has multiple responsibilities which violates the single responsibility principle (SRP).

{{< image src="product-import-responsibilities.svg" alt="Product import responsibilities" >}}

We need to break down this class into smaller ones to isolate responsibilities and make it compliant with the single responsibility principle. We will create a new class called  `CsvProductLoader ` that will load the product data from the CSV file, and we will create a second class called  `MysqlProducts` that will be responsible for saving product data into the database."

```ts
class CsvProductLoader {
  async loadProduct(file: string): Promise<Product[]> {
    const products: Product[] = [];
    createReadStream(file)
      .pipe(csvParser())
      .on('data', (product: Product) => products.push(product));
    
    return products;
  }
}

class MysqlProducts {
  constructor(private connection: Connection) {}
    
  async save(product: Product): Promise<void> {
    await this.connection.execute(
      'INSERT INTO products (name, description) VALUES (?, ?)',
      [product.name, product.description],
    );
  }
}
```

We still need the `ProductImport` class. It acts as a controller and is responsible for orchestrating the interactions between the `CsvProductLoader` and `MysqlProducts` classes. The `ProductImport` class doesn't need to handle any of the low-level data processing or database operations. Its primary responsibility is to delegate the tasks of loading and saving data to the specialized classes. This separation of concerns promotes modularity and makes the code more maintainable.

```ts
class ProductImport {
  constructor(
    private productLoader: CsvProductLoader,
    private products: MysqlProducts,
  ) {}
    
  async import(filePath: string): Promise<void> {
    const products = await this.productLoader.loadProduct(filePath);
    products.forEach((product: Product) => this.products.save(product));
  }
}
```

There is a last thing to improve in this code example. The `ProductImport` class currently relies on concrete classes, which doesn't adhere to the Dependency Inversion principle because high-level modules should not depend on low-level modules directly. To address this, we need to introduce interfaces to abstract away the dependencies in the `ProductImport` class.

```ts
interface ProductLoader {
  loadProduct(file: string): Promise<Product[]>
}

interface ProductLoader {
  save(product: Product): Promise<void>
}

class ProductImport {
  constructor(
    private productLoader: ProductLoader,
    private products: ProductLoader,
  ) {}
}
```
I’ve written an article about the Dependency Inversion Principle (DIP), which explains the principle and how it helps to make testing easier:

{{< page-link page="solid-dependency-inversion-principle" >}}

{{< training-link >}}

The biggest benefit  of working with small classes is that it eases testing. The original `ProductImport` class required a working database and the ability to read files from the filesystem. This doesn't help with having a short feedback loop. Testing code that involves IO operations is more complicated because the code cannot be executed without the tools required by the application. Splitting massive classes into smaller ones helps isolate the IO operations and makes your code more testable.

I've written an article about how the Single Responsibility Principle (SRP) helps with easy testing, especially when your classes are huge, and you want to test their private methods:

{{< page-link page="do-not-test-private-methods" >}}

Creating good code is like playing with Lego bricks. It involves working on small, easily testable classes and assembling them using composition to build more complex features.
