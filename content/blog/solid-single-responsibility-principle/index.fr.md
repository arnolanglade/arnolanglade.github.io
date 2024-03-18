---
title: "Les principes SOLID : Comprendre le principe de responsabilité unique"
date: 2024-03-25
image_credit: designedbyflores
url: solid-single-responsibility-principle
description: "Le principe de responsabilité unique (SRP) est une règle d'ingénierie logicielle qui peut aider les développeurs à écrire du code plus maintenable et testable. En suivant ce principe, les développeurs peuvent décomposer des problèmes complexes en unités de code plus petites et plus gérables, ce qui rend le code plus facile à comprendre et à maintenir."
keywords: "Principe de Responsabilité Unique, Single Responsibility Principle,SRP,SOLID Principles,SOLID,Code modulaire,Software Development logiciel,Object-Oriented Programming, Programmation Orienté Objet,POO,OOP"
tags: [OOP, SOLID]
---

Le principe de responsabilité unique (Single Responsibility Principle) est le premier des cinq principes SOLID. Il peut être le principe SOLID le plus simple à comprendre, mais il n'est pas toujours facile à appliquer, surtout si vous êtes un développeur junior. Que dit ce principe ?

>There should never be more than one reason for a class to change. In other words, every class should have only one responsibility
>
>[wikipedia](https://en.wikipedia.org/wiki/SOLID)

SRP peut être difficile à appliquer car il nécessite des développeurs de décomposer des problèmes complexes en unités de code plus petites et plus gérables. Identifier et isoler les responsabilités peut être difficile, et si cela est fait de manière incorrecte, cela peut conduire à de mauvaises décisions de conception.

Prenons un exemple. La classe suivante est chargée d'importer des produits dans une application en tant que PIM ou ERP.

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

Cette classe `ProductImport` fait plusieurs choses : elle récupère les données des produits à partir d'un fichier CSV et les importe dans une base de données. Cela signifie qu'elle a plusieurs responsabilités, ce qui viole le principe de responsabilité unique (SRP).

{{< image src="product-import-responsibilities.svg" alt="Product import responsibilities" >}}

Nous devons diviser cette grosse classe en plusieurs petites classes pour isoler les responsabilités et la rendre conforme au principe de responsabilité unique. Nous allons créer une nouvelle classe appelée `CsvProductLoader` qui chargera les données des produits à partir du fichier CSV, et nous créerons une seconde classe appelée `MysqlProducts` qui sera responsable de sauvegarder les données des produits dans la base de données.

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

Nous avons toujours besoin de la classe `ProductImport`. Elle agit comme un contrôleur et est responsable de l'orchestration des interactions entre les classes `CsvProductLoader` et `MysqlProducts`. La classe `ProductImport` n'a pas besoin de gérer des traitements de données de bas niveau ou des opérations de base de données. Sa responsabilité principale est de déléguer les tâches de lecture et de sauvegarde des données aux classes spécialisées. Cette séparation des responsabilités favorise la modularité et rend le code plus maintenable.

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

Il reste une dernière chose à améliorer dans cet exemple de code. La classe `ProductImport` dépend actuellement de classes concrètes, ce qui ne respecte pas le principe d'Inversion de Dépendance, car les modules de haut niveau ne devraient pas dépendre directement des modules de bas niveau. Pour remédier à cela, nous devons introduire des interfaces pour abstraire les dépendances dans la classe `ProductImport`.

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
J'ai écrit un article sur le Principe d'Inversion de Dépendance (DIP) qui explique le principe et comment il facilite les tests :

{{< page-link page="solid-dependency-inversion-principle" >}}

{{< training-link >}}

Le plus grand avantage de travailler avec de petites classes est qu'il facilite les tests. La classe `ProductImport` originale nécessitait une base de données fonctionnelle et la capacité de lire des fichiers du système de fichiers. Cela ne facilite pas l'obtention d'une boucle de feedback courte. Tester du code impliquant des opérations d'entrée/sortie (Input/Output) est plus compliqué parce que le code ne peut pas être exécuté sans les outils requis par l'application. Diviser de grosses classes en plus petites aide à isoler les opérations d'entrée/sortie (Input/Output) et rend votre code plus testable.

J'ai écrit un article sur la manière dont le Principe de Responsabilité Unique (SRP) facilite les tests, surtout lorsque vos classes sont énormes et que vous souhaitez tester leurs méthodes privées :

{{< page-link page="do-not-test-private-methods" >}}

Créer du bon code est comme jouer avec des briques Lego. Cela implique de travailler sur des classes petites et facilement testables et de les assembler en utilisant la composition pour construire des fonctionnalités plus complexes.
