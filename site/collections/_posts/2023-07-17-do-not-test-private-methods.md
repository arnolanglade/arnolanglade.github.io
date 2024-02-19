---
title: Don’t test private methods
description: "One of the first mistakes I made when I started to test my code was to test private methods. Spoiler alert: it was a bad idea! If you need to test a private method, it probably means that your code is not well designed. Private methods are implementation details of objects and we should not care about them. When you test public methods you also test the private ones."
date: 2023-07-17
image: do-not-test-private-method/do-not-test-private-methods.webp
alt: Don’t test private methods
image_credit: dtopkin1
keywords: "unit test,design pattern,pattern,software,private method,single responsibility principle,test"
tags: [testing, OOP]
---

It is pretty easy to make mistakes when you start testing your code. One of the first mistakes I made was to test private methods. Spoiler alert: it was a bad idea because I had to use reflection to make them public to access them. If you need to test a private method, it probably means that your code is not well designed

We don’t test private methods. Private methods are implementation details of objects and we should not care about them. Don’t worry! They are tested in the end. When you test public methods you also test the private ones as described in the next schema.

![Test private methods through public ones](images/posts/do-not-test-private-method/test-private-methods-through-public-ones.svg)

I needed to test the private methods because my object was a God object (huge object). It did a lot of things. It had a few public methods and a lot of private ones because too many things happened behind the scenes.

![Object with too many private methods](images/posts/do-not-test-private-method/object-with-too-many-private-methods.svg)

The problem with this design is this object did not follow the **S**ingle **R**esponsibility **P**rinciple, but what is this principle?

>There should never be more than one reason for a class to change. In other words, every class should have only one responsibility
>
>[wikipedia](https://en.wikipedia.org/wiki/SOLID)

My object was super huge because it did too many things. It had too many responsibilities. Because of that, I could not test it easily. How can we avoid that?

![complicated to test objects with many responsibilities](images/posts/do-not-test-private-method/complicated-to-test-objects-with-many-responsibilities.svg)

It’s better to work on small problems than a big one. The solution would have been to identify each responsibility to extract them into dedicated objects. We don't need magic tricks to test small objects. It is simple to test them because they do a simple thing, and we only need to use their public API (public method) to test them. We don't need reflection anymore.

![split good objects into small classes](images/posts/do-not-test-private-method/split-good-objects-into-small-classes.svg)

Then, we need to apply the composition pattern to assemble those classes to make them work as the God object. Composition is like playing Lego: we have many small bricks, and we put them together to make a big piece. Software is the same. You should work with small classes/functions to easily test them and piece them together to make your feature.

{% include training-link.html %}

Let’s take an example. The following class is in charge of importing products into an application as a PIM or an ERP. This class does several things, it gets product data from a CSV file and it imports them into a database. We need to test the whole class to ensure the product import works as expected. That’s a bit annoying because I can’t test the CSV file reading or the production saving.

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

We need to split this class into smaller ones to ease testing. We will extract both private methods into dedicated classes.

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
Now, we can test them stand-alone because these classes expose public methods. We don’t need a magic trick such as reflection to change their visibility to test them.

We still need the `ProductImport` class. It will depend on both previous classes and act as a controller. It asks `CsvProductLoader` to get the product information from the CSV file and asks `CsvProductLoader` to save them into a database.

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

That's great because we extract IO usage into new classes. Both `MysqlProducts` and `CsvProductLoader` need to be tested with integration/contract tests since `ProductImport` can be unit tested.

We need to make a last change. We cannot rely on concrete classes. We need to introduce interfaces to avoid coupling between `ProductImport` and its dependencies (`MysqlProducts` and `CsvProductLoader`).

```ts
interface ProductLoader {
  loadProduct(file: string): Promise<Product[]>
}

interface Products {
  save(product: Product): Promise<void>
}

class ProductImport {
  constructor(
    private productLoader: ProductLoader,
    private products: Products,
  ) {}
}
```

**Note**: I've written an article about how the inversion dependency design pattern will ease testing. Here is the link: 

{% include blog-post-link.html url='/ease-testing-thanks-to-the-dependency-inversion-design-pattern.html' image='inversion-dependency/ease-testing-thanks-to-the-dependency-inversion-design-pattern.webp' title='Ease testing thanks to the dependency inversion design pattern' %}


Thanks to my proofreader [@LaureBrosseau](https://www.linkedin.com/in/laurebrosseau).
