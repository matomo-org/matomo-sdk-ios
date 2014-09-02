Pod::Spec.new do |spec|
  spec.name         = "PiwikTracker"
  spec.version      = "2.5.2"
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
  
  spec.subspec 'AFNetworkingv1' do |afnetworkingv1|
      afnetworkingv1.source_files   = 'PiwikTracker+AFNetworkingv1/*.{h,m,}'
      afnetworkingv1.dependency 'PiwikTracker/Core'
	  afnetworkingv1.dependency 'AFNetworking', '1.3.2'
  end
  
end
