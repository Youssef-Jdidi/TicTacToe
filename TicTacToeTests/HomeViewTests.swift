//
//  HomeViewTests.swift
//  TicTacToeTests
//
//  Created by Youssef JDIDI on 01/10/2024.
//

import Testing
import ComposableArchitecture
@testable import TicTacToe

@MainActor
struct HomeViewTests {
    @Test func testRoutingToGameViewWhenComputerVsComputerClicked() async {
        let testStore = store()
        await testStore.send(.computerVsComputerClicked) {
            $0.path = .init(repeating: HomeViewReducer.Path.State.gameView(.init(gameType: .computerVsComputer)), count: 1)
        }
    }
    
    @Test func testRoutingToGameViewWhenMeVsFriendClicked() async {
        let testStore = store()
        await testStore.send(.meVsFriendClicked) {
            $0.path = .init(repeating: HomeViewReducer.Path.State.gameView(.init(gameType: .playerVsPlayer)), count: 1)
        }
    }
    
    @Test func testRoutingToGameViewWhenMeVsComputerClicked() async {
        let testStore = store()
        await testStore.send(.meVsComputerClicked) {
            $0.path = .init(repeating: HomeViewReducer.Path.State.gameView(.init(gameType: .playerVsComputer)), count: 1)
        }
    }
    
    private func store() -> TestStoreOf<HomeViewReducer> {
        TestStore(initialState: HomeViewReducer.State(path: StackState<HomeViewReducer.Path.State>())) {
            HomeViewReducer()
        }
    }

}
