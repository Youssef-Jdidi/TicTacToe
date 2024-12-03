//
//  TicTacToeApp.swift
//  TicTacToe
//
//  Created by Youssef JDIDI on 01/10/2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct TicTacToeApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(store: Store(initialState: HomeViewReducer.State.initialValue,
                                  reducer: { HomeViewReducer() }))
        }
    }
}
