//
//  ViewControllerViewModel.swift
//  ToDoApp
//
//  Created by Evgenii Kolgin on 27.08.2021.
//

import RealmSwift
import UIKit

class ViewControllerViewModel {
    
    let realm = try! Realm()
    
    var toDoItems: [ToDoListItem] = [] {
        didSet {
            updateSnapshot()
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, ToDoListItem>?
    
    func loadObjects() {
        toDoItems = realm.objects(ToDoListItem.self).map({ $0 })
    }
    
    func saveObject(_ object: ToDoListItem) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print("Error while saving object")
        }
        loadObjects()
    }
    
    func deleteObject(_ object: ToDoListItem) {
        do {
            try self.realm.write {
                self.realm.delete(object)
            }
        } catch  {
            print("Error while deleting object")
        }
        loadObjects()
    }
    
    func updateObject(_ object: ToDoListItem, text: String) {
        do {
            try realm.write() {
                object.itemText = text
            }
        } catch {
            print("Error while saving object")
        }
        loadObjects()
    }
    
    func toggleObject(_ object: ToDoListItem) {
        do {
            try realm.write() {
                object.isDone.toggle()
            }
        } catch {
            print("Error while saving object")
        }
        loadObjects()
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ToDoListItem>()
        snapshot.appendSections([.toDoSection, .doneSection])

        for item in toDoItems {
            if item.isDone {
                snapshot.appendItems([item], toSection: .doneSection)
            } else {
                snapshot.appendItems([item], toSection: .toDoSection)
            }
        }

        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
