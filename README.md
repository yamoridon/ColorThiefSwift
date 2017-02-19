# ColorThiefSwift

Grabs the dominant color or a representative color palette from an image.
A Swift port of Sven Woltmann's Java implementation.

![screen shot](https://github.com/orchely/ColorThiefSwift/blob/master/screenshot.png?raw=true "screen shot")

[![CI Status](http://img.shields.io/travis/orchely/ColorThiefSwift.svg?style=flat)](https://travis-ci.org/orchely/ColorThiefSwift)
[![Version](https://img.shields.io/cocoapods/v/ColorThiefSwift.svg?style=flat)](http://cocoapods.org/pods/ColorThiefSwift)
[![License](https://img.shields.io/cocoapods/l/ColorThiefSwift.svg?style=flat)](http://cocoapods.org/pods/ColorThiefSwift)
[![Platform](https://img.shields.io/cocoapods/p/ColorThiefSwift.svg?style=flat)](http://cocoapods.org/pods/ColorThiefSwift)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 8
- Swift 2
  - Swift 3 version will be available soon!

## Installation

ColorThiefSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ColorThiefSwift"

# Support Swift 2 only for now
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
	    config.build_settings['SWIFT_VERSION'] = '2.3'
	  end
  end
end
```

## Author

Kazuki Ohara kazuki.ohara@gmail.com

## License

ColorThiefSwift is available under the MIT license. See the LICENSE file for more info.

## Thanks

- Sven Woltmann - for the Java Implementation. ColorThiefSwift is a port of this.
- https://github.com/SvenWoltmann/color-thief-java
- Lokesh Dhakar - for the original JavaScript version.
- http://lokeshdhakar.com/projects/color-thief/
- https://github.com/lokesh/color-thief/
