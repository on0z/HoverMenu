# HoverMenu
This is simple popover menu.
You don't have to raise your finger when choosing a menu.

<img src="https://raw.githubusercontent.com/on0z/HoverMenu/materials/materials/HoverMenu.png" alt="APNG画像" height="600">

How to use (Minimum code. Please see ViewController3 in Demo)

1. make button in menu

```
let width = 50
let height = 30
let button = HoverMenuButton(
    size: (width, height),
    setView: {$0.backgroundColor = UIColor.red},    // (UIView) -> Void
    handler: {button, gesture in print("didTap")}   // (HoverMenuButton, UIGestureRecognizer) -> Void
)
```

1. make menu

```
/// target: UIViewController        ViewController on which you want to present a menu.
/// buttons: [HoverMenuButton]      buttons which you want to view
/// delegate: HoverMenuDelegate     delegate
let menu = HoverMenuController(target: self, buttons: [button], delegate: nil)
```

1. set direction, axis, popover sourceView (or BarButtonItem)

```
menu.direction = .up        // up(default), down, left, right
menu.axis = .horizontal     // horizontal(default), vertical
let rect = CGRect.zero
let view = UIView(...)
menu.sourceRectView = (rect: rect, view: view)
//menu.sourceBarButton = UIBarButtonItem(...)
```

1. set launch button

```
let launchButton = UIView(...)
...
/// target: menu which you want to present
let gesture = HoverGestureRecognizer(target: menu)
lauchButton.addGestureRecognier(gesture)
```

1. In a class that inherits HoverMenu delegate, add such code.

```
func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    if controller.presentedViewController is HoverMenuController{
        //Requires return .none
        return .none
    }
    
    // Your code...
    
    return controller.presentedViewController.modalPresentationStyle
}
```
