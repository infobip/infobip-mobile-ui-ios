//
//  IBCallUIState.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI
import Combine

// MARK: - Supporting enums

public enum IBCallPhase: Equatable {
    case calling
    case established
    case reconnecting
    case ended
}

public enum IBCallType: Equatable {
    case audio
    case video
}

public enum IBScreenshareState {
    case none
    /// The local user is sharing their screen. The associated value is a VideoTrack (typed as AnyObject
    /// to avoid a hard dependency on InfobipRTC in the shared library).
    case local(AnyObject)
    /// A remote participant is sharing their screen.
    case remote(AnyObject)

    var isActive: Bool {
        if case .none = self { return false }
        return true
    }

    var videoTrack: AnyObject? {
        switch self {
        case .none: return nil
        case .local(let track): return track
        case .remote(let track): return track
        }
    }
}

// MARK: - IBCallUIState

/// The observable state that drives the call UI. Consumers update this from their call event
/// listeners; the SwiftUI views automatically react to changes.
@MainActor
public final class IBCallUIState: ObservableObject {

    // MARK: - Call metadata

    @Published public var callPhase: IBCallPhase = .calling
    @Published public var callType: IBCallType = .audio
    @Published public var remoteTitle: String = ""
    /// Human-readable status: elapsed duration (e.g. "00:42") while established,
    /// or a localised string like "Calling…" before connection.
    @Published public var statusText: String = ""

    // MARK: - Participant state

    @Published public var isRemoteMuted: Bool = false

    // MARK: - Video tracks
    // Typed as AnyObject to avoid a compile-time dependency on InfobipRTC.
    // Consumers cast to their VideoTrack type when constructing IBVideoStreamView.

    /// The local camera video track, or nil when camera is off.
    @Published public var localVideoTrack: AnyObject? = nil
    /// The remote camera video track, or nil when no remote video.
    @Published public var remoteVideoTrack: AnyObject? = nil
    /// Active screenshare, either local or remote.
    @Published public var screenshare: IBScreenshareState = .none

    // MARK: - PIP

    @Published public var isPIP: Bool = false

    // MARK: - Derived helpers

    /// True when the layout should switch to the full-screen video layout.
    /// Local-only camera does not trigger the switch — only remote video or screenshare does.
    public var isVideoActive: Bool {
        remoteVideoTrack != nil || screenshare.isActive
    }

    public init() {}
}
