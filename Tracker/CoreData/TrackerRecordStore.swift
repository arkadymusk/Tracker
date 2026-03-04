//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Аркадий Червонный on 26.02.2026.
//

import CoreData
import UIKit

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerStore(
        _ store: TrackerRecordStore,
        didUpdate update: StoreUpdate
    )
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerRecordStoreDelegate?
    private var inserted = IndexSet()
    private var deleted = IndexSet()
    private var updated = IndexSet()
    private var moved: [(from: Int, to: Int)] = []
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            assertionFailure("fetch failed: \(error)")
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        inserted.removeAll()
        deleted.removeAll()
        updated.removeAll()
        moved.removeAll()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStore(
            self,
            didUpdate: StoreUpdate(
                insertedIndexes: inserted,
                deletedIndexes: deleted,
                updatedIndexes: updated,
                movedIndexes: moved
            )
        )
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            inserted.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deleted.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updated.insert(indexPath.item)
        case .move:
            guard let from = indexPath?.item, let to = newIndexPath?.item else { return }
            moved.append((from: from, to: to))
        @unknown default:
            fatalError()
        }
    }
}
