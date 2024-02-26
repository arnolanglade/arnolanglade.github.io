---
title: How to use custom React hook to increase application testability
date: 2023-04-04
image_credit: joetography
url: software-testing-react-hook
aliases:
    - "how-to-use-custom-react-hook-to-increase-application-testability.html"
    - "how-to-use-custom-react-hook-to-increase-application-testability"
description: "Sometimes, we depend on libraries that provide components which cannot be well rendered in the test environment. That means we cannot test some parts of an application. Learn how to use a React hook to prevent that problem and increase the application testability in this new blog article."
keywords: "react,reactjs,react hook,javascript,typescript,coupling,software,testing,react dependency injection,react dependency inversion,dependency injection,dependency inversion,react testing"
tags: [react, testing]
---

In my previous blog, I spoke about reducing coupling in a React app to improve testing. Now I will show you how a custom React hook can increase testability.

**Note:** I assume that you are comfortable with React hooks. If you aren’t, please have a look at the [React documentation](https://reactjs.org/docs/hooks-intro.html)

First of all, I will show you some code that is not testable. In my [side project](https://mymaps.world), I use `react-map-gl` to create maps with [Mapbox](https://www.mapbox.com/). Unfortunately, I can't render the map with the testing library because this library only works in a web browser. I might have done something wrong but I haven't found any solution to solve this problem.

```tsx
export function MapPage() {
   const {mapId} = useParams<{ mapId: string }>();
   const [markers, setMarkers] = useState([]);
   const [isMarkerOpened, setIsMarkerOpened] = useState(false);


   useEffect(() => {
       setMarkers(getMarkers(mapId));
   }, [mapId]);


   const openMarkerPopup = () => setIsMarkerOpened(true);
   const closeMarkerPopup = () => setIsMarkerOpened(false);


   return (
       <>
           <ReactMapGL>
               {markers.map(
                   (marker) => <Marker
                       longitude={marker.longitude}
                       latitude={marker.latitude}
                   >
                       <MarkerIcon onClick={openMarkerPopup} />
                   </Marker>
               )}
           </ReactMapGL>
           <MarkerPopup isOpened={isMarkerOpened} onClose={closeMarkerPopup} />
       </>
   )
}
```

`MapPage` is in charge of loading map data depending on the `mapId` and rendering a map with its markers. I can’t test the `MapBoard` component because the `ReactMapGL` component can’t be rendered through the test tooling. That’s sad because I still want to check if I can open the marker popup when a user clicks on a marker.

React will help us to fix this issue! We need to refactor this component to extract the business logic into a hook. This way, the component will only be responsible for rendering things. Let’s begin by creating the hooks.

```tsx
export function useMapPage(mapId, {defaultIsMarkerOpened} = {defaultIsMarkerOpened: false}) {
   const [markers, setMarkers] = useState([]);
   const [isMarkerOpened, setIsMarkerOpened] = useState(defaultIsMarkerOpened);


   useEffect(() => {
       setMarkers(getMarkers(mapId));
   }, [mapId]);


   const openMarkerPopup = () => setIsMarkerOpened(true);
   const closeMarkerPopup = () => setIsMarkerOpened(false);


   return {
       markers,
       isMarkerOpened,
       closeMarkerPopup,
       openMarkerPopup,
   }
}
```
The hook exposes two variables: `markers` which is an array of map’s markers and `isMarkerOpened` which is a boolean that indicates if the popup is opened or closed. It exposes two functions, `openMarkerPopup` and `closeMarkerPopup` that let us mutate the `isMarkerOpened` boolean.

**Note:** We could only expose `setIsMarkerOpened` but I think `openMarkerPopup` and `closeMarkerPopup` function names are clearer and match the component logic.

Now, we need to call the hook from the `MapPage` component and it will still work as before.

```tsx
export function MapPage() {
   const {
       markers,
       isMarkerOpened,
       closeMarkerPopup,
       openMarkerPopup
   } = useMapPage(mapId);


   return (
       <>
           <ReactMapGL>
               {markers.map(
                   (marker) => <Marker
                       longitude={marker.longitude}
                       latitude={marker.latitude}
                   >
                       <MarkerIcon onClick={openMarkerPopup} />
                   </Marker>
               )}
           </ReactMapGL>
           <MarkerPopup isOpened={isMarkerOpened} onClose={closeMarkerPopup} />
       </>
   )
}
```

The `MapPage` is still untestable but we can start testing the hook to ensure hook logic matches business expectations. We can test if we can open a marker’s popup. That’s great because the testing library provides the `renderHook` helper that eases the hook testing.

**Note:** If you want to know how `renderHook` works you should have a look at this [blog post](https://kentcdodds.com/blog/how-to-test-custom-react-hooks) written by [Kent C. Dodds](https://twitter.com/kentcdodds).

```tsx
describe('Map Page', () => {
   test('should open the marker popup', async () => {
       const { result } = renderHook(() => useMapPage(
           'mapId', {defaultIsMarkerOpened: false}
       ));
       
       act(() => result.current.openMarkerPopup());
       
       expect(result.current.isMarkerOpened).toEqual(true);
   });


   test('should close the marker popup', async () => {
       const { result } = renderHook(() => useMapPage(
           'mapId', {defaultIsMarkerOpened: true}
       ));
       
       act(() => result.current.closeMarkerPopup());

       expect(result.current.isMarkerOpened).toEqual(false);
   });
});
```

As I said at the beginning of this blog post I wrote a blog post to explain how to reduce coupling in a React application. Please, have a look at this [blog post](/how-to-reduce-coupling-in-your-react-app.html) to understand how to make a dependency injection system.

Now, we need to remove the `getMarkers` function call from the hooks if we want to test the map data loading. We don’t want to trigger side effects like HTTP calls in the unit test suite because we want to have the shortest feedback loop. We will get the `getMarkers` function to `useServiceContainer` which is a hook that provides any services.

```tsx
export function useMapPage(mapId, {defaultIsMarkerOpened} = {defaultIsMarkerOpened: false}) {
   const {getMarkers} = useServiceContainer();
   // ...
  
   useEffect(() => {
       setMarkers(getMarkers(mapId));
   }, [mapId]);
   // ...
}
```

By default, the `useServiceContainer` hooks return the production services, we will need to replace the `getMarkers` service with a fake service for testing purposes. The  `useServiceContainer` hooks can’t work without a React Provider. I like to create a factory that wraps components I test with all needed providers. It avoids a lot of noise in the test suites and makes tests more readable.

```tsx
export const createWrapper = (serviceContainer) => function Wrapper(
   { children }: { children: ReactElement },
) {
   return (
       <ContainerContext.Provider value={serviceContainer}>
           {children}
       </ContainerContext.Provider>
   );
};
```

Note: the factory has a parameter which is the service container. It will let us define the services we want to override for testing.

The `renderHook` has a `wrapper` option that lets you define the component that will wrap the hook you are testing. We will use the `createWrapper` factory to wrap the hook into the `ContainerContext` provider and we create a fake `getMarkers` service.

```tsx
describe('Map Page', () => {
   test('should load the markers of the map', async () => {
       const markers = [{id: 'makerId'}];
       const { result } = renderHook(
           () => useMapPage('mapId'),
           {wrapper: createWrapper({getMarkers: () => markers})}
       );
       
       expect(result.current.markers).toEqual(markers);
   });
});
```

Now, the `getMarkers` is predictable. That means we can test the map loading because the `getMarker` function will return `[{id: 'makerId'}]` every time.

Thanks to my proofreader [@LaureBrosseau](https://www.linkedin.com/in/laurebrosseau).
