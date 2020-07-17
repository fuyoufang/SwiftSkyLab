# SwiftSkyLib

[![CI Status](https://img.shields.io/travis/fuyoufang/SwiftSkyLib.svg?style=flat)](https://travis-ci.org/fuyoufang/SwiftSkyLib)
[![Version](https://img.shields.io/cocoapods/v/SwiftSkyLib.svg?style=flat)](https://cocoapods.org/pods/SwiftSkyLib)
[![License](https://img.shields.io/cocoapods/l/SwiftSkyLib.svg?style=flat)](https://cocoapods.org/pods/SwiftSkyLib)
[![Platform](https://img.shields.io/cocoapods/p/SwiftSkyLib.svg?style=flat)](https://cocoapods.org/pods/SwiftSkyLib)

适用于 iOS 和 Mac 的 A/B 测试框架。 

该框架使用 Swift，模仿 Object-C 版本的 [SkyLab](https://github.com/mattt/SkyLab) 完成。

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Simple A/B Test
```
SwiftSkyLab.abTest("Test1", A: {
    print("Test1 - A")
}, B: {
    print("Test1 - B")
})
```
## Split Test with Weighted Probabilities

```
SwiftSkyLab.splitTest("Test2", conditions: [
    "Red" : 0.15,
    "Green" : 0.10,
    "Blue" : 0.50,
    "Purple" : 0.25
]) { (choice) in
    print("Test2 - \(choice ?? "None")")
}

SwiftSkyLab.splitTest("Test4", conditions: [
    "Red",
    "Green",
    "Blue",
    "Purple"
]) { (choice) in
    print("Test4 - \(choice ?? "None")")
}
```
## Multivariate Test

```
SwiftSkyLab.multivariateTest("Test5", variables: [
    "Red" : 0.15,
    "Green" : 0.10,
    "Blue" : 0.50,
    "Purple" : 0.25
]) { (activeVariables) in
    print("Test5 - \(activeVariables)")
}

SwiftSkyLab.multivariateTest("Test3", variables: [
    "Red",
    "Green",
    "Blue",
    "Purple"
]) { (activeVariables) in
    print("Test3 - \(activeVariables)")
}
```

## Requirements

## Installation

SwiftSkyLib is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftSkyLib'
```

## Author

fuyoufang, fuyoufang@163.com

## License

SwiftSkyLib is available under the MIT license. See the LICENSE file for more info.
