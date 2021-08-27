//
//  Model.swift
//  ToDoApp
//
//  Created by Evgenii Kolgin on 22.02.2021.
//

import Foundation
import RealmSwift

enum Section {
    case toDoSection, doneSection
    
    func description() -> String {
        switch self {
        case .toDoSection:
            return "I gotta do it"
        case .doneSection:
            return "I did it"
        }
    }
}

class ToDoListItem: Object {
    @objc dynamic var isDone: Bool = false
    @objc dynamic var itemText: String = ""
}
