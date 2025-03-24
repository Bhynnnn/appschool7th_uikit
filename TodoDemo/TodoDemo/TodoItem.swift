//
//  TodoItem.swift
//  TodoDemo
//
//  Created by 강보현 on 3/21/25.
//

import UIKit
import CoreData

struct TodoItem: Hashable {
    let id: UUID
    let title: String
    var isCompleted: Bool
    
    init(id: UUID, title: String, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
    
    init(title: String, isCompleted: Bool) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        return lhs.id == rhs.id
    }
}


extension TodoItem {
    func toManagedObject(in context: NSManagedObjectContext) -> TodoItemEntity {
        let entity = TodoItemEntity(context: context)
        entity.id = id
        entity.title = title
        entity.isCompleted = isCompleted
        entity.createdAt = Date()
        return entity
    }
    
    static func from(_ entity: TodoItemEntity) -> TodoItem {
        guard let id = entity.id, let title = entity.title else {
            fatalError("Invalid TodoItemEntity")
        }
        let isCompleted = entity.isCompleted
        var item  = TodoItem(id: id, title: title, isCompleted: isCompleted)
        return item
    
    }
}
