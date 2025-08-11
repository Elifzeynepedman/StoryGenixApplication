//
//  SquareThumbnailView.swift
//  StoryGenix
//
//  Created by Elif Edman on 11.08.2025.
//

import SwiftUI

struct SquareThumbnailView: View {
    let imageURL: String
    let isSelected: Bool
    let onTap: () -> Void
    let onSelect: () -> Void

    var body: some View {
        GeometryReader { geo in
            let side = geo.size.width
            ZStack(alignment: .topTrailing) {
                Button(action: onTap) {
                    // Reserve a square frame and fill it
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.05))
                            .frame(width: side, height: side)

                        AsyncImage(url: URL(string: imageURL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: side, height: side)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: side, height: side)
                            case .failure:
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.white)
                                    .frame(width: side, height: side)
                            @unknown default:
                                EmptyView()
                                    .frame(width: side, height: side)
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button(action: onSelect) {
                    Circle()
                        .fill(isSelected ? Color.green : Color.black.opacity(0.3))
                        .frame(width: 26, height: 26)
                        .overlay {
                            if isSelected {
                                Image(systemName: "checkmark").foregroundColor(.white)
                            } else {
                                Circle().stroke(Color.white, lineWidth: 1)
                            }
                        }
                        .padding(6)
                }
            }
        }
        // Important: give the grid a square footprint to allocate space.
        .aspectRatio(1, contentMode: .fit)
    }
}
