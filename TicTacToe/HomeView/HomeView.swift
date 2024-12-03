//
//  HomeView.swift
//  TicTacToe
//
//  Created by Youssef JDIDI on 01/10/2024.
//

import SwiftUI
import ComposableArchitecture
import Factory

struct HomeView: View {
    let store: StoreOf<HomeViewReducer>
    
    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            VStack(alignment: .center, spacing: 16) {
                Button("Me vs Computer") {
                    store.send(.meVsComputerClicked)
                }
                Button("Me vs Friend") {
                    store.send(.meVsFriendClicked)
                }
                Button("Computer vs Computer") {
                    store.send(.computerVsComputerClicked)
                }
            }
            .dsButtonStyle()
        } destination: { store in
            switch store.case {
                case .gameView(let gameViewStore): GameView(store: gameViewStore)
            }
        }
    }
}
