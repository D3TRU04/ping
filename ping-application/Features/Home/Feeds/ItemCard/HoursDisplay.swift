//
//  HoursDisplay.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/feeds/item-card/components/HoursDisplay.tsx
//  Hours display with expand/collapse functionality
//

import SwiftUI

struct HoursDisplay: View {
    let hours: [String]
    let expanded: Bool
    let onToggle: () -> Void
    
    private let dayOrder = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private let dayShort: [String: String] = [
        "Monday": "Mon",
        "Tuesday": "Tue",
        "Wednesday": "Wed",
        "Thursday": "Thu",
        "Friday": "Fri",
        "Saturday": "Sat",
        "Sunday": "Sun"
    ]
    
    private var todayName: String {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        // Convert from 1-7 (Sunday-Saturday) to Monday-Sunday
        let index = weekday == 1 ? 6 : weekday - 2
        return dayOrder[index]
    }
    
    private var todayShort: String {
        dayShort[todayName] ?? todayName
    }
    
    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.mint)
                    .padding(.top, 1)
                
                VStack(alignment: .leading, spacing: 2) {
                    if expanded {
                        // Show all grouped hours
                        let groups = groupHours(hours)
                        if groups.isEmpty {
                            Text("Hours unavailable")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        } else {
                            ForEach(groups, id: \.id) { group in
                                Text(formatGroupedHours(group))
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }
                    } else {
                        // Show today's hours or first available
                        let todayHours = getTodayHours()
                        if !todayHours.isEmpty {
                            ForEach(todayHours, id: \.self) { hour in
                                Text(formatTodayHour(hour))
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        } else if let firstHour = hours.first {
                            // Show first available hours as fallback
                            Text(formatAnyHour(firstHour))
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        } else {
                            Text("See hours")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Expand/collapse indicator
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(AppColors.textTertiary)
                    .padding(.top, 3)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color(hex: "F5F6FA"))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func groupHours(_ hoursArr: [String]) -> [HourGroup] {
        let parsed = hoursArr.compactMap { hour -> (day: String, time: String)? in
            let parts = hour.split(separator: ":")
            guard let day = parts.first else { return nil }
            let time = parts.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            return (String(day), time)
        }
        
        let sorted = parsed.sorted { dayOrder.firstIndex(of: $0.day) ?? 0 < dayOrder.firstIndex(of: $1.day) ?? 0 }
        
        var groups: [HourGroup] = []
        var i = 0
        
        while i < sorted.count {
            let start = i
            var end = i
            
            while end + 1 < sorted.count &&
                  sorted[end + 1].time == sorted[start].time &&
                  (dayOrder.firstIndex(of: sorted[end + 1].day) ?? 0) == (dayOrder.firstIndex(of: sorted[end].day) ?? 0) + 1 {
                end += 1
            }
            
            groups.append(HourGroup(
                id: UUID(),
                start: sorted[start].day,
                end: sorted[end].day,
                time: sorted[start].time
            ))
            
            i = end + 1
        }
        
        return groups
    }
    
    private func getTodayHours() -> [String] {
        return hours.filter { $0.hasPrefix(todayName) }
    }
    
    private func compactTime(_ time: String) -> String {
        return time
            .replacingOccurrences(of: ":00", with: "")
            .replacingOccurrences(of: " AM", with: "am")
            .replacingOccurrences(of: " PM", with: "pm")
            .replacingOccurrences(of: " - ", with: "–")
    }
    
    private func formatGroupedHours(_ group: HourGroup) -> String {
        let startShort = dayShort[group.start] ?? group.start
        let endShort = dayShort[group.end] ?? group.end
        let time = compactTime(group.time)
        
        if group.start == group.end {
            return "\(startShort): \(time)"
        } else {
            return "\(startShort)–\(endShort): \(time)"
        }
    }
    
    private func formatTodayHour(_ hour: String) -> String {
        let time = hour.split(separator: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
        return "\(todayShort): \(compactTime(time))"
    }
    
    private func formatAnyHour(_ hour: String) -> String {
        let parts = hour.split(separator: ":")
        guard let day = parts.first else { return hour }
        let time = parts.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
        let shortDay = dayShort[String(day)] ?? String(day)
        return "\(shortDay): \(compactTime(time))"
    }
}

struct HourGroup: Identifiable {
    let id: UUID
    let start: String
    let end: String
    let time: String
}
