
source 'https://github.com/CocoaPods/Specs.git'

xcodeproj 'PiwikTracker'
workspace 'PiwikTracker'

inhibit_all_warnings!


target :ios do
  platform :ios, '7.0'
  link_with ['PiwikTrackeriOSDemo']
  pod 'PiwikTracker', :path => './'
end


#target :iosafnetworking1 do
#  platform :ios, '7.0'
#  link_with ['PiwikTracker+AFNetworking1']
#  pod 'PiwikTracker/AFNetworking1', :path => './'
#end


target :iosafnetworking2 do
  platform :ios, '7.0'
  link_with ['PiwikTracker+AFNetworking2']
  pod 'PiwikTracker/AFNetworking2', :path => './'
end


target :osx do
  platform :osx, '10.8'
  link_with ['PiwikTrackerOSXDemo']
  pod 'PiwikTracker', :path => './'
end