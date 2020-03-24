# Custom Keyboard

![Custom Keyboard](https://github.com/huubao2309/touch_show_widget/blob/master/images/popover.gif)

## Use

```dart
child: CupertinoPopoverButton(
  child: Container(
    // ...
  ),
  popoverBuild: (context) {
     return CupertinoPopoverMenuList(
       children: <Widget>[
         CupertinoPopoverMenuItem(
           leading: Icon(Icons.add),
           child: Text("Insert"),
          ),
         CupertinoPopoverMenuItem(
           // ...
         ),
         // ...
       ],
     );
  },
),
```
