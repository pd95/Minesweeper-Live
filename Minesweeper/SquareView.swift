//
//  SquareView.swift
//  Minesweeper
//
//  Created by Philipp on 08.08.2024.
//

import SwiftUI

struct SquareView: View {
    let square: Square
    var highlightMine: Bool = false

    var color: Color {
        if square.isRevealed {
            .gray.opacity(0.2)
        } else {
            .gray
        }
    }

    var textColor: Color {
        Color("mine \(square.nearbyMines)")
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
                        .foregroundStyle(textColor)
                        .bold()
                }
            } else if square.hasMine && highlightMine {
                Text("💣")
                    .font(.system(size: 48))
                    .shadow(color: .gray, radius: 1)
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
    Grid(horizontalSpacing: 2, verticalSpacing: 2) {
        GridRow {
            SquareView(square: Square(row: 0, column: 0))
            SquareView(square: .sample())
            SquareView(square: .sample(isFlagged: true))
            SquareView(square: .sample(hasMine: true), highlightMine: true)
            SquareView(square: .sample(hasMine: true))
        }
        GridRow {
            SquareView(square: .sample(nearbyMines: 1))
            SquareView(square: .sample(nearbyMines: 2))
            SquareView(square: .sample(nearbyMines: 3))
            SquareView(square: .sample(nearbyMines: 4))
        }
        GridRow {
            SquareView(square: .sample(nearbyMines: 5))
            SquareView(square: .sample(nearbyMines: 6))
            SquareView(square: .sample(nearbyMines: 7))
            SquareView(square: .sample(nearbyMines: 8))
        }
    }
    .font(.largeTitle)
    .preferredColorScheme(.dark)
    .padding()
}
