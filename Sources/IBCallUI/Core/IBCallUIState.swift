//
//  IBCallUIState.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI
import Combine

// MARK: - Supporting types

/// A participant in a multi-party call, as seen by the coordination layer.
/// Defined here (in the UI package) so `IBCallUIState` can carry participant state
/// without a dependency on the app layer.
public struct IBCallParticipant: Equatable, Identifiable {
    public enum Role: Equatable { case agent, customer }

    public let id: String          // identity string (unique per participant)
    public let displayName: String?
    public let role: Role
    public var isOnHold: Bool
    public var isTalking: Bool
    public var isReconnecting: Bool
    public var isLoading: Bool     // per-participant spinner (e.g. while ringing)

    public init(id: String, displayName: String?, role: Role,
                isOnHold: Bool = false, isTalking: Bool = false,
                isReconnecting: Bool = false, isLoading: Bool = false) {
        self.id = id
        self.displayName = displayName
        self.role = role
        self.isOnHold = isOnHold
        self.isTalking = isTalking
        self.isReconnecting = isReconnecting
        self.isLoading = isLoading
    }
}

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
    @Published public var warningText: String = ""
    @Published public var warningIcon: Image?

    // MARK: - Participant state

    @Published public var isRemoteMuted: Bool = false

    // MARK: - Multi-party coordination state

    /// All participants in the current call (empty for plain 1-on-1 calls).
    /// The coordination layer populates this from state-machine effects; UI observes it.
    @Published public var callParticipants: [IBCallParticipant] = []

    /// `true` while waiting for a multi-party operation to complete (global spinner).
    @Published public var isMultiPartyLoading: Bool = false

    /// Identity or display value of the specific participant that is currently loading
    /// (e.g. a callee that is ringing). `nil` means the spinner is global.
    @Published public var loadingCalleeValue: String? = nil

    /// `true` when the customer leg has been placed on hold during an advising session.
    @Published public var isCustomerOnHold: Bool = false

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
