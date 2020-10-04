//
//  DataStoreManager.swift
//  TaskList
//
//  Created by BEREZIN Stanislav on 03.10.2020.
//

import Foundation
import CoreData

class DataStoreManager {
    
    static let shared = DataStoreManager()

    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private init() {}

    // MARK: - Save
    func save(data: String?) {
        guard let entityDescription = NSEntityDescription.entity(
            forEntityName: "Task",
            in: persistentContainer.viewContext) else { return }
        
        guard let task = NSManagedObject(
                entity: entityDescription,
                insertInto: persistentContainer.viewContext) as? Task else { return }
        
        task.title = data
        save(context: persistentContainer.viewContext)
    }
    
    // MARK: - Fetch
    func fecthData() -> [Task] {
        var tasks: [Task] = []
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
        return tasks
    }
    
    // MARK: - Delete
    func delete(data: Task) {
        persistentContainer.viewContext.delete(data)
        save(context: persistentContainer.viewContext)
    }
    
    // MARK: - Edit
    func edit(titleInCurrentTask text: String?, at index: Int) {
        var tasks = fecthData()
        let selectedTask = tasks.remove(at: index)
        selectedTask.title = text
        tasks.insert(selectedTask, at: index)
        save(context: persistentContainer.viewContext)
    }

    // MARK: - Core Data Saving support
    private func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
