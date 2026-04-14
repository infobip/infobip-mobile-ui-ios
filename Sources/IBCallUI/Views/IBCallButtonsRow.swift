//
//  IBCallButtonsRow.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI

/// Horizontal row showing up to `maxVisible` buttons (default 4).
/// Each button is driven by a `IBCallButtonModel` binding.
struct IBCallButtonsRow: View {
    @Binding var buttons: [IBCallButtonModel]
    var maxVisible: Int = 4

    var body: some View {
        HStack(spacing: 24) {
            ForEach(Array(buttons.prefix(maxVisible).enumerated()), id: \.element.id) { index, _ in
                IBCallButton(model: $buttons[index])
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 16)
    }
}
