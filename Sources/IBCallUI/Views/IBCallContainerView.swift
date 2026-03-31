//
//  IBCallContainerView.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI

/// Root SwiftUI view that switches between `IBVoiceCallView` and `IBMediaCallView`
/// based on `IBCallUIState`. Also renders the `IBOverlayBanner` when needed.
///
/// Consumers do not use this view directly — they present `IBCallViewController`.
struct IBCallContainerView: View {
    @ObservedObject var state: IBCallUIState
    @Binding var buttons: [IBCallButtonModel]
    var configuration: IBCallUIConfiguration
    /// Factory injected by the consumer to create InfobipRTC video renderer views.
    var rendererFactory: (AnyObject) -> UIView
    var onPIPToggle: () -> Void

    var body: some View {
        mainView
    }

    @ViewBuilder
    private var mainView: some View {
        if state.isVideoActive {
            IBMediaCallView(
                state: state,
                buttons: $buttons,
                configuration: configuration,
                rendererFactory: rendererFactory,
                onPIPToggle: onPIPToggle
            )
        } else {
            IBVoiceCallView(
                state: state,
                buttons: $buttons,
                configuration: configuration,
                rendererFactory: rendererFactory,
                onPIPToggle: onPIPToggle
            )
        }
    }
}
