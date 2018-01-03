<p align="center"><img width="150" src ="https://user-images.githubusercontent.com/9360037/34412301-5c2cf4fe-ec17-11e7-8f1b-f487b4cd6218.png"/></p>

[![CI Status](http://img.shields.io/travis/ZhipingYang/FORScrollViewEmptyAssistant.svg?style=flat)](https://travis-ci.org/ZhipingYang/XYDebugView)
[![Version](https://img.shields.io/cocoapods/v/XYDebugView.svg?style=flat)](http://cocoapods.org/pods/XYDebugView)
[![License](https://img.shields.io/cocoapods/l/XYDebugView.svg?style=flat)](http://cocoapods.org/pods/XYDebugView)
[![Platform](https://img.shields.io/cocoapods/p/XYDebugView.svg?style=flat)](http://cocoapods.org/pods/XYDebugView)

> XYDebugView is debug tool to draw the all view's frame in device screen and show it by 2d/3d style like reveal did.

## Use

**Open debug view funtion**
> tap the red statusBar to show or destroy the debug result

```objective-c
// XYDebugViewManager

/**
 开启debug功能，默认使用XYDebugStyle2D对keyWindow进行debug
 */
+ (void)showDebug;

/**
 debug the keyWindow
 */
+ (void)showDebugWithStyle:(XYDebugStyle)debugStyle;

/**
 debug specific view

 @param View the view to debug layout
 @param debugStyle 2d/3d
 */
+ (void)showDebugInView:(nullable UIView *)View withDebugStyle:(XYDebugStyle)debugStyle;
```

**Close debug view funtion**
> dismiss red statusBar & remove debugging

```objective-c
// XYDebugViewManager

/**
 close debug function
 */
+ (void)dismissDebugView;
```


## debug view with 2d

<img width="250" alt="wx20170601-170002 2x" src="https://user-images.githubusercontent.com/9360037/34407789-45fd3d5e-ebfb-11e7-91ca-71eefd1fc97c.png"> <img width="250" alt="wx20170601-170002 2x" src="https://user-images.githubusercontent.com/9360037/34407791-469feae0-ebfb-11e7-8ac1-6f6c4aee9c91.png"> <img width="250" alt="wx20170601-170002 2x" src="https://user-images.githubusercontent.com/9360037/34407792-46d402ee-ebfb-11e7-8776-5e11c6564cbe.png">

## debug with 3d

- support gestures
	- single touch pan: to rotate view angle
	- double touches pan: move the position
	- rotation: rotate z axis
	- pinch: zoom
- recover to init Transform
- other transform
	- change distance between layers (zPosition)
	- prominently the specific layer (alpha)
	- change perspective effect drawings (m34)

<img width="250" alt="wx20170601-170002 2x" src="https://user-images.githubusercontent.com/9360037/34407800-480a2ee0-ebfb-11e7-9ccf-7e945ca5d88d.png"> <img width="250" alt="wx20170601-170002 2x" src="https://user-images.githubusercontent.com/9360037/34407803-4874991a-ebfb-11e7-9a84-c59e0a220077.png"> <img width="250" alt="wx20170601-170002 2x" src="https://user-images.githubusercontent.com/9360037/34407806-4910dc1c-ebfb-11e7-9adb-a1360ea617ed.png">

## debug specific view with 3d

<img width="250" alt="wx20170601-170002 2x" src="https://user-images.githubusercontent.com/9360037/34407793-4707e82a-ebfb-11e7-83c0-104e88a087b7.png"> <img width="250" alt="wx20170601-170002 2x" src="https://user-images.githubusercontent.com/9360037/34407795-4739fd38-ebfb-11e7-9722-318268ce73e1.png"> <img width="250" alt="wx20170601-170002 2x" src="https://user-images.githubusercontent.com/9360037/34407805-48dc4c5e-ebfb-11e7-9dd7-5768d6976f29.png">


## Installation

XYDebugView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "XYDebugView", '~> 1.0.1'
```

## Author

XcodeYang, xcodeyang@gmail.com

## License

XYDebugView is available under the MIT license. See the LICENSE file for more info.
