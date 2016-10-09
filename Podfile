
source 'https://github.com/CocoaPods/Specs.git'

project 'PiwikTracker'
workspace 'PiwikTracker'

inhibit_all_warnings!


target 'PiwikTrackerSwiftTests' do
  use_frameworks!
  platform :ios, '8.0'

  pod 'Quick', '~> 0.10'
  pod 'Nimble', '~> 5.0'


  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
      # config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = 'ABCDEFGH/'
      config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
    end
  end

end

# target :ios do
#   platform :ios, '7.0'
#   link_with ['PiwikTrackeriOSDemo']
#   pod 'PiwikTracker', :path => './'
# end


#target :iosafnetworking1 do
#  platform :ios, '7.0'
#  link_with ['PiwikTracker+AFNetworking1']
#  pod 'PiwikTracker/AFNetworking1', :path => './'
#end


# target :iosafnetworking2 do
#   platform :ios, '7.0'
#   link_with ['PiwikTracker+AFNetworking2']
#   pod 'PiwikTracker/AFNetworking2', :path => './'
# end


# target :osx do
#   platform :osx, '10.8'
#   link_with ['PiwikTrackerOSXDemo']
#   pod 'PiwikTracker', :path => './'
# end