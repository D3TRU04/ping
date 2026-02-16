//
//  ProfileCardImageView.swift
//  PingNative
//
//  Image source and profile image view for profile card
//

import SwiftUI

enum ImageSource {
    case url(URL?)
    case image(String)
    case placeholder
}

struct ProfileImageView: View {
    let source: ImageSource

    var body: some View {
        switch source {
        case .url(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Color(hex: "F3F4F6")
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderView
                @unknown default:
                    Color(hex: "F3F4F6")
                }
            }
        case .image(let name):
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fill)
        case .placeholder:
            placeholderView
        }
    }

    private var placeholderView: some View {
        Image(systemName: "person.fill")
            .font(.system(size: 28))
            .foregroundColor(AppColors.textTertiary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "F3F4F6"))
    }
}
