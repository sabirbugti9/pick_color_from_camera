#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint color_picker_camera.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pick_color_from_camera'
  s.version          = '1.0.0'
  s.summary          = 'A new Flutter plugin.'
  s.description      = <<-DESC
  As the name suggests "Pick Color From Camera" lets its users to obtain the RGB(hex) color code of any object.It opens the back camera and shows color code of the object that comes in focus within the centered target.You can utilize RGB(hex) color code of object according to your need.
                       DESC
  s.homepage         = 'https://github.com/sabirbugti9/pick_color_from_camera/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Sabir Bugti' => 'abugti532@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
