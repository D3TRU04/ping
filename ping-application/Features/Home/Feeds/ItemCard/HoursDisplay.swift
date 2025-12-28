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
    
    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.mint)
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    if expanded {
                        // Show all grouped hours
                        ForEach(groupHours(hours), id: \.id) { group in
                            Text(formatGroupedHours(group))
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                        }
                    } else {
                        // Show only today's hours
                        ForEach(getTodayHours(), id: \.self) { hour in
                            Text(formatTodayHour(hour))
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color(hex: "F5F6FA"))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func groupHours(_ hoursArr: [String]) -> [HourGroup] {
        let parsed = hoursArr.map { hour -> (day: String, time: String) in
            let parts = hour.split(separator: ":")
            guard let day = parts.first else { return ("", "") }
            let time = parts.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            return (String(day), time)
        }
        
        let sorted = parsed.sorted { dayOrder.firstIndex(of: $0.day) ?? 0 < dayOrder.firstIndex(of: $1.day) ?? 0 }
        
        var groups: [HourGroup] = []
        var i = 0
        
        while i < sorted.count {
            var start = i
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
    
    private func formatGroupedHours(_ group: HourGroup) -> String {
        let startShort = dayShort[group.start] ?? group.start
        let endShort = dayShort[group.end] ?? group.end
        
        if group.start == group.end {
            return "\(startShort): \(group.time)"
        } else {
            return "\(startShort)–\(endShort): \(group.time)"
        }
    }
    
    private func formatTodayHour(_ hour: String) -> String {
        let time = hour.split(separator: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
        let todayShort = dayShort[todayName] ?? todayName
        return "\(todayShort): \(time)"
    }
}

struct HourGroup: Identifiable {
    let id: UUID
    let start: String
    let end: String
    let time: String
}
