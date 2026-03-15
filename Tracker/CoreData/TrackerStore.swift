//
//  TrackerStore.swift
//  Tracker
//
//  Created by Аркадий Червонный on 26.02.2026.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func trackerStore(
        _ store: TrackerStore,
        didUpdate update: StoreUpdate
    )
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?
    private var inserted = IndexSet()
    private var deleted = IndexSet()
    private var updated = IndexSet()
    private var moved: [(from: Int, to: Int)] = []
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
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
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.header", ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.title, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.header",
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
    
    var trackers: [Tracker] {
        guard
            let objects = fetchedResultsController.fetchedObjects
        else { return [] }

        return objects.compactMap { core in
            guard
                let id = core.id,
                let title = core.title,
                let emoji = core.emoji
            else { return nil }

            let color = UIColor(UInt32(core.color))
            let schedule = decodeSchedule(core.schedule)

            return Tracker(
                id: id,
                title: title,
                color: color,
                emoji: emoji,
                schedule: schedule
            )
        }
    }

    var categories: [TrackerCategory] {
        let sections = fetchedResultsController.sections ?? []
        return sections.map { section in
            let trackerObjects: [TrackerCoreData] = section.objects as? [TrackerCoreData] ?? []
            let trackers: [Tracker] = trackerObjects.compactMap { core in
                guard
                    let id = core.id,
                    let title = core.title,
                    let emoji = core.emoji
                else { return nil }

                let color = UIColor(UInt32(core.color))
                let schedule = decodeSchedule(core.schedule)

                return Tracker(
                    id: id,
                    title: title,
                    color: color,
                    emoji: emoji,
                    schedule: schedule
                )
            }

            return TrackerCategory(header: section.name, trackers: trackers)
        }
    }

    func addTracker(_ tracker: Tracker, toCategory title: String) throws {
        let category = fetchCategory(with: title) ?? createCategory(with: title)

        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = Int64(tracker.color.toHex())
        trackerCoreData.schedule = encodeSchedule(tracker.schedule)
        trackerCoreData.category = category

        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let request = TrackerCoreData.fetchRequest() as NSFetchRequest<TrackerCoreData>
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1

        guard let trackerCoreData = try context.fetch(request).first else {
            return
        }

        let category = fetchCategory(with: categoryTitle) ?? createCategory(with: categoryTitle)

        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = Int64(tracker.color.toHex())
        trackerCoreData.schedule = encodeSchedule(tracker.schedule)
        trackerCoreData.category = category

        try context.save()
    }

    private func fetchCategory(with title: String) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest() as NSFetchRequest<TrackerCategoryCoreData>
        request.predicate = NSPredicate(format: "header == %@", title)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func createCategory(with title: String) -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.header = title
        return category
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1

        let result = try context.fetch(request)
        guard let object = result.first else { return }

        context.delete(object)
        try context.save()
    }

    private func encodeSchedule(_ schedule: [Weekday]) -> Data? {
        let raw = schedule.map { $0.rawValue }
        return try? JSONEncoder().encode(raw)
    }

    private func decodeSchedule(_ data: Data?) -> [Weekday] {
        guard let data else { return [] }
        let raw = (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        return raw.compactMap { Weekday(rawValue: $0) }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
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
