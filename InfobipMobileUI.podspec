Pod::Spec.new do |s|
  s.name             = 'InfobipMobileUI'
  s.version          = '1.0.0'
  s.summary          = 'Reusable SwiftUI voice/video call UI components for Infobip iOS integrations.'
  s.description      = <<~DESC
    InfobipMobileUI provides a fully customisable call screen (voice and video) that both
    the Conversations app (BEPO) and the Mobile Messaging SDK (WebRTCUI) can consume.
    Consumers own all call logic and drive the shared UI through a clean, data-driven API.
  DESC

  s.homepage         = 'https://git.ib-ci.com/scm/cma/infobip-mobile-ui-ios'
  s.license          = { :type => 'Infobip', :file => 'LICENSE' }
  s.author           = { 'Infobip' => 'mobile@infobip.com' }
  s.source           = { :git => 'https://git.ib-ci.com/scm/cma/infobip-mobile-ui-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.swift_version         = '5.0'

  # The Swift sources live in Sources/IBCallUI/ (folder name kept for historical reasons).
  # The module is exposed as InfobipMobileUI via module_name below.
  s.source_files  = 'Sources/IBCallUI/**/*.swift'
  s.module_name   = 'InfobipMobileUI'

  # Asset catalog and sound files bundled under the key 'InfobipMobileUI'.
  # At runtime IBCallUIBundle resolves this as 'InfobipMobileUI.bundle'.
  s.resource_bundles = {
    'InfobipMobileUI' => ['Sources/IBCallUI/Resources/**']
  }

  s.frameworks = 'UIKit', 'SwiftUI'

  # Disable Bitcode (deprecated from Xcode 14, but keeps older setups happy).
  s.pod_target_xcconfig = {
    'ENABLE_BITCODE' => 'NO'
  }
end
