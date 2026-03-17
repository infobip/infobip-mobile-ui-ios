//
//  IBCallUIConfiguration.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI

/// All visual customisation for the call UI. Consumers pass their own icon images and
/// colour overrides when constructing this and hand it to `IBCallViewController`.
public struct IBCallUIConfiguration {

    // MARK: - Colors

    public var backgroundColor: Color
    public var foregroundColor: Color
    public var textSecondaryColor: Color
    public var sheetBackgroundColor: Color
    public var sheetDividerColor: Color
    public var sheetDragIndicatorColor: Color
    public var buttonColor: Color
    public var buttonSelectedColor: Color
    public var hangupButtonColor: Color
    public var errorColor: Color
    public var rowActionLabelColor: Color

    // MARK: - Icons

    public var iconMute: Image
    public var iconUnMute: Image
    public var iconMutedParticipant: Image
    public var iconScreenShareOn: Image
    public var iconScreenShareOff: Image
    public var iconAvatar: Image
    public var iconVideo: Image
    public var iconVideoOff: Image
    public var iconSpeaker: Image
    public var iconSpeakerOff: Image
    public var iconFlipCamera: Image
    public var iconEndCall: Image
    public var iconExpand: Image
    public var iconCollapse: Image
    public var iconAlert: Image
    public var iconLandscapeOn: Image
    public var iconLandscapeOff: Image

    // MARK: - Init

    public init(
        backgroundColor: Color = Color(ibMobileUIHex: "#242424"),
        foregroundColor: Color = .white,
        textSecondaryColor: Color = Color(ibMobileUIHex: "#5D5F61"),
        sheetBackgroundColor: Color = Color(ibMobileUIHex: "#242424"),
        sheetDividerColor: Color = Color(ibMobileUIHex: "#3B3B39"),
        sheetDragIndicatorColor: Color = Color(ibMobileUIHex: "#5D5F61"),
        buttonColor: Color = Color(ibMobileUIHex: "#5D5F61"),
        buttonSelectedColor: Color = .white,
        hangupButtonColor: Color = Color(ibMobileUIHex: "#C84714"),
        errorColor: Color = Color(ibMobileUIHex: "#FF3B30").opacity(0.9),
        rowActionLabelColor: Color = .white,
        iconMute: Image,
        iconUnMute: Image,
        iconMutedParticipant: Image,
        iconScreenShareOn: Image,
        iconScreenShareOff: Image,
        iconAvatar: Image,
        iconVideo: Image,
        iconVideoOff: Image,
        iconSpeaker: Image,
        iconSpeakerOff: Image,
        iconFlipCamera: Image,
        iconEndCall: Image,
        iconExpand: Image,
        iconCollapse: Image,
        iconAlert: Image,
        iconLandscapeOn: Image,
        iconLandscapeOff: Image
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.textSecondaryColor = textSecondaryColor
        self.sheetBackgroundColor = sheetBackgroundColor
        self.sheetDividerColor = sheetDividerColor
        self.sheetDragIndicatorColor = sheetDragIndicatorColor
        self.buttonColor = buttonColor
        self.buttonSelectedColor = buttonSelectedColor
        self.hangupButtonColor = hangupButtonColor
        self.errorColor = errorColor
        self.rowActionLabelColor = rowActionLabelColor
        self.iconMute = iconMute
        self.iconUnMute = iconUnMute
        self.iconMutedParticipant = iconMutedParticipant
        self.iconScreenShareOn = iconScreenShareOn
        self.iconScreenShareOff = iconScreenShareOff
        self.iconAvatar = iconAvatar
        self.iconVideo = iconVideo
        self.iconVideoOff = iconVideoOff
        self.iconSpeaker = iconSpeaker
        self.iconSpeakerOff = iconSpeakerOff
        self.iconFlipCamera = iconFlipCamera
        self.iconEndCall = iconEndCall
        self.iconExpand = iconExpand
        self.iconCollapse = iconCollapse
        self.iconAlert = iconAlert
        self.iconLandscapeOn = iconLandscapeOn
        self.iconLandscapeOff = iconLandscapeOff
    }

    /// Returns a copy with a fully transparent sheet background (used in video/screenshare layout).
    var withTransparentSheet: IBCallUIConfiguration {
        var copy = self
        copy.sheetBackgroundColor = .clear
        return copy
    }
}

// MARK: - Color helpers

public extension Color {
    /// Initialise from a 6- or 8-digit hex string (with or without leading #).
    init(ibMobileUIHex: String) {
        let hex = ibMobileUIHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

