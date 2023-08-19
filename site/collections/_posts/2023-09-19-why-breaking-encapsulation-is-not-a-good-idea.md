---
title: Why breaking encapsulation is not a good idea
description: "This principle restricts direct access to the state of the object from outside. This means that the internal implementation details of a class are hidden. Accessing the state of the object is only allowed through its public API (public methods). This concept helps to protect the data from outside interference and ensures controlled and secure data manipulation."
date: 2023-09-19
image: why-breaking-encapsulation-is-not-a-good-idea/why-breaking-encapsulation-is-not-a-good-idea.webp
alt: Why breaking encapsulation is not a good idea
image_credit: mattseymour﻿
keywords: "oop,encapsulation,object,tell don’t ask,object"
tags: [testing, oop]
---

In this blog post, I would like to speak about an important concept in Oriented Object Programming which is the encapsulation principle.

Before speaking about encapsulation let's talk a bit about OOP. What is the object's life cycle? The first step of the object’s life cycle is to be instantiated. We give everything an object needs to initialise its internal state. Then we use its public API (public methods) to communicate with it. An object exposes a public API (behaviour) that manipulates its internal state (data).

![Object life cycle](images/posts/why-breaking-encapsulation-is-not-a-good-idea/object-life-cycle.svg)

So, what is encapsulation? This principle restricts direct access to the state of the object from outside. This means that the internal implementation details of a class are hidden. Accessing the state of the object is only allowed through its public API (public methods). This concept helps to protect the data from outside interference and ensures controlled and secured data manipulation.

**Note:** An object that only has getters and setters is not an object! This is a data structure because it has no behaviour.

I worked on many applications that used getters and setters. They are good examples of what is breaking encapsulation. It is easy to break encapsulation but it is not a good idea. It will make your code less maintainable and your applications less evolutive. Let’s take a simple example to understand why breaking encapsulation is a bad idea. I want to find the closest point of interest on a map close to a given location. 

```ts
type Location = {
  latitude: number
  longitude: number
}


type PointOfInterest = {
  name: string
  location: Location
}

class Map {
  constructor(private pointOfInterests: PointOfInterest[]) {}


  getPointOfInterests(): PointOfInterest[] {
    return this.pointOfInterests
  }
}

class AClassWhereWeNeedToFindClosestPOI {
  doSomething(map: Map) {
    const pointOfInterest = map.getPointOfInterests()
      .filter((pointOfInterest: PointOfInterest) => {
        // ...
      })[0]
    // ...
  }
}
```

The `Map` class has a `getPointOfInterest` getter that gets the class property with the same name. Then we can use this getter to access the list of points of interest to iterate them and find the closest one. 

The drawback with this getter is that we will need to copy/paste this piece of code if we have to look for the closest point of interest in several places. It won’t help you to mutualize code. At best, you can extract this piece of code into a dedicated class like the following example:


```ts
class POIFinder {
  find(map: Map): PointOfInterest {
    return map.getPointOfInterests()
      .filter((pointOfInterest: PointOfInterest) => {
        // ...
      })[0]
  }
}
```

The problem with this code is that we extract the `Map` object behaviour into another class. We will turn the `Map` object into a data structure if we remove all methods that add a behaviour to it.

**Note:** A class that ends with -ER (like in the previous example) is a good insight into how this class does the job of another class.

What happens if we need to change the internal of the POI list? Now, we don’t want to use an array anymore, we want to manage the POI list with a custom class named `PointOfInterestList`. It might be a simple refactoring for small applications but it is super painful for huge ones. If the getter method is used hundreds of times, we will have to refactor each `getPointOfInterest` usage to make them compatible with the new signature.

To avoid this problem, we only need to apply the “Tell, don’t ask” principle. This principle says that we should tell an object to do something instead of asking for its internal state to do something in his stead.
 
The solution would be to add a `findClosestPointOfInterest` method to the `Map` object. The only purpose of this method is to find the closest POI no matter how the POI list is designed. This allows you to refactor the internal state of the object as many times you want. 

```ts
class ListOfPointOfInterest {
  findClosest() {
    // ...
  }
}

class Map {
  constructor(private pointOfInterests: PointOfInterest[]) {}


  findClosestPointOfInterest(location: Location): PointOfInterest {
    return this.pointOfInterests.findClosest()
  }
}
```

**Note:** Breaking encapsulation to test your code is a bad idea too. I wrote an article to present you with an alternative to the getter to prevent exposing the state of the objects. Here is the link [Why you should not expose objects' state to test them](https://arnolanglade.github.io/you-should-not-expose-objects-state-to-test-them.html)

Thanks to my proofreader [@LaureBrosseau](https://www.linkedin.com/in/laurebrosseau).
