Pod::Spec.new do |spec|
  spec.name         = "PiwikTracker"
  spec.version      = "4.0.0-alpha1"
  spec.summary      = "A Piwik tracker written in Swift for iOS apps."
  spec.homepage     = "https://github.com/piwik/piwik-sdk-ios/"
  spec.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.author       = { "Mattias Levin" => "mattias.levin@gmail.com", "Cornelius Horstmann" => "site-github@brototyp.de" }
  spec.source       = { :git => "https://github.com/piwik/piwik-sdk-ios.git", :tag => "v#{spec.version}" }
  spec.ios.deployment_target = '7.0'
  spec.requires_arc = true
  spec.default_subspecs = 'Core'
  
  spec.subspec 'Core' do |core|
  	core.source_files = 'PiwikTracker/*.swift'
  end
end
