//
//  GameEngine.swift
//  TicTacToe
//
//  Created by Youssef JDIDI on 19/10/2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI

enum Player: CaseIterable {
    case home, visitor

    var name: String {
        switch self {
            case .home:
                return "Player 1"
            case .visitor:
                return "Player 2"
        }
    }

    var symbol: String {
        switch self {
            case .home:
                return "X"
            case .visitor:
                return "O"
        }
    }

    var opponentSymbol: String {
        switch self {
            case .home:
                return "O"
            case .visitor:
                return "X"
        }
    }
    
    var displayColor: Color {
        switch self {
            case .home:
                return .blue
            case .visitor:
                return .orange
        }
    }
}

enum GameType {
    case playerVsPlayer
    case playerVsComputer
    case computerVsComputer
}

enum Difficulty {
    case easy
    case medium
    case hard
}

enum GameState: Equatable {
    case idle
    case ongoing
    case win(Player)
    case draw
}

@Reducer
struct GameEngineReducer {
    @ObservableState
    struct State: Equatable {
        let gameType: GameType
        let difficulty: Difficulty
        var gameState: GameState
        var currentPlayer: Player
        var moveCount: Int
        var board: Board = [["", "", ""], ["", "", ""], ["", "", ""]]
        var boardInteractionEnabled: Bool = true

        init(gameType: GameType, difficulty: Difficulty) {
            self.gameType = gameType
            self.difficulty = difficulty
            self.currentPlayer = gameType == .computerVsComputer ? Player.allCases.randomElement() ?? .home : .home
            self.gameState = .idle
            self.moveCount = 0
        }
        
        func canTap(with move: Move) -> Bool {
            board[move.0][move.1].isEmpty && gameState == .ongoing && boardInteractionEnabled
        }
    }
    enum Action {
        case startGame
        case gameStateChanged(GameState)
        case nextPlay
        case computerMove(Player, Difficulty, Board)
        case playerMove(Move)
        case switchPlayer
    }

    typealias Move = (Int, Int)
    typealias Board = [[String]]

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .startGame:
                    return .run { send in
                        await send(.gameStateChanged(.ongoing))
                        await send(.nextPlay)
                    }
                case .nextPlay:
                    guard state.gameState == .ongoing else { return .none }
                    state.boardInteractionEnabled = state.gameType == .playerVsPlayer ||
                    (state.currentPlayer == .home && state.gameType == .playerVsComputer)
                    return nextToPlay(state)
                case .gameStateChanged(let gameState):
                    state.gameState = gameState
                    return .none
                case .computerMove(let player, let difficulty, let board):
                    state.boardInteractionEnabled = false
                    return .run(priority: .background) { send in
                        try? await Task.sleep(for: .seconds(1))
                        let move = await computerMove(player: player,
                                                      difficulty: difficulty,
                                                      board: board)
                        return await send(.playerMove(move))
                    }
                case .playerMove(let move):
                    state.board[move.0][move.1] = state.currentPlayer.symbol
                    state.moveCount += 1
                    return checkGameState(state: state)
                case .switchPlayer:
                    state.currentPlayer = state.currentPlayer == .home ? .visitor : .home
                    return .send(.nextPlay)
            }
        }
    }

    private func nextToPlay(_ state: State) -> Effect<Action> {
        switch state.gameType {
            case .playerVsPlayer:
                return .none
            case .playerVsComputer:
                switch state.currentPlayer {
                    case .home: return .none
                    case .visitor: return .send(.computerMove(.visitor, state.difficulty, state.board))
                }
            case .computerVsComputer:
                return .send(.computerMove(state.currentPlayer, state.difficulty, state.board))
        }
    }

    private func computerMove(player: Player, difficulty: Difficulty, board: Board) async -> Move {
        return switch difficulty {
            case .easy:
                self.getRandomMove(board)
            case .medium:
                findBlockingMove(player: player, board: board)
            case .hard:
                await makeBestMove(player: player, board: board)
        }
    }

    private func isValidMove(_ move: Move, _ board: Board) -> Bool {
        return board[move.0][move.1].isEmpty
    }

    private func updateBoard(with move: Move, state: inout State) {
        state.board[move.0][move.1] = state.currentPlayer.symbol
        state.moveCount += 1
    }

    private func getRandomMove(_ board: Board) -> Move {
        let emptyCells = getEmptyCells(board: board)
        return emptyCells.randomElement() ?? (0, 0)
    }

    private func checkGameState(state: State) -> Effect<Action> {
        if checkWin(for: state.currentPlayer.symbol, board: state.board) {
            return .send(.gameStateChanged(.win(state.currentPlayer)))
        }

        if state.moveCount >= 9 {
            return .send(.gameStateChanged(.draw))
        }
        return .send(.switchPlayer)
    }

    private func findBlockingMove(player: Player, board: Board) -> Move {
        for (row, col) in getEmptyCells(board: board) {
            var tempBoard = board
            tempBoard[row][col] = player.opponentSymbol
            if checkWin(for: player.opponentSymbol, board: tempBoard) {
                return (row, col)
            }
        }
        return getRandomMove(board)
    }

    private func makeBestMove(player: Player, board: Board) async -> Move {
        var bestScore = Int.min
        var bestMove: Move?
        await withTaskGroup(of: (Move, Int).self) { group in
            for (row, col) in getEmptyCells(board: board) {
                group.addTask {
                    var board = board
                    board[row][col] = player.symbol
                    let score = await minimax(player: player,
                                              board: board,
                                              depth: 3,
                                              isMaximizing: false)
                    board[row][col] = ""
                    return ((row, col), score)
                }
            }

            for await (move, score) in group {
                if score > bestScore {
                    bestScore = score
                    bestMove = move
                }
            }
        }
        
        return bestMove ?? findBlockingMove(player: player, board: board)
    }

    private func minimax(player: Player,
                         board: Board,
                         depth: Int,
                         isMaximizing: Bool) async -> Int {
        if checkWin(for: player.symbol, board: board) { return 10 - depth }
        if checkWin(for: player.opponentSymbol, board: board) { return depth - 10 }
        if isBoardFull(board: board) { return 0 }

        if isMaximizing {
            var maxEval = Int.min
            for (row, col) in getEmptyCells(board: board) {
                var board = board
                board[row][col] = player.symbol
                let eval = await minimax(player: player,
                                         board: board,
                                         depth: depth + 1,
                                         isMaximizing: false)
                maxEval = max(maxEval, eval)
            }
            return maxEval
        } else {
            var minEval = Int.max
            for (row, col) in getEmptyCells(board: board) {
                var board = board
                board[row][col] = player.opponentSymbol
                let eval = await minimax(player: player,
                                         board: board,
                                         depth: depth + 1,
                                         isMaximizing: true)
                minEval = min(minEval, eval)
            }
            return minEval
        }
    }

    private func checkWin(for player: String, board: Board) -> Bool {
        return (0..<3).contains { board[$0].allSatisfy { $0 == player } } ||
        (0..<3).contains { value in board.map { l in l[value] }.allSatisfy { $0 == player } } ||
        [board[0][0], board[1][1], board[2][2]].allSatisfy { $0 == player } ||
        [board[0][2], board[1][1], board[2][0]].allSatisfy { $0 == player }
    }
    
    private func getEmptyCells(board: Board) -> [(Int, Int)] {
        var emptyCells: [(Int, Int)] = []
        for row in 0..<3 {
            for col in 0..<3 where board[row][col] == "" {
                emptyCells.append((row, col))
            }
        }
        return emptyCells
    }
    
    private func isBoardFull(board: Board) -> Bool {
        return !board.joined().contains("")
    }
}
