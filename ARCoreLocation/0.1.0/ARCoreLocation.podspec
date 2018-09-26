Pod::Spec.new do |s|

  s.platform     = :ios
  s.ios.deployment_target = '11.0'
  s.name         = "ARCoreLocation"
  s.version      = "0.1.0"
  s.summary      = "Place AR landmarks on real-world locations."

  s.description  = <<-DESC
                ARCoreLocation is a lightweight iOS framework for displaying AR content
                at real-world coordinates.
                   DESC

  s.homepage     = "https://github.com/FreshworksStudio/arcorelocation"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Skyler Smith" => "skyler@freshworks.io" }

  s.source       = { :git => "https://github.com/FreshworksStudio/arcorelocation.git",
                     :tag => "#{s.version}" }

  s.source_files  = "ARCoreLocation/**/*.{swift}"

#s.resources = "ARCoreLocation/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

  s.frameworks = "UIKit", "ARKit", "CoreLocation", "GLKit"

  s.swift_version = "4.2"

end
