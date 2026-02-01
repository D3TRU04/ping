//
//  ForYouViewModel+Actions.swift
//  PingNative
//
//  Like and save actions for ForYou feed
//

import Foundation

extension ForYouViewModel {

    func toggleLike(placeId: String, isLiked: Bool, userId: String) async {
        guard let placesService = placesService else {
            #if DEBUG
            print("❌ ForYou toggleLike: placesService not configured")
            #endif
            return
        }

        #if DEBUG
        print("🔄 ForYou toggleLike: placeId=\(placeId), isLiked=\(isLiked)")
        #endif

        // Optimistic update
        if isLiked {
            likedPlaces.insert(placeId)
        } else {
            likedPlaces.remove(placeId)
        }

        do {
            if isLiked {
                _ = try await placesService.recordPlaceVisit(userId: userId, placeId: placeId)
                #if DEBUG
                print("✅ ForYou toggleLike: recorded visit for \(placeId)")
                #endif
            } else {
                try await placesService.removePlaceVisit(userId: userId, placeId: placeId)
                #if DEBUG
                print("✅ ForYou toggleLike: removed visit for \(placeId)")
                #endif
            }
        } catch {
            #if DEBUG
            print("❌ ForYou toggleLike error: \(error)")
            #endif
            // Revert on error
            if isLiked {
                likedPlaces.remove(placeId)
            } else {
                likedPlaces.insert(placeId)
            }
        }
    }

    func toggleSave(placeId: String, listName: String, userId: String) async {
        guard let collectionsService = collectionsService else {
            #if DEBUG
            print("❌ ForYou toggleSave: collectionsService not configured")
            #endif
            return
        }

        let isSaved = savedPlaces.contains(placeId)

        #if DEBUG
        print("🔄 ForYou toggleSave: placeId=\(placeId), currently saved=\(isSaved), will be saved=\(!isSaved)")
        #endif

        // Optimistic update
        if isSaved {
            savedPlaces.remove(placeId)
            savedMap[listName]?.removeAll { $0 == placeId }
        } else {
            savedPlaces.insert(placeId)
            if savedMap[listName] == nil {
                savedMap[listName] = []
            }
            savedMap[listName]?.append(placeId)
        }

        do {
            if isSaved {
                try await collectionsService.unsavePlaceFromAll(userId: userId, placeId: placeId)
                #if DEBUG
                print("✅ ForYou toggleSave: unsaved \(placeId)")
                #endif
            } else {
                var collectionId = defaultCollectionId
                if collectionId == nil {
                    collectionId = try await collectionsService.getOrCreateDefaultCollection(userId: userId)
                    self.defaultCollectionId = collectionId
                }
                _ = try await collectionsService.savePlace(userId: userId, placeId: placeId, collectionId: collectionId!)
                #if DEBUG
                print("✅ ForYou toggleSave: saved \(placeId) to collection \(collectionId ?? "unknown")")
                #endif
            }
        } catch {
            #if DEBUG
            print("❌ ForYou toggleSave error: \(error)")
            #endif
            // Revert on error
            if isSaved {
                savedPlaces.insert(placeId)
                if savedMap[listName] == nil {
                    savedMap[listName] = []
                }
                savedMap[listName]?.append(placeId)
            } else {
                savedPlaces.remove(placeId)
                savedMap[listName]?.removeAll { $0 == placeId }
            }
        }
    }
}
