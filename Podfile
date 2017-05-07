source 'https://github.com/CocoaPods/Specs.git'

abstract_target :example do
  use_frameworks!
  inhibit_all_warnings!
  workspace 'PiwikTracker'

  target :ios do
    platform :ios, '8.0'
    project 'Example/ios'
    pod 'PiwikTracker', path: './'
  end

  target :macos do
    platform :osx, '10.12'
    project 'Example/macos/macos'
    pod 'PiwikTracker', path: './'
  end

  #target :osx do
    # platform :osx, '10.8'
    # link_with ['PiwikTrackerOSXDemo']
    # pod 'PiwikTracker', :path => './'
  #end
end

target 'PiwikTrackerTests' do
  use_frameworks!
  platform :ios, '8.0'
  inhibit_all_warnings!
  workspace 'PiwikTracker'
  inherit! :search_paths
  
  pod 'Quick', '~> 0.10'
  pod 'Nimble', '~> 5.1'
end
