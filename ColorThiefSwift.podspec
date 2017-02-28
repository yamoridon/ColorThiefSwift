#
# Be sure to run `pod lib lint ColorThiefSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ColorThiefSwift'
  s.version          = '0.1.4'
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

  s.homepage         = 'https://github.com/orchely/ColorThiefSwift'
  s.screenshots     = 'https://github.com/orchely/ColorThiefSwift/raw/master/screenshot.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kazuki Ohara' => 'kazuki.ohara@gmail.com' }
  s.source           = { :git => 'https://github.com/orchely/ColorThiefSwift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/orchely'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ColorThiefSwift/Classes/*.swift'
  
  # s.resource_bundles = {
  #   'ColorThiefSwift' => ['ColorThiefSwift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
