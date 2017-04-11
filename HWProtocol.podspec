#
#  Be sure to run `pod spec lint HWProtocol.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|


  s.name         = "HWProtocol"
  s.version      = "1.1.2"
  s.summary      = "Protocol extension for Objective-C"

  s.description  = <<-DESC
                  Protocol extension for Objective-C
                   DESC

  s.homepage     = "https://github.com/chunzhiying"

  s.license      = "MIT "


  s.author       = { "chunzhiying" => "chun.zhiying.ggl@gmail.com" }

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/chunzhiying/HWProtocol.git", 
                     :tag => "#{s.version}" }

  s.source_files  = "Source/**/*.{h,m}"

  s.frameworks = "Foundation"

end
