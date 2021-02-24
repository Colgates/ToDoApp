//
//  Model.swift
//  ToDoApp
//
//  Created by Evgenii Kolgin on 22.02.2021.
//

import Foundation
import RealmSwift

enum Section {
    case main
}

class ToDoListItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var itemText: String = ""
}
