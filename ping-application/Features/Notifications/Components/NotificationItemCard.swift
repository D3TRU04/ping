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
                // Icon with clear glass background
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 52, height: 52)
                        .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 0.5))
                    
                    Image(systemName: iconForType(notification.type))
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundColor(notification.isRead ? AppColors.textTertiary : Color(hex: "1FC9C3"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 16, weight: notification.isRead ? .medium : .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    Text(notification.body)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary.opacity(0.7))
                        .lineLimit(2)

                    Text(formatDate(notification.createdAt))
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textPrimary.opacity(0.4))
                        .padding(.top, 2)
                }

                Spacer()

                // Unread indicator
                if !notification.isRead {
                    Circle()
                        .fill(AppColors.mint)
                        .frame(width: 10, height: 10)
                        .shadow(color: AppColors.mint.opacity(0.5), radius: 4)
                }
            }
            .padding(18)
            .glassCardStyle(cornerRadius: 30, opacity: 0.08)
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
