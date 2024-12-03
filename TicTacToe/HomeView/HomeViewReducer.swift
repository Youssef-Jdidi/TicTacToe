//
//  HomeViewReducer.swift
//  TicTacToe
//
//  Created by Youssef JDIDI on 02/10/2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
class HomeViewReducer {
    @ObservableState
    struct State: Equatable {
        var path: StackState<Path.State>

        static func == (lhs: HomeViewReducer.State,
                        rhs: HomeViewReducer.State) -> Bool {
            lhs.path.ids == rhs.path.ids
        }
    }

    enum Action {
        case meVsComputerClicked
        case meVsFriendClicked
        case computerVsComputerClicked
        // Routing Actions
        case path(StackActionOf<Path>)
    }

    @Reducer
    enum Path: Equatable {
        case gameView(GameViewReducer)

        static func == (lhs: HomeViewReducer.Path, rhs: HomeViewReducer.Path) -> Bool {
            switch (lhs, rhs) {
                case (.gameView, .gameView):
                    return true
            }
        }
    }

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
                case .meVsComputerClicked:
                    state.path.append(.gameView(GameViewReducer.State.init(gameType: .playerVsComputer)))
                    return .none
                case .meVsFriendClicked:
                    state.path.append(.gameView(GameViewReducer.State.init(gameType: .playerVsPlayer)))
                    return .none
                case .computerVsComputerClicked:
                    state.path.append(.gameView(GameViewReducer.State.init(gameType: .computerVsComputer)))
                    return .none
                case .path: return .none
            }
        }.forEach(\.path, action: \.path)
    }
}

extension HomeViewReducer.State {
    static let initialValue = HomeViewReducer.State(path: StackState<HomeViewReducer.Path.State>())
}
