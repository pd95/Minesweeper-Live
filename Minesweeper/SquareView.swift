//
//  SquareView.swift
//  Minesweeper
//
//  Created by Philipp on 08.08.2024.
//

import SwiftUI

struct SquareView: View {
    let square: Square

    var color: Color {
        if square.isRevealed {
            .gray.opacity(0.2)
        } else {
            .gray
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(color.gradient)

            if square.isRevealed {
                if square.hasMine {
                    Text("💥")
                        .font(.system(size: 48))
                        .shadow(color: .red, radius: 1)
                } else if square.nearbyMines > 0 {
                    Text(String(square.nearbyMines))
                }
            } else if square.isFlagged {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.black, .yellow)
                    .shadow(color: .black, radius: 3)
            }
        }
        .frame(width: 60, height: 60)
    }
}

#Preview {

    var s1 = Square(row: 0, column: 0)
    var s2 = Square(row: 0, column: 0)
    s2.isRevealed = true
    var s3 = Square(row: 0, column: 0)
    s3.isFlagged = true
    var s4 = Square(row: 0, column: 0)
    s4.isRevealed = true
    s4.hasMine = true
    var s5 = Square(row: 0, column: 0)
    s5.isRevealed = true
    s5.nearbyMines = 3

    return VStack {
        SquareView(square: s1)
        SquareView(square: s2)
        SquareView(square: s3)
        SquareView(square: s4)
        SquareView(square: s5)
    }
    .padding()
}
