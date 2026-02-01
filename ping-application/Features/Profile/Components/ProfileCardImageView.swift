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
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textTertiary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(hex: "F3F4F6"))
                @unknown default:
                    Color(hex: "F3F4F6")
                }
            }
        case .image(let name):
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}
