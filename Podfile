# Uncomment the next line to define a global platform for your project
platform :ios, '11.4'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'RNNativeAudioTest' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  # Pods for react-native-audio-recorder
  pod 'AudioKit', '~> 4.3'
  pod 'SwiftyJSON', '~> 4.1'
  pod 'SwiftSiriWaveformView', '~> 2.4'

  # Your 'node_modules' directory is probably in the root of your project,
  # but if not, adjust the `:path` accordingly
  pod 'React', :path => '../node_modules/react-native', :subspecs => [
    'Core',
    'CxxBridge', # Include this for RN >= 0.47
    'DevSupport', # Include this to enable In-App Devmenu if RN >= 0.43
    'RCTText',
    'RCTNetwork',
    'RCTWebSocket', # Needed for debugging
    'RCTAnimation', # Needed for FlatList and animations running on native UI thread
    # Add any other subspecs you want to use in your project
  ]

  # Explicitly include Yoga if you are using RN >= 0.42.0
  pod 'yoga', :path => '../node_modules/react-native/ReactCommon/yoga'

  # Third party deps podspec link
  pod 'DoubleConversion', :podspec => '../node_modules/react-native/third-party-podspecs/DoubleConversion.podspec'
  pod 'glog', :podspec => '../node_modules/react-native/third-party-podspecs/glog.podspec'
  pod 'Folly', :podspec => '../node_modules/react-native/third-party-podspecs/Folly.podspec'
end

def change_lines_in_file(file_path, &change)
    print "Fixing #{file_path}...\n"

    contents = []

    file = File.open(file_path, 'r')
    file.each_line do | line |
        contents << line
    end
    file.close

    File.open(file_path, 'w') do |f|
        f.puts(change.call(contents))
    end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
        end
    end
end
