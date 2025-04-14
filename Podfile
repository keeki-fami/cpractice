# Uncomment the next line to define a global platform for your project
platform :ios, '17.6'

# install! 'cocoapods', :warn_for_unused_master_specs_repo => false

target 'cpractice' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for cpractice
  pod 'FSCalendar'

  # Pods for admob
  pod 'Google-Mobile-Ads-SDK'

end

  post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.6"
    end
  end
end


