# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MetaMera' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MetaMera
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore', '~> 7.0'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'Firebase/RemoteConfig'
  pod 'PKHUD', '~> 5.0' 
  pod 'ARCL'
  pod 'IQKeyboardManagerSwift' 
  pod 'AlamofireImage', '~> 4.1'
  pod 'FirebaseFirestoreSwift', '~> 7.0-beta'

  pod 'SwiftGen'

  target 'MetaMeraTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MetaMeraUITests' do
    # Pods for testing
  end


end

# remove warning for 'IPHONEOS_DEPLOYMENT_TARGET'
post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
   config.build_settings["DEVELOPMENT_TEAM"] = "JH5QRQ7596"
  end
 end
end
