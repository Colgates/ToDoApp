//
//  ViewController.swift
//  ToDoApp
//
//  Created by Evgenii Kolgin on 20.11.2020.
//
import UIKit

class ViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    var viewModel = ViewControllerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        view.backgroundColor = .systemBackground
        title = "ToDoList"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupCollectionView()
        configureDataSource()
        
        viewModel.loadObjects()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    func setupCollectionView() {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .sidebar)
        
        layoutConfig.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let item = self?.viewModel.dataSource?.itemIdentifier(for: indexPath) else { return nil }
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
                self?.viewModel.deleteObject(item)
                completion(true)
            }
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        layoutConfig.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let item = self?.viewModel.dataSource?.itemIdentifier(for: indexPath) else { return nil }
            
            let archiveAction = UIContextualAction(style: .normal, title: "Done") { (action, view, completion) in
                self?.viewModel.toggleObject(item)
                completion(true)
            }
            archiveAction.backgroundColor = .systemGreen
            return UISwipeActionsConfiguration(actions: [archiveAction])
        }
        
        layoutConfig.headerMode = .supplementary
        
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ToDoListItem> { (cell, indexPath, item) in
            
            var configuration = cell.defaultContentConfiguration()
            configuration.text = item.itemText
            
            if item.isDone {
                configuration.image = UIImage(systemName: "checkmark.square")
            } else {
                configuration.image = UIImage(systemName: "square")
            }
            cell.contentConfiguration = configuration
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] (headerView, elementKind, indexPath) in
            
            let headerItem = self.viewModel.dataSource?.snapshot().sectionIdentifiers[indexPath.section]
            
            var configuration = headerView.defaultContentConfiguration()
            configuration.text = headerItem?.description()

            configuration.textProperties.font = .boldSystemFont(ofSize: 16)
            configuration.textProperties.color = .systemBlue
            configuration.directionalLayoutMargins = .init(top: 20.0, leading: 0.0, bottom: 10.0, trailing: 0.0)
            
            headerView.contentConfiguration = configuration
        }
        
        viewModel.dataSource = UICollectionViewDiffableDataSource<Section, ToDoListItem>(collectionView: collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, identifier: ToDoListItem) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        })
        
        viewModel.dataSource?.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    @objc private func didTapAddButton() {
        let alert = UIAlertController(title: "Add a new task", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = "Enter your task"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { _ in
            let noteTextField = alert.textFields![0] as UITextField
            if let noteText = noteTextField.text {
                if noteText != "" {
                    let note = ToDoListItem()
                    note.itemText = noteText
                    print(note.isDone)
                    self.viewModel.saveObject(note)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let selectedItem = viewModel.dataSource?.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }

        let alert = UIAlertController(title: "Edit", message: "", preferredStyle: .alert)

        alert.addTextField { (textField:UITextField) in
            textField.text = selectedItem.itemText
        }

        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { _ in
            let noteTextField = alert.textFields![0] as UITextField
            if let noteText = noteTextField.text {
                if noteText != "" {
                    self.viewModel.updateObject(selectedItem, text: noteText)
                }
            }
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            collectionView.deselectItem(at: indexPath, animated: true)
        })

        alert.addAction(cancelAction)
        alert.addAction(saveAction)

        self.present(alert, animated: true, completion: nil)
    }
}
