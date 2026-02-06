//
//  TodayViewModel+Actions.swift
//  PingNative
//
//  Like and save toggle actions for Today feed
//

import Foundation

extension TodayViewModel {

    func toggleLike(placeId: String, isLiked: Bool, userId: String) async {
        guard let placesService = placesService else {
            #if DEBUG
            print("❌ Today toggleLike: placesService not configured")
            #endif
            return
        }

        #if DEBUG
        print("🔄 Today toggleLike: placeId=\(placeId), isLiked=\(isLiked)")
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
                print("✅ Today toggleLike: recorded visit for \(placeId)")
                #endif
                // Notify followers about place visit
                if let notificationsService = notificationsService,
                   let profileService = profileService {
                    Task {
                        let place = todayFeedItems.first { $0.id == placeId }
                        let placeName = place?.name ?? "a place"
                        if let followers = try? await profileService.fetchFollowers(userId: userId) {
                            for follower in followers {
                                try? await notificationsService.createNotification(
                                    recipientId: follower.id,
                                    senderId: userId,
                                    type: "place_visit",
                                    title: "Place Visit",
                                    message: "Someone you follow visited \(placeName)",
                                    metadata: ["sender_id": userId, "place_name": placeName, "place_id": placeId]
                                )
                            }
                        }
                    }
                }
            } else {
                try await placesService.removePlaceVisit(userId: userId, placeId: placeId)
                #if DEBUG
                print("✅ Today toggleLike: removed visit for \(placeId)")
                #endif
            }
        } catch {
            #if DEBUG
            print("❌ Today toggleLike error: \(error)")
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
            print("❌ Today toggleSave: collectionsService not configured")
            #endif
            return
        }

        let isSaved = savedPlaces.contains(placeId)

        #if DEBUG
        print("🔄 Today toggleSave: placeId=\(placeId), currently saved=\(isSaved), will be saved=\(!isSaved)")
        #endif

        // Optimistic update
        if isSaved {
            savedPlaces.remove(placeId)
            savedMap["all_saved"]?.removeAll { $0 == placeId }
        } else {
            savedPlaces.insert(placeId)
            if savedMap["all_saved"] == nil {
                savedMap["all_saved"] = []
            }
            savedMap["all_saved"]?.append(placeId)
        }

        do {
            if isSaved {
                try await collectionsService.unsavePlaceFromAll(userId: userId, placeId: placeId)
                #if DEBUG
                print("✅ Today toggleSave: unsaved \(placeId)")
                #endif
            } else {
                var collectionId = defaultCollectionId
                if collectionId == nil {
                    collectionId = try await collectionsService.getOrCreateDefaultCollection(userId: userId)
                    defaultCollectionId = collectionId
                }
                _ = try await collectionsService.savePlace(userId: userId, placeId: placeId, collectionId: collectionId!)
                #if DEBUG
                print("✅ Today toggleSave: saved \(placeId) to collection \(collectionId ?? "unknown")")
                #endif
            }
        } catch {
            #if DEBUG
            print("❌ Today toggleSave error: \(error)")
            #endif
            // Revert on error
            if isSaved {
                savedPlaces.insert(placeId)
                savedMap["all_saved"]?.append(placeId)
            } else {
                savedPlaces.remove(placeId)
                savedMap["all_saved"]?.removeAll { $0 == placeId }
            }
        }
    }
}
