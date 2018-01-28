source 'https://github.com/CocoaPods/Specs.git'

abstract_target :example do
  use_frameworks!
  inhibit_all_warnings!
  project 'MatomoTracker'
  workspace 'MatomoTracker'

  target :ios do
    platform :ios, '8.0'
    project 'Example/ios/ios'
    pod 'MatomoTracker', path: './'
  end

  target :macos do
    platform :osx, '10.12'
    project 'Example/macos/macos'
    pod 'MatomoTracker', path: './'
  end

  target :tvos do
    platform :tvos, '10.2'
    project 'Example/tvos/tvos'
    pod 'MatomoTracker', path: './'
  end

end

target 'MatomoTrackerTests' do
  use_frameworks!
  platform :ios, '8.0'
  inhibit_all_warnings!
  project 'MatomoTracker'
  workspace 'MatomoTracker'
  inherit! :search_paths
  
  pod 'Quick', '~> 1.2'
  pod 'Nimble', '~> 7.0'
end
