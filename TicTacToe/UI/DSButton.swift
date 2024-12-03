//
//  DSButton.swift
//  TicTacToe
//
//  Created by Youssef JDIDI on 02/10/2024.
//

import SwiftUI

struct DSButton: ButtonStyle {
    // init with style
    init() {}
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding()
            .background(configuration.isPressed ? .blue.opacity(0.9) : .blue)
            .foregroundStyle(.white)
            .clipShape(.capsule(style: .circular))
    }
}

extension View {
    func dsButtonStyle() -> some View {
        buttonStyle(DSButton())
    }
}
