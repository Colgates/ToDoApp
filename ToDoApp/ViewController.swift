//
//  ViewController.swift
//  ToDoApp
//
//  Created by Evgenii Kolgin on 20.11.2020.
//



import UIKit

class ViewController: UIViewController {
    
    var notes = [Notes]()
    
    private let collectionView: UICollectionView = {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Notes>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        title = "ToDoList"
        
        collectionView.delegate = self
        
        setupCollectionView()
        setupSubviews()
        updateDataSource()
    }
    
    func setupCollectionView() {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Notes> { (cell, indexPath, note) in
            var content = cell.defaultContentConfiguration()
            content.text = note.title
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Notes>(collectionView: collectionView) { (collectionView, indexPath, note) -> UICollectionViewCell? in
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
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Notes>()
        snapshot.appendSections([.main])
        snapshot.appendItems(notes)
        
        dataSource.apply(snapshot,animatingDifferences: true)
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
                    let note = Notes(title: noteText)
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
    }
    
}
