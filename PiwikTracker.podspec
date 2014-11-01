Pod::Spec.new do |spec|
  spec.name         = "PiwikTracker"
  spec.version      = "3.1.1"
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
  	core.source_files = 'PiwikTracker/*.{h,m}'
 	core.osx.exclude_files = 'PiwikTracker/PiwikTrackedViewController.{h,m}'
	core.resources = 'PiwikTracker/piwiktracker.xcdatamodeld'
  	core.ios.frameworks = 'Foundation', 'UIKit', 'CoreData', 'CoreLocation', 'CoreGraphics'
  	core.osx.frameworks = 'Foundation', 'Cocoa', 'CoreData', 'CoreGraphics'
  end

# Can not reference both AFNetworking1 and 2, will create conflicts  
#  spec.subspec 'AFNetworking1' do |afnetworking1|
#      afnetworking1.source_files   = 'PiwikTracker+AFNetworking1/*.{h,m,}'
#      afnetworking1.dependency 'PiwikTracker/Core'
#	  afnetworking1.dependency 'AFNetworking', '1.3.2'
#  end
  
  spec.subspec 'AFNetworking2' do |afnetworking2|
      afnetworking2.source_files   = 'PiwikTracker+AFNetworking2/*.{h,m,}'
      afnetworking2.dependency 'PiwikTracker/Core'
	  afnetworking2.dependency "AFNetworking", '~> 2.0'
  end
  
end
