#
# Be sure to run `pod lib lint ColorThiefSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ColorThiefSwift'
  s.version          = '0.5.0'
  s.summary          = 'Grabs the dominant color or a representative color palette from an image.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Grabs the dominant color or a representative color palette from an image.
A Swift port of same name libraries of JavaScript and Java.
  DESC

  s.homepage         = 'https://github.com/yamoridon/ColorThiefSwift'
  s.screenshots     = 'https://github.com/yamoridon/ColorThiefSwift/raw/master/screenshot.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kazuki Ohara' => 'kazuki.ohara@gmail.com' }
  s.source           = { :git => 'https://github.com/yamoridon/ColorThiefSwift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/yamoridon'

  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '4.0'
  s.macos.deployment_target = '10.13'
  s.swift_version = '5.0'

  s.source_files = 'ColorThiefSwift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ColorThiefSwift' => ['ColorThiefSwift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.ios.frameworks = 'UIKit'
  s.tvos.frameworks = 'UIKit'
  s.watchos.frameworks = 'UIKit'
  s.macos.frameworks = 'AppKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
