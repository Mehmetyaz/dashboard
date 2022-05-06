
Dynamic dashboard widget that allows your users to create their own layouts. Rezise, move, indirect resize/move, auto  re-layout are supported.

## Features

[Try online demo](https://styledart.dev/#/dashboard)

Dashboard can be thought of as a dynamic grid. Your users can create their own layouts, add new widgets or remove widgets.

Layout divides the screen into horizontal slots according to the entered value. The aspect ratio of the slots also determine their height. Widgets called DashboardItem are placed in these slots. This layout can be changed later.

<img src="https://github.com/Mehmetyaz/dashboard/blob/master/documentation/slots.png?raw=true" width="400"/>

### Resize

<img src="https://github.com/Mehmetyaz/dashboard/blob/master/documentation/resize.gif?raw=true" width="400"/>

Dashboard Items can be resized both by long pressing on mobile and by holding and moving on desktop/browser.

### Move

<img src="https://github.com/Mehmetyaz/dashboard/blob/master/documentation/move.gif?raw=true" width="400"/>

Dashboard Item locations can be changed by long pressing on mobile or by holding and pulling on desktop/browser.

### Slots Changes

With dynamic slot count, you can re-layout window size changes.

<img src="https://github.com/Mehmetyaz/dashboard/blob/master/documentation/re-layout.gif?raw=true" width="400"/>>


### Storage Delegate

The layout information of the users can be stored in the database or on the local disk.

Define your storage delegate.

```dart
class MyItemStorage extends DashboardItemStorageDelegate {  

  @override  
  FutureOr<List<DashboardItem>> getAllItems(int slotCount) {  
    // return items from db.
  }  
  
  @override  
  FutureOr<void> onItemsUpdated(  
      List<DashboardItem> items, int slotCount) {
      // save new layouts to db.
  }
  //[...]
}
```

And use it.

```dart
DashboardItemController.withDelegate(
    itemStorageDelegate: MyItemsStorage())
```


## Getting started

### Define Dashboard

```dart
Dashboard(  
  dashboardItemController: itemController,  
  itemBuilder: (item) {
	//return widget
  },  
);
```

### Define Items

Items can come from the database, or can be defined as fixed.

Fixed:
```dart
DashboardItemController(items: [
  DashboardItem(width: 2, height: 3, identifier: "id_1"),  
  DashboardItem(  
      startX: 3, startY: 4, width: 3, height: 1, identifier: "id_2"),  
]);
```

Or with delegate:

```dart
DashboardItemController<ADashboardItemImp>.withDelegate(  
    itemStorageDelegate: MyItemStorage())
```

[See example](https://pub.dev/packages/dashboard/example)


### Define Builder

The Builder is invoked with a DashboardItem and returns a widget.

```dart
Dashboard(  
  dashboardItemController: itemController,  
  itemBuilder: (item) {
	return Text(item.identifier);
  },  
);
```

## Parameters

### Item Style

Each item is wrapped with a Material widget. You can enter the parameters of the Material widget with item style.

All is optional.
```dart
ItemStyle(  
  color: Colors.red,  
  borderRadius: BorderRadius.circular(10),  
  shape: const RoundedRectangleBorder(),  
  shadowColor: Colors.black,  
  animationDuration: const Duration(milliseconds: 200),  
  borderOnForeground: false,  
  clipBehavior: Clip.antiAliasWithSaveLayer,  
  elevation: 10,  
  textStyle: const TextStyle(color: Colors.black),  
  type: MaterialType.card  
);
```

#### Slide

Slide to top items initially. Auto relayout places items to top as possible.

```slideToTop: true```

Before: 

<img src="https://github.com/Mehmetyaz/dashboard/blob/master/documentation/before.png?raw=true" width="400"/>>

After: 

<img src="https://github.com/Mehmetyaz/dashboard/blob/master/documentation/after.png?raw=true" width="400"/>>

#### Shrink

Shrink items when re-layout or editing is possible.


### Edit Mode Settings
See code comments for edit mode settings parameters.

All is optional.
````dart
    EditModeSettings(

        // animation settings
        curve: Curves.easeInOutCirc,
        duration: const Duration(milliseconds: 200),
        
        // fill editing item actual size
        fillEditingBackground: true,

        // space that can be held to resize
        resizeCursorSide: 20,
        
        // draw lines for slots
        paintBackgroundLines: true,
        
        // shrink items when editing if possible and necessary
        shrinkOnMove: true,
        
        // long press to edit
        longPressEnabled: true,
        
        // pan to edit
        panEnabled: true,
        
        backgroundStyle: const EditModeBackgroundStyle(
            fillColor: Colors.red,
            lineWidth: 1.5,
            lineColor: Colors.black,
            
            // line by vertical space
            dualLineHorizontal: true,

            // line by horizontal space
            dualLineVertical: true));
````

### Storage Delegate

[See example](https://pub.dev/packages/dashboard/example)

## Additional

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/mehmetyaz)

TODO  
 - [ ] Define and fix animation bugs.
 - [ ] Check performance improvements.
 - [ ] Write tests.
 - [ ] Add more documentation.
 - [ ] Add more example.
 - [ ] Create Youtube video.