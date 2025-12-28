//
//  HomeViewModel.swift
//  PingNative
//
//  Created on 12/3/25.
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // TODO: Add actual data models based on RN app
    // @Published var items: [Item] = []
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement actual data loading from Supabase
        // This is a placeholder that assumes the RN app loads some list of items
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        isLoading = false
    }
    
    func refresh() async {
        await load()
    }
}
