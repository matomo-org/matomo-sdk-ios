xcodeproj 'PiwikTracker'
workspace 'PiwikTracker'

inhibit_all_warnings!


target :ios do
  platform :ios, '7.0'
  link_with ['PiwikTrackeriOSDemo']
  pod 'PiwikTracker', :path => './'
end


target :iosafnetworkingv1 do
  platform :ios, '7.0'
  link_with ['PiwikTracker+AFNetworkingv1']
  pod 'PiwikTracker/AFNetworkingv1', :path => './'
end


target :osx do
  platform :osx, '10.8'
  link_with ['PiwikTrackerOSXDemo']
  pod 'PiwikTracker', :path => './'
end