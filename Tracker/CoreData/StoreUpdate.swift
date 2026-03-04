//
//  StoreUpdate.swift
//  Tracker
//
//  Created by Аркадий Червонный on 04.03.2026.
//
import CoreData

struct StoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: [(from: Int, to: Int)]
}
