//
//  IBCallButtonsIds.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

/// Canonical string identifiers for built-in call action buttons.
///
/// Use these constants wherever a button `id` is read or written — in factories,
/// `setButton(id:)` calls, and any UI logic that identifies buttons by ID.
public struct IBCallButtonsIds {
    public static let hangup       = "hangup"
    public static let microphone   = "microphone"
    public static let video        = "video"
    public static let screenshare  = "screenshare"
    public static let speakerphone = "speakerphone"
    public static let flipCamera   = "flipCamera"
    public static let hold         = "hold"
    public static let transfer     = "transfer"
    public static let dialpad      = "dialpad"
    public static let focusSwitch  = "focusSwitch"
    public static let merge        = "merge"
    public static let stopAdvising = "stopAdvising"

    private init() {}
}
