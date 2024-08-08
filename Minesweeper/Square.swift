//
//  Square.swift
//  Minesweeper
//
//  Created by Philipp on 08.08.2024.
//

import Foundation

@Observable
class Square: Equatable, Identifiable {
    var id = UUID()
    var row: Int
    var column: Int

    var hasMine = false
    var nearbyMines = 0
    var isRevealed = false
    var isFlagged = false

    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }

    static func sample(hasMine: Bool = false, nearbyMines: Int = 0, isFlagged: Bool = false) -> Square {
        let square = Square(row: 0, column: 0)
        square.isRevealed = isFlagged ? false : true
        square.hasMine = hasMine
        square.nearbyMines = nearbyMines
        square.isFlagged = isFlagged

        return square
    }

    static func ==(lhs: Square, rhs: Square) -> Bool {
        lhs.id == rhs.id
    }
}
