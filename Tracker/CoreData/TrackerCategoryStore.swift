//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Аркадий Червонный on 26.02.2026.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerStore(
        _ store: TrackerCategoryStore,
        didUpdate update: StoreUpdate
    )
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerCategoryStoreDelegate?
    private var inserted = IndexSet()
    private var deleted = IndexSet()
    private var updated = IndexSet()
    private var moved: [(from: Int, to: Int)] = []
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate is not available or has unexpected type")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.header, ascending: true)
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
    
    func fetchCategories() -> [TrackerCategory] {
        let objects = fetchedResultsController.fetchedObjects ?? []
        return objects.map { coreData in
            TrackerCategory(
                header: coreData.header ?? "",
                trackers: []
            )
        }
    }

    func addCategory(title: String) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        if categoryExists(with: trimmedTitle) {
            return
        }

        let category = TrackerCategoryCoreData(context: context)
        category.header = trimmedTitle

        try context.save()
        try fetchedResultsController.performFetch()
    }

    private func categoryExists(with title: String) -> Bool {
        let request = TrackerCategoryCoreData.fetchRequest() as NSFetchRequest<TrackerCategoryCoreData>
        request.predicate = NSPredicate(format: "header == %@", title)
        request.fetchLimit = 1

        let result = try? context.fetch(request)
        return !(result?.isEmpty ?? true)
    }
    
    private func resetChanges() {
        inserted.removeAll()
        deleted.removeAll()
        updated.removeAll()
        moved.removeAll()
    }
    
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        resetChanges()
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
            guard let indexPath = newIndexPath else { return }
            inserted.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { return }
            deleted.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { return }
            updated.insert(indexPath.item)
        case .move:
            guard let from = indexPath?.item, let to = newIndexPath?.item else { return }
            moved.append((from: from, to: to))
        @unknown default:
            return
        }
    }
}
