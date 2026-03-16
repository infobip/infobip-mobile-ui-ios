//
//  IBCallButton.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI

/// A single circular call action button that renders from a `IBCallButtonModel`.
struct IBCallButton: View {
    @Binding var model: IBCallButtonModel

    var body: some View {
        Button(action: { model.onTap() }) {
            let isSelected = model.isSelected
            let bg = isSelected
                ? (model.selectedBackgroundColor ?? model.backgroundColor)
                : model.backgroundColor
            let icon = isSelected ? (model.selectedIcon ?? model.icon) : model.icon
            let fg = isSelected ? (model.selectedIconColor ?? model.iconColor) : model.iconColor

            ZStack {
                Circle()
                    .fill(bg)
                icon
                    .resizable()
                    .scaledToFit()
                    .padding(12)
                    .foregroundColor(fg)
            }
        }
        .disabled(!model.isEnabled)
        .opacity(model.isEnabled ? 1.0 : 0.4)
        .frame(width: 56, height: 56)
        .accessibilityLabel(model.label ?? "")
    }
}
