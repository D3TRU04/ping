//
//  SaveToCollectionSheet.swift
//  PingNative
//
//  Source: ping/apps/src/screens/home/feeds/components/SaveToCollectionSheet.tsx
//  Modal sheet for saving places to collections
//

import SwiftUI

struct SaveToCollectionSheet: View {
    @Binding var visible: Bool
    let savedMap: [String: [String]]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Save to a collection")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Button(action: { visible = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
            }
            .padding()
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            // Create New Collection
            Button(action: {
                // TODO: Implement create new collection
            }) {
                HStack {
                    Text("Create new collection")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.mint)
                }
                .padding()
            }
            
            // Collections List
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(savedMap.keys.sorted()), id: \.self) { name in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(name.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("\(savedMap[name]?.count ?? 0) item\((savedMap[name]?.count ?? 0) == 1 ? "" : "s")")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        
                        if name != savedMap.keys.sorted().last {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 1)
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
