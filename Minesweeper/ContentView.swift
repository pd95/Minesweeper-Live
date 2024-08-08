//
//  ContentView.swift
//  Minesweeper
//
//  Created by Philipp on 08.08.2024.
//

import SwiftUI

enum GameState {
    case waiting, playing, won, lost
}

struct ContentView: View {

    @State private var rows = [[Square]]()

    @State private var gameState = GameState.waiting
    @State private var secondsElapsed = 0
    @State private var isHoveringOverRestart = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()


    var statusEmoji: String {
        if isHoveringOverRestart {
            "😮"
        } else {
            switch gameState {
            case .waiting, .playing:
                "🙂"
            case .won:
                "😎"
            case .lost:
                "😵"
            }
        }
    }

    var allSquares: [Square] {
        rows.flatMap { $0 }
    }

    var revealedSquares: [Square] {
        allSquares.filter(\.isRevealed)
    }

    var flaggedSquares: [Square] {
        allSquares.filter(\.isFlagged)
    }

    var minedSquares: [Square] {
        allSquares.filter(\.hasMine)
    }

    var minesFound: Int {
        max(0, minedSquares.count - flaggedSquares.count)
    }

    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 0) {
                    Text(minesFound.formatted(.number.precision(.integerLength(3))))
                        .fixedSize()
                        .padding(.horizontal, 6)
                        .foregroundStyle(.red.gradient)

                    Button(action: reset) {
                        Text(statusEmoji)
                            .padding(.horizontal, 6)
                            .background(.gray.opacity(0.5).gradient)
                    }
                    .onHover { hovering in
                        isHoveringOverRestart = hovering
                    }
                    .buttonStyle(.plain)

                    Text(secondsElapsed.formatted(.number.precision(.integerLength(3))))
                        .fixedSize()
                        .padding(.horizontal, 6)
                        .foregroundStyle(.red.gradient)
                }
                .monospaced()
                .font(.largeTitle)
                .background(.black)
                .clipShape(.rect(cornerRadius: 10))
                .padding(.top)

                Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                    ForEach(0..<rows.count, id: \.self) { row in
                        GridRow {
                            ForEach(rows[row]) { square in
                                SquareView(square: square, highlightMine: gameState == .lost)
                                    .onTapGesture {
                                        select(square)
                                    }
                                    .onLongPressGesture {
                                        flag(square)
                                    }
                            }
                        }
                    }
                }
                .font(.largeTitle)
                .onAppear(perform: createGrid)
                .preferredColorScheme(.dark)
                .clipShape(.rect(cornerRadius: 6))
                .padding([.horizontal, .bottom])
                .opacity(gameState == .waiting || gameState == .playing ? 1 : 0.5)
            }
            .disabled(gameState == .won || gameState == .lost)
            .onReceive(timer) { _ in
                guard gameState == .playing else { return }
                guard secondsElapsed < 999 else { return }
                secondsElapsed += 1
            }

            if gameState == .won || gameState == .lost {
                GameOverView(state: gameState) {
                    withAnimation {
                        reset()
                    }
                }
            }
        }
    }

    func createGrid() {
        rows.removeAll()
        for row in 0..<9 {
            var rowSquares = [Square]()

            for column in 0..<9 {
                let square = Square(row: row, column: column)
                //square.isRevealed = true
                rowSquares.append(square)
            }

            rows.append(rowSquares)
        }

        //placeMines(avoiding: rows[4][4])
    }

    func square(atRow row: Int, column: Int) -> Square? {
        if row < 0 { return nil }
        if row >= rows.count { return nil}
        if column < 0 { return nil }
        if column >= rows[row].count { return nil}
        return rows[row][column]
    }

    func getAdjacentSquares(toRow row: Int, column: Int) -> [Square] {
        var result = [Square?]()

        result.append(square(atRow: row - 1, column: column - 1))
        result.append(square(atRow: row - 1, column: column))
        result.append(square(atRow: row - 1, column: column + 1))

        result.append(square(atRow: row, column: column - 1))
        result.append(square(atRow: row, column: column + 1))

        result.append(square(atRow: row + 1, column: column - 1))
        result.append(square(atRow: row + 1, column: column))
        result.append(square(atRow: row + 1, column: column + 1))

        return result.compactMap { $0 }
    }


    func placeMines(avoiding: Square) {
        var possibleSquares = allSquares
        let disallowed = getAdjacentSquares(toRow: avoiding.row, column: avoiding.column) + CollectionOfOne(avoiding)
        possibleSquares.removeAll(where: disallowed.contains)

        for square in possibleSquares.shuffled().prefix(10) {
            square.hasMine = true
        }

        for row in rows {
            for square in row {
                let adjacentSquares = getAdjacentSquares(toRow: square.row, column: square.column)
                square.nearbyMines = adjacentSquares.filter(\.hasMine).count
            }
        }
    }

    func select(_ square: Square) {
        guard gameState == .waiting || gameState == .playing else { return }
        guard square.isRevealed == false else { return }
        guard square.isFlagged == false else { return }

        if revealedSquares.count == 0 {
            placeMines(avoiding: square)
            gameState = .playing
        }

        if square.hasMine == false && square.nearbyMines == 0 {
            reveal(square)
        } else {
            square.isRevealed = true

            if square.hasMine {
                withAnimation(.default.delay(0.25)) {
                    gameState = .lost
                }
            }
        }

        checkForWin()
    }

    func flag(_ square: Square) {
        guard square.isRevealed == false else { return }
        square.isFlagged.toggle()
    }

    func reveal(_ square: Square) {
        guard square.isRevealed == false else { return }
        guard square.isFlagged == false else { return }

        square.isRevealed = true
        if square.nearbyMines == 0 {
            let adjacentSquares = getAdjacentSquares(toRow: square.row, column: square.column)

            for adjacentSquare in adjacentSquares {
                reveal(adjacentSquare)
            }
        }
    }

    func checkForWin() {
        if revealedSquares.count == allSquares.count - minedSquares.count {
            withAnimation(.default.delay(0.25)) {
                gameState = .won
            }
        }
    }

    func reset() {
        secondsElapsed = 0
        gameState = .waiting
        createGrid()
    }
}

#Preview {
    ContentView()
}
