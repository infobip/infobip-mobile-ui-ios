# InfobipMobileUI

Reusable SwiftUI UI components for Infobip iOS integrations.

## Overview

`InfobipMobileUI` provides a fully customisable call screen that both the **Conversations app** (BEPO) and the **Mobile Messaging SDK** (WebRTCUI) can consume. Each consumer keeps its own call logic and drives the shared UI through a simple, protocol-based API.

## Features

- SwiftUI-first, UIKit-compatible via `CallViewController`
- Voice call screen (avatar, status, duration, muted indicator)
- Video call screen (full-screen remote, draggable floating local)
- Draggable bottom sheet with visible + overflow buttons
- Fully customisable via `CallUIConfiguration` (colours, icons)
- Configurable buttons via `[CallButtonModel]` — consumers own all tap logic
- Picture-in-Picture support (custom PIPKit vendored)
- BEPO-specific buttons (Hold, Transfer, Dialpad) in a dedicated `BEPO/` group

## Installation

### Swift Package Manager

```swift
.package(url: "https://git.ib-ci.com/scm/cma/infobip-mobile-ui-ios.git", from: "1.0.0")
```

Then add `InfobipMobileUI` to your target's dependencies.

### CocoaPods *(coming soon)*

```ruby
pod 'InfobipMobileUI'
```

## Usage

```swift
import InfobipMobileUI

let state = CallUIState()
let config = CallUIConfiguration.default
let buttons: [CallButtonModel] = [
    CallButtonModel.hangup { /* hangup logic */ },
    CallButtonModel.microphone(isSelected: false) { /* mute toggle */ },
    CallButtonModel.speakerphone(isSelected: false) { /* speaker toggle */ }
]

let callVC = CallViewController(state: state, buttons: buttons, configuration: config)
PIPKit.show(with: callVC)

// Drive UI from your call event listeners:
state.callPhase = .established
state.statusText = "00:42"
state.remoteTitle = "John Doe"
```

### BEPO (Conversations App)

```swift
import InfobipMobileUI

var buttons: [CallButtonModel] = [ /* common buttons */ ]
buttons += BEPOCallButtonModels.hold(isOnHold: false) { /* hold logic */ }
buttons += BEPOCallButtonModels.transfer(canTransfer: true) { /* present transfer UI */ }
buttons += BEPOCallButtonModels.dialpad { /* present dialpad */ }
```

## Architecture

```
CallViewController (UIViewController + IBPIPUsable)
└── UIHostingController
    └── CallContainerView (SwiftUI)
        ├── VoiceCallView    — audio-only layout
        └── MediaCallView    — video layout with FloatingVideoWindow
```
