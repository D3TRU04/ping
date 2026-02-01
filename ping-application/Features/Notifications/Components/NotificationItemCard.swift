//
//  NotificationItemCard.swift
//  PingNative
//
//  Individual notification item card component
//

import SwiftUI

struct NotificationItemCard: View {
    let notification: Notification
    let onPress: () -> Void
    let onMarkAsRead: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onPress) {
            HStack(spacing: 14) {
                // Icon with glow effect (similar to profile picture style)
                ZStack {
                    // Subtle glow for unread
                    if !notification.isRead {
                        Circle()
                            .fill(Color(hex: "1FC9C3").opacity(0.15))
                            .frame(width: 56, height: 56)
                            .blur(radius: 8)
                    }

                    Circle()
                        .fill(notification.isRead ? Color(hex: "F3F4F6") : Color(hex: "1FC9C3").opacity(0.12))
                        .frame(width: 48, height: 48)

                    Image(systemName: iconForType(notification.type))
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundColor(notification.isRead ? AppColors.textTertiary : Color(hex: "1FC9C3"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 16, weight: notification.isRead ? .regular : .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    Text(notification.body)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)

                    Text(formatDate(notification.createdAt))
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.top, 2)
                }

                Spacer()

                // Unread indicator
                if !notification.isRead {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 10, height: 10)
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(notification.isRead ? 0.03 : 0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            if !notification.isRead {
                Button(action: onMarkAsRead) {
                    Label("Mark as Read", systemImage: "checkmark.circle")
                }
            }

            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func iconForType(_ type: String) -> String {
        switch type {
        case "follow": return "person.badge.plus"
        case "place_visit": return "mappin.circle"
        case "place_recommendation": return "star.circle"
        case "chat_message": return "message"
        default: return "bell"
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
