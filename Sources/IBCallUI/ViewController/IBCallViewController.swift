//
//  IBCallViewController.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import UIKit
import SwiftUI

/// The entry point for presenting the call UI. Consumers create an instance of
/// this view controller and present it (or pass it to `IBPIPKit.show(with:)`).
///
/// The controller hosts a `IBCallContainerView` (SwiftUI) as a child
/// `UIHostingController`, so it works seamlessly with UIKit navigation stacks
/// and IBPIPKit's window-level presentation.
///
/// ## Usage
/// ```swift
/// let state = IBCallUIState()
/// let buttons: [IBCallButtonModel] = [
///     .hangup { callInteractor.hangup() },
///     .microphone(isSelected: false) { callInteractor.micToggle() },
/// ]
/// let vc = IBCallViewController(state: state, buttons: buttons)
/// IBPIPKit.show(with: vc)
/// ```
@MainActor
public final class IBCallViewController: UIViewController, IBPIPUsable {

    // MARK: - Public properties

    public let state: IBCallUIState
    public var configuration: IBCallUIConfiguration
    public var isInitiatedWithPIP: Bool = false

    // MARK: - PIP

    public var initialState: IBPIPState = .full

    public var pipSize: CGSize {
        if !state.isVideoActive {
            return CGSize(width: 280, height: 180)
        }
        return CGSize(width: 280, height: 300)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Private

    private let buttonsState: IBButtonsState
    private let rendererFactory: (AnyObject) -> UIView
    private var hostingController: UIHostingController<IBCallContainerViewWrapper>?

    /// Optional: constraint used to shift the call view down when an overlay
    /// banner is shown (matches behaviour of IBCallViewController.topConstraint).
    private var topConstraint: NSLayoutConstraint?

    // MARK: - Init

    /// - Parameters:
    ///   - state: The observable state that drives the UI. Update this from your call event listeners.
    ///   - buttons: Ordered list of call action buttons. The first ≤4 are always visible; the rest appear in the expandable overflow list.
    ///   - configuration: Visual theme including all icon images.
    ///   - rendererFactory: Closure that creates an InfobipRTC video renderer `UIView` for a given track. Required for video calls. Pass a no-op for audio-only applications.
    public init(
        state: IBCallUIState,
        buttons: [IBCallButtonModel],
        configuration: IBCallUIConfiguration,
        rendererFactory: @escaping (AnyObject) -> UIView
    ) {
        self.state = state
        self.buttonsState = IBButtonsState()
        self.buttonsState.buttons = buttons
        self.configuration = configuration
        self.rendererFactory = rendererFactory
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Use init(state:buttons:configuration:)") }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(configuration.backgroundColor)
        embedSwiftUIView()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Collapse button is only relevant when IBPIPKit is active
        let isPIPActive = IBPIPKit.isActive
        state.isPIP = isPIPActive && (IBPIPKit.state == .pip)
    }

    // MARK: - Setup

    private func embedSwiftUIView() {
        let rootView = IBCallContainerViewWrapper(
            state: state,
            buttonsState: buttonsState,
            configuration: configuration,
            rendererFactory: rendererFactory,
            onPIPToggle: { [weak self] in self?.togglePIP() }
        )

        let hostingVC = UIHostingController(rootView: rootView)
        hostingVC.view.backgroundColor = .clear
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(hostingVC)
        view.addSubview(hostingVC.view)

        let top = hostingVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        topConstraint = top
        NSLayoutConstraint.activate([
            top,
            hostingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingVC.didMove(toParent: self)
        self.hostingController = hostingVC
    }

    // MARK: - Button updates

    /// Replace the entire button array at runtime (e.g. when a video track is added).
    public func updateButtons(_ newButtons: [IBCallButtonModel]) {
        // Update the shared reference object — the SwiftUI binding reads from it,
        // so the view re-renders without tearing down the hosting controller.
        buttonsState.buttons = newButtons
    }

    // MARK: - PIP

    private func togglePIP() {
        if IBPIPKit.isPIP {
            stopPIPMode()
            state.isPIP = false
        } else {
            startPIPMode()
            state.isPIP = true
        }
    }

    public func didChangedState(_ pipState: IBPIPState) {
        state.isPIP = (pipState == .pip)
        if pipState == .full {
            // Reset any transient layout when coming back to full screen
        }
    }

    // MARK: - Orientation

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if #available(iOS 16.0, *) { return .all } else { return .portrait }
    }

    public override var shouldAutorotate: Bool {
        if #available(iOS 16.0, *) { return true } else { return false }
    }
}

// MARK: - IBButtonsState (ObservableObject so button mutations don't recreate the hosting controller)

@MainActor
private final class IBButtonsState: ObservableObject {
    @Published var buttons: [IBCallButtonModel] = []
}

// MARK: - Wrapper that observes IBButtonsState so IBCallContainerView re-renders on button changes

private struct IBCallContainerViewWrapper: View {
    @ObservedObject var state: IBCallUIState
    @ObservedObject var buttonsState: IBButtonsState
    var configuration: IBCallUIConfiguration
    var rendererFactory: (AnyObject) -> UIView
    var onPIPToggle: () -> Void

    var body: some View {
        IBCallContainerView(
            state: state,
            buttons: $buttonsState.buttons,
            configuration: configuration,
            rendererFactory: rendererFactory,
            onPIPToggle: onPIPToggle
        )
    }
}
