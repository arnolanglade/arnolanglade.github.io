---
title: How to reduce coupling in your React app
description: "The dependency inversion principle is a great design pattern, it makes applications more modular and easier to test. A React Context can help to implement this pattern in a React application. Learn how in this new blog article."
date: 2023-03-06
image: how-to-reduce-coupling-in-your-react-app.webp
alt: How to reduce coupling in your React app
image_credit: diana_pole
keywords: "react,dependency injection,dependency inversion,typescript,coupling,software,design pattern"
tags: [react, design-patterns]
---

Today, I would like to cover dependency injection in React. I worked with several frameworks using tools to build and inject dependencies. It is pretty convenient if you apply the dependency inversion principle because you can easily change a dependency with another one.

I will start by briefly introducing what is a React Context and I will then show you how to solve coupling problems in a React application.

## What is a React Context?

> Context provides a way to pass data through the component tree without having to pass props down manually at every level.
>
> [React documentation](https://reactjs.org/docs/context.html)

Let’s take an example: several components display the username of the user who is connected. We have to pass the username as props to every application component that needs this information. It is annoying, but React context can help for this specific use case.

First, we need to create a context:

```ts self-taught
const UserContext = React.createContext<string>();
```

Then, we need to wrap our components using a context provider and give it a value. The value is the data we want to share with the provider’s children components.

```tsx
function App() {
    return (
        <UserContext.Provider value={'arn0'}>
            <Toolbar />
            <OtherComponent />
        </UserContext.Provider>
    );
}
```

Finally, we can get this value (the username) from the context thanks to the useContext hooks.

```tsx
function Toolbar() {
    const username = useContext(UserContext);

    return (
        <div>
            Welcome {username}
        </div>
    );
}

```
## Which problems coupling brings?

> Coupling is the degree of interdependence between software modules; a measure of how closely connected two routines or modules are; the strength of the relationships between modules.
>
> [Wikipedia](https://en.wikipedia.org/wiki/Coupling_(computer_programming))

The developer's worst enemy is **coupling** because it makes your code less testable. To illustrate what I am saying we will take an example: a to-do list application. The `TodoList` component is responsible for retrieving data from the server and building the list of tasks to do.

```tsx
const findTasks = async () => {
    return await axios.get('/tasks');
}

function TodoList() {
    const [tasks, setTasks] = useState<Task[]>([]);

    useEffect(() => {
        (async () => {
            const response = await findTasks();
            setTasks(response.data);
        })();
    }, []);
    
    return (
        <ul>
            {tasks.map((task: Task) => <li key={task.id}>{task.label}</li>)}
        </ul>
    );
}
```

The problem with the `TodoList` component is that it depends on the `axios` library to get data from the server. It does not ease testing because we need to set up the server to make this component work. Unit testing requires a short feedback loop! We need to find a way to get rid of this HTTP call. It would be great to be able to do HTTP calls in production but using stub for testing.

## How React Context reduces coupling?

The problem with the `TodoList` component is that we should be able to use several implementations of the `findTasks`, but we can’t with its design. We need an implementation for the production that will make an HTTP call and another one for testing that will return stub.

The `findTasks` function should not be hardcoded but it should be injected as a component dependency. A React Context will help us to solve that issue.

```tsx
type ServiceContainer = {findTasks: () => Promise<Task>};

const ContainerContext = React.createContext<ServiceContainer>({} as ServiceContainer);

export const useServiceContainer = () => useContext(ContainerContext);

const findTasks = async () => {
    return await axios.get('/tasks');
}

function App() {
    return (
        <ContainerContext.Provider value={findTasks}>
            <TodoList/>
        </ContainerContext.Provider>
    );
}
```

The `ServiceContainer` type represents all services we want to register in our application. The `ContainerContext` will share those services with `ContainerContext.Provider` children.

Then, we only need to get the `findTasks` function from the React Context.

```tsx
function TodoList() {
    const {findTasks} = useServiceContainer();
    const [tasks, setTasks] = useState<Task[]>([]);

    useEffect(() => {
        (async () => {
           const response = await findTasks();
           setTasks(response.data);
        })();
    }, []);

    return (
        <ul>
            {tasks.map((task: Task) => <li key={task.id}>{task.label}</li>)}
        </ul>
    );
}
```

Now, the code is testable because we can easily replace the `findTasks` by stub in the test suite. We can easily set up a test because this new function does not use HTTP calls.

```tsx
it('render the todo list', () => {
    render(
        <ContainerContext.Provider value={
            { findTasks: () => ({id: 1, label: 'label'}) }
        }>
            <TodoList/>
        </ContainerContext.Provider>
    )

    // …
});
```

Thanks to my proofreader [@LaureBrosseau](https://www.linkedin.com/in/laurebrosseau).
