//
//  GameViewReducer.swift
//  TicTacToe
//
//  Created by Youssef JDIDI on 02/10/2024.
//

import ComposableArchitecture
import Foundation

@Reducer
struct GameViewReducer {
    @ObservableState
    struct State: Equatable {
        var childState: GameEngineReducer.State
        var headerText: String = ""
        @Presents var endGameState: ConfirmationDialogState<Action.AlertAction>?
        
        init(gameType: GameType) {
            self.childState = .init(gameType: gameType, difficulty: .medium)
        }
        enum GameViewState {
            case idle
        }
    }
    enum Action {
        case childAction(GameEngineReducer.Action)
        case idle
        case close
        case headerText(String)
        case endGame(PresentationAction<AlertAction>)
        
        enum AlertAction: Equatable {
            case close
            case open
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.childState, action: \.childAction) {
            GameEngineReducer()
        }
        Reduce { state, action in
            switch action {
                case .idle: return .send(.childAction(.startGame))
                case .childAction(let childAction):
                    switch childAction {
                        case .gameStateChanged(let childGameState):
                            switch childGameState {
                                case .ongoing,
                                        .idle:
                                    return .none
                                case .draw: return Effect.concatenate(.send(.headerText("It's a draw!")),
                                                                      .run { send in
                                                                          try await Task.sleep(nanoseconds: 1_000_000_000)
                                                                          await send(.endGame(PresentationAction.presented(.open)))
                                                                      })
                                case .win(let player):
                                    return Effect.concatenate(.send(.headerText("\(player.name) wins!")),
                                                              .run { send in
                                                                  try await Task.sleep(nanoseconds: 1_000_000_000)
                                                                  await send(.endGame(PresentationAction.presented(.open)))
                                                              })
                            }
                        case .nextPlay:
                            return .send(.headerText("\(state.childState.currentPlayer.name) turn"))
                        default: return .none
                    }
                case .endGame(let alertAction):
                    if case .presented(.open) = alertAction {
                        state.endGameState = ConfirmationDialogState<Action.AlertAction>(title: {
                            TextState("Game Over")
                        }, actions: {
#warning("TODO")
                            ButtonState<Action.AlertAction>(role: nil, action: .close, label: {
                                TextState("Play again")
                            })
                        })
                    } else {
                        state.endGameState = nil
                    }
                    return .none
                case .close: return .none
                case .headerText(let text):
                    state.headerText = text
                    return .none
            }
        }
    }
}
