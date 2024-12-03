//
//  GameView.swift
//  TicTacToe
//
//  Created by Youssef JDIDI on 02/10/2024.
//

import SwiftUI
import ComposableArchitecture

struct GameView: View {
    let store: StoreOf<GameViewReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 16) {
                Text(viewStore.headerText)
                    .font(.title2)
                    .foregroundColor(viewStore.childState.currentPlayer.displayColor)
                    .padding(.bottom, 20)
                ForEach(0..<3) { row in
                    HStack {
                        ForEach(0..<3) { column in
                            ZStack(alignment: .center) {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .shadow(radius: 4)
                                
                                // Display X or O based on player's move
                                Text(viewStore.childState.board[row][column])
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(viewStore.childState.board[row][column] == "X" ? .blue : .orange)
                                    .scaleEffect(viewStore.childState.board[row][column].isEmpty ? 0.8 : 1.2)
                                    .animation(.easeInOut(duration: 0.2), value: viewStore.childState.board[row][column])
                            }
                            .onTapGesture {
                                handleTap(row: row, column: column)
                            }
                        }
                    }
                }
            }
            .onAppear {
                store.send(.idle)
            }
            .confirmationDialog(store: store.scope(state: \.$endGameState,
                                                   action: \.endGame))
        }
    }

    private func handleTap(row: Int, column: Int) {
        if store.childState.canTap(with: (row, column)) {
            store.send(.childAction(.playerMove((row, column))))
        }
    }
}
