# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'VibeChat' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VibeChat
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Giphy'

  target 'VibeChatTests' do
    inherit! :complete
    # Pods for testing
  end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end

end
