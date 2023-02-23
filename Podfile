# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MetaMera' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MetaMera
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Firestore', '~> 7.0'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'Firebase/RemoteConfig'
  pod 'PKHUD', '~> 5.0' 
  pod 'ARCL', '1.3.0'
  pod 'IQKeyboardManagerSwift' 
  pod 'AlamofireImage', '~> 4.1'
  pod 'FirebaseFirestoreSwift', '~> 7.0-beta'

  pod 'SwiftGen'

  script_phase name: 'Run Firebase Crashlytics',
               shell_path: '/bin/sh',
               script: '"${PODS_ROOT}/FirebaseCrashlytics/run"',
               input_files: ['${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}', '$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)']

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
