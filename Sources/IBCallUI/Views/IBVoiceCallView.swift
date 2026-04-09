//
//  IBVoiceCallView.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI

/// Audio-only call screen. Shown when `callType == .audio` or during the
/// `.calling` phase before video is established.
struct IBVoiceCallView: View {
    @ObservedObject var state: IBCallUIState
    @Binding var buttons: [IBCallButtonModel]
    var configuration: IBCallUIConfiguration
    var rendererFactory: ((AnyObject) -> UIView)?
    var onPIPToggle: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            configuration.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if !state.isPIP, !state.warningText.isEmpty {
                    HStack {
                        Spacer()
                        state.warningIcon?
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(configuration.warningColor)
                        Text(state.warningText)
                            .font(.system(size: 18))
                            .foregroundColor(configuration.warningColor)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 0)
                        Spacer()
                    }
                }
                
                Text(state.remoteTitle)
                    .font(.system(size: !state.isPIP ? 32 : 24, weight: .bold))
                    .foregroundColor(configuration.foregroundColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, !state.isPIP ? 120 : 10)

                Text(state.statusText)
                    .font(.system(size: !state.isPIP ? 20 : 12))
                    .foregroundColor(configuration.textSecondaryColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                
                if !state.isPIP {
                    // Remote muted indicator
                    if state.isRemoteMuted {
                        configuration.iconMutedParticipant
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(configuration.foregroundColor)
                    }

                    // Avatar placeholder
                    configuration.iconAvatar
                        .resizable()
                        .scaledToFit()
                        // TODO: UIScreen.main is deprecated in iOS 16. Refactor once iOS 15 support is dropped.
                        .frame(width: 80)
                        .padding(.top, state.isRemoteMuted ? 4 : 0)

                    Spacer()
                }

                if state.isPIP {
                    Spacer(minLength: 8)
                } else {
                    Spacer()
                }
            }

            // Bottom sheet
            if !state.isPIP {
                IBCallButtonsSheet(
                    buttons: $buttons,
                    configuration: configuration
                )
            } else {
                // PIP: compact inline row — buttons are interactive, empty areas pass through
                IBCallButtonsRow(buttons: $buttons)
                    .padding(.bottom, 8)
                    .background(configuration.sheetBackgroundColor)
            }

            // Local video floating window — only instantiated when a track exists
            // so the UIKit renderer view is fully torn down when camera stops
            if let factory = rendererFactory, state.localVideoTrack != nil, !state.isPIP {
                IBFloatingVideoWindow(
                    localVideoTrack: state.localVideoTrack,
                    secondaryVideoTrack: nil,
                    rendererFactory: factory,
                    isPIP: state.isPIP
                )
            }
        }
        // In PIP mode, any tap not consumed by a button expands back to full screen
        .contentShape(Rectangle())
        .onTapGesture {
            if state.isPIP { onPIPToggle() }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onPIPToggle) {
                (state.isPIP ? configuration.iconExpand : configuration.iconCollapse)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(configuration.foregroundColor)
            }
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .padding(.trailing, 8)
            .padding(.top, 8)
        }
    }
}
