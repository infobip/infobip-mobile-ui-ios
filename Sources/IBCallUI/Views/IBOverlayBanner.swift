//
//  IBOverlayBanner.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI

/// A top-of-screen banner used to show persistent notifications such as
/// "You are muted" or "Reconnecting…". The banner stretches to fill the width
/// of the call screen.
struct IBOverlayBanner: View {
    var message: String
    var icon: Image?
    var backgroundColor: Color
    var foregroundColor: Color

    var body: some View {
        HStack(spacing: 8) {
            if let icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(foregroundColor)
            }
            Text(message)
                .foregroundColor(foregroundColor)
                .font(.subheadline)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(backgroundColor)
    }
}
