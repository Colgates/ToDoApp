//
//  ViewController.swift
//  ToDoApp
//
//  Created by Evgenii Kolgin on 20.11.2020.
//
import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let realm = try! Realm()
    
    var notes = [ToDoListItem]()
    
    private var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, ToDoListItem>!
    
    var snapshot: NSDiffableDataSourceSnapshot<Section, ToDoListItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        view.backgroundColor = .systemBackground
        title = "ToDoList"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        setupCollectionView()
        collectionView.delegate = self
        
        loadObjects()
        updateDataSource()
    }
    
    func setupCollectionView() {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        layoutConfig.trailingSwipeActionsConfigurationProvider = { [unowned self] (indexPath) in
            
            guard let item = dataSource.itemIdentifier(for: indexPath) else {
                return nil
            }
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
                deleteSwipe(for: action, item: item)
                completion(true)
            }
            
            //
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        layoutConfig.leadingSwipeActionsConfigurationProvider = { [unowned self] (indexPath) in
            guard let item = dataSource.itemIdentifier(for: indexPath) else {
                return nil
            }
            
            let archiveAction = UIContextualAction(style: .normal, title: "Archived") { (action, view, completion) in
                archiveSwipe(for: action, item: item)
                completion(true)
            }
            archiveAction.backgroundColor = .systemGreen
            return UISwipeActionsConfiguration(actions: [archiveAction])
        }
        
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0.0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
        ])
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ToDoListItem> { (cell, indexPath, item) in
            
            var content = cell.defaultContentConfiguration()
            content.text = item.itemText
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, ToDoListItem>(collectionView: collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, identifier: ToDoListItem) -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
            // you can coondigure cell appearance here
            return cell
        })
    }
    
    func updateDataSource() {
        snapshot = NSDiffableDataSourceSnapshot<Section, ToDoListItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(notes, toSection: .main)
        
        dataSource.apply(snapshot,animatingDifferences: true)
    }
    
    func loadObjects() {
        notes = realm.objects(ToDoListItem.self).map({ $0 })
    }
    
    func saveObject(_ object: Object) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print("Error while saving object")
        }
    }
    
    @objc private func didTapAddButton() {
        let alert = UIAlertController(title: "Add a new task", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = "Enter your task"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
            let noteTextField = alert.textFields![0] as UITextField
            if let noteText = noteTextField.text {
                if noteText != "" {
                    let note = ToDoListItem()
                    note.itemText = noteText
                    self.saveObject(note)
                    self.notes.append(note)
                    self.updateDataSource()
                }
            }
        })
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - TableView Delegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        
        let actionSheet = UIAlertController(title: selectedItem.itemText, message: "What do you want to do?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { action in
            
            let alert = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
            
            alert.addTextField { (textField:UITextField) in
                textField.text = self.notes[indexPath.row].itemText
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                let noteTextField = alert.textFields![0] as UITextField
                if let noteText = noteTextField.text {
                    if noteText != "" {
                        
                        let item = self.notes[indexPath.row]
                        do {
                            try self.realm.write() {
                                item.itemText = noteText
                            }
                        } catch {
                            print("Error updating item")
                        }
                        self.loadObjects()
                        self.updateDataSource()
                    }
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                collectionView.deselectItem(at: indexPath, animated: true)
            })
            
            alert.addAction(cancelAction)
            alert.addAction(saveAction)
            
            self.present(alert, animated: true, completion: nil)
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            
            let item = self.notes[indexPath.row]
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch  {
                
            }
            self.loadObjects()
            self.updateDataSource()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            collectionView.deselectItem(at: indexPath, animated: true)
        }))
        present(actionSheet, animated: true, completion: nil)
    }
}

extension ViewController {
    func deleteSwipe(for action: UIContextualAction, item: ToDoListItem) {
        do {
            try self.realm.write {
                self.realm.delete(item)
            }
        } catch  {
            
        }
        self.loadObjects()
        self.updateDataSource()
    }
    
    func archiveSwipe(for action: UIContextualAction, item: ToDoListItem) {
        
    }
}

