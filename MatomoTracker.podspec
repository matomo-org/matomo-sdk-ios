Pod::Spec.new do |spec|
  spec.name         = "MatomoTracker"
  spec.version      = "7.5.2"
  spec.summary      = "A Matomo Tracker written in Swift for iOS, tvOS and macOS apps."
  spec.homepage     = "https://github.com/matomo-org/matomo-sdk-ios/"
  spec.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.author       = { "Mattias Levin" => "mattias.levin@gmail.com", "Cornelius Horstmann" => "site-github@brototyp.de" }
  spec.source       = { :git => "https://github.com/matomo-org/matomo-sdk-ios.git", :tag => "v#{spec.version}" }
  spec.ios.deployment_target = '11.0'
  spec.tvos.deployment_target = '10.0'
  spec.osx.deployment_target = '10.13'
  spec.requires_arc = true
  spec.default_subspecs = 'Core'
  spec.swift_version = '5.0'
  
  spec.ios.frameworks = 'UIKit'
  spec.tvos.frameworks = 'UIKit'
  
  spec.subspec 'Core' do |core|
  	core.source_files = 'MatomoTracker/*.swift'
  end
end
