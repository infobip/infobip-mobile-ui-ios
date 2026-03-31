//
//  IBCallButtonModel.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI

/// Data model for a single call action button. Consumers create instances of this type
/// (using the convenience factory methods below or ad-hoc) and pass an ordered array to
/// `IBCallViewController`. The first ≤4 buttons appear in the always-visible row; any
/// additional buttons are revealed in the expandable overflow list.
public struct IBCallButtonModel: Identifiable {
    public let id: String
    public var icon: Image
    public var selectedIcon: Image?
    /// Short label shown below the button in the overflow list view.
    public var label: String?
    public var backgroundColor: Color
    public var selectedBackgroundColor: Color?
    /// Icon foreground color when unselected. Defaults to `.white`.
    public var iconColor: Color
    /// Icon foreground color when selected. Defaults to `.white`.
    public var selectedIconColor: Color?
    public var isSelected: Bool
    public var isEnabled: Bool
    /// When true the button is excluded from the visible array passed to the view.
    public var isHidden: Bool
    /// Called when the button is tapped. Consumers own all business logic.
    public var onTap: () -> Void

    public init(
        id: String,
        icon: Image,
        selectedIcon: Image? = nil,
        label: String? = nil,
        backgroundColor: Color,
        selectedBackgroundColor: Color? = nil,
        iconColor: Color = .white,
        selectedIconColor: Color? = nil,
        isSelected: Bool = false,
        isEnabled: Bool = true,
        isHidden: Bool = false,
        onTap: @escaping () -> Void
    ) {
        self.id = id
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.label = label
        self.backgroundColor = backgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.iconColor = iconColor
        self.selectedIconColor = selectedIconColor
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHidden = isHidden
        self.onTap = onTap
    }
}

// MARK: - Convenience factories for common call buttons

public extension IBCallButtonModel {

    /// End-call (hangup) button. Always uses the hangup colour from the active configuration.
    static func hangup(
        configuration: IBCallUIConfiguration,
        onTap: @escaping () -> Void
    ) -> IBCallButtonModel {
        IBCallButtonModel(
            id: "hangup",
            icon: configuration.iconEndCall,
            backgroundColor: configuration.hangupButtonColor,
            onTap: onTap
        )
    }

    /// Microphone mute/unmute toggle.
    static func microphone(
        isSelected: Bool = false,
        configuration: IBCallUIConfiguration,
        onTap: @escaping () -> Void
    ) -> IBCallButtonModel {
        IBCallButtonModel(
            id: "microphone",
            icon: configuration.iconMute,
            selectedIcon: configuration.iconUnMute,
            label: "Microphone",
            backgroundColor: configuration.buttonSelectedColor,
            selectedBackgroundColor: configuration.buttonColor,
            isSelected: isSelected,
            onTap: onTap
        )
    }

    /// Camera video toggle.
    static func video(
        isSelected: Bool = false,
        configuration: IBCallUIConfiguration,
        onTap: @escaping () -> Void
    ) -> IBCallButtonModel {
        IBCallButtonModel(
            id: "video",
            icon: configuration.iconVideoOff,
            selectedIcon: configuration.iconVideo,
            label: "Video",
            backgroundColor: configuration.buttonColor,
            selectedBackgroundColor: configuration.buttonSelectedColor,
            isSelected: isSelected,
            onTap: onTap
        )
    }

    /// Screenshare toggle.
    static func screenshare(
        isSelected: Bool = false,
        configuration: IBCallUIConfiguration,
        onTap: @escaping () -> Void
    ) -> IBCallButtonModel {
        IBCallButtonModel(
            id: "screenshare",
            icon: configuration.iconScreenShareOn,
            selectedIcon: configuration.iconScreenShareOff,
            label: "Screensharing",
            backgroundColor: configuration.buttonColor,
            selectedBackgroundColor: configuration.buttonSelectedColor,
            isSelected: isSelected,
            onTap: onTap
        )
    }

    /// Speakerphone toggle.
    static func speakerphone(
        isSelected: Bool = false,
        configuration: IBCallUIConfiguration,
        onTap: @escaping () -> Void
    ) -> IBCallButtonModel {
        IBCallButtonModel(
            id: "speakerphone",
            icon: configuration.iconSpeakerOff,
            selectedIcon: configuration.iconSpeaker,
            label: "Speakerphone",
            backgroundColor: configuration.buttonColor,
            selectedBackgroundColor: configuration.buttonSelectedColor,
            isSelected: isSelected,
            onTap: onTap
        )
    }

    /// Flip (switch) camera button.
    static func flipCamera(
        configuration: IBCallUIConfiguration,
        onTap: @escaping () -> Void
    ) -> IBCallButtonModel {
        IBCallButtonModel(
            id: "flipCamera",
            icon: configuration.iconFlipCamera,
            label: "Flip Camera",
            backgroundColor: configuration.buttonColor,
            onTap: onTap
        )
    }
}
