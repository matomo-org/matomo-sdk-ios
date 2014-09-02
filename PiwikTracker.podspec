Pod::Spec.new do |spec|
  spec.name         = "PiwikTracker"
  spec.version      = "2.6.0"
  spec.summary      = "A Piwik tracker written in Objective-C for iOS and OSX apps."
  spec.homepage     = "https://github.com/piwik/piwik-sdk-ios/"
  spec.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.author       = { "Mattias Levin" => "mattias.levin@gmail.com" }
  spec.source       = { :git => "https://github.com/piwik/piwik-sdk-ios.git", :tag => "v#{spec.version}" }
  spec.ios.deployment_target = '7.0'
  spec.osx.deployment_target = '10.8'
  spec.requires_arc = true
  spec.default_subspecs = 'Core'
  
  spec.subspec 'Core' do |core|
  	core.ios.source_files = 'PiwikTracker/*.{h,m,xcdatamodeld}'
 	core.osx.exclude_files = 'PiwikTracker/PiwikTrackedViewController.{h,m}'
  	core.ios.frameworks = 'Foundation', 'UIKit', 'CoreData', 'CoreLocation', 'CoreGraphics'
  	core.osx.frameworks = 'Foundation', 'Cocoa', 'CoreData', 'CoreGraphics'
  end
  
  spec.subspec 'AFNetworking1' do |afnetworking1|
      afnetworking1.source_files   = 'PiwikTracker+AFNetworking1/*.{h,m,}'
      afnetworking1.dependency 'PiwikTracker/Core'
	  afnetworking1.dependency 'AFNetworking', '1.3.2'
  end
  
end
