Pod::Spec.new do |s|
  s.name             = 'InfobipMobileUI'
  s.version          = '1.0.5'
  s.summary          = 'Reusable SwiftUI voice/video call UI components for Infobip iOS integrations.'
  s.description      = <<~DESC
    InfobipMobileUI provides a fully customisable call screen (voice and video) that both
    the Conversations app (BEPO) and the Mobile Messaging SDK (WebRTCUI) can consume.
    Consumers own all call logic and drive the shared UI through a clean, data-driven API.
  DESC

  s.homepage         = 'https://github.com/infobip/infobip-mobile-ui-ios.git'
  s.license          = { :type => 'Infobip', :file => 'LICENSE' }
  s.author           = { 'Infobip' => 'mobile@infobip.com' }
  s.source           = { :git => 'https://github.com/infobip/infobip-mobile-ui-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version         = '5.0'

  # The Swift sources live in Sources/IBCallUI/ (folder name kept for historical reasons).
  # The module is exposed as InfobipMobileUI via module_name below.
  s.source_files  = 'Sources/IBCallUI/**/*.swift'
  s.module_name   = 'InfobipMobileUI'

  s.frameworks = 'UIKit', 'SwiftUI'
end
