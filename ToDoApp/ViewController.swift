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
    
    private let collectionView: UICollectionView = {
        
        var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        
        configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
            let del = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in





                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [del])
        }
        
        
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, ToDoListItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        title = "ToDoList"
        navigationController?.navigationBar.prefersLargeTitles = true
        collectionView.delegate = self
        
        setupCollectionView()
        setupSubviews()
        
        loadObjects()
        updateDataSource()
    }
    
    func setupCollectionView() {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, ToDoListItem> { (cell, indexPath, note) in
            var content = cell.defaultContentConfiguration()
            content.text = note.itemText
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, ToDoListItem>(collectionView: collectionView) { (collectionView, indexPath, note) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: note)
        }
    }
    
    
    func setupSubviews() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                                     collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)])
    }
    
    func updateDataSource() {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, ToDoListItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(notes)
        
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
            textField.placeholder = "Enter your note"
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
        collectionView.deselectItem(at: indexPath, animated: true)
        
        
        let actionSheet = UIAlertController(title: "Actions", message: "What do you want to do?", preferredStyle: .actionSheet)
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
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(saveAction)
            
            self.present(alert, animated: true, completion: nil)
        }))
        present(actionSheet, animated: true, completion: nil)
    }
}

