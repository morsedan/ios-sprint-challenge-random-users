//
//  UsersTableViewController.swift
//  Random Users
//
//  Created by morse on 12/6/19.
//  Copyright © 2019 Erica Sadun. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    struct PropertyKeys {
        
        static let cell = "UserCell"
        
        static let detailSegue = "ShowUserDetailSegue"
    }
    let userController = UserController()
    private let photoFetchQueue = OperationQueue()
    private var fetchOperations: [String: FetchPhotoOperation] = [:]
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userController.fetchUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userController.users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.cell, for: indexPath)

        cell.textLabel?.text = userController.users[indexPath.row].name
        fetchImage(for: cell, indexPath: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        fetchOperations[userController.users[indexPath.row].name]?.cancel()
    }
    
    // MARK: - Private Methods
    
    private func fetchImage(for cell: UITableViewCell, indexPath: IndexPath) {
        
        let photoString = userController.users[indexPath.row].thumbnail
        
//        if let imageData = cache.retrieveValue(for: userController.users[indexPath.row].name),
//            let image = UIImage(data: imageData) {
//            cell.imageView.image = image
//            return
//        }
        
        let photoFetchOperation = FetchPhotoOperation(photoString: photoString)
        
//        let storeData = BlockOperation {
//            if let imageData = photoFetchOperation.imageData {
//                self.cache.cache(value: imageData, for: userController.users[indexPath.row].name)
//            }
//        }
        
        let setImage = BlockOperation {
            defer { self.fetchOperations.removeValue(forKey: self.userController.users[indexPath.row].name) } // So we use less memory
            if self.tableView.indexPath(for: cell) != indexPath {
                return
            } else {
                guard let data = photoFetchOperation.imageData else { return }
                let image = UIImage(data: data)
                cell.imageView?.image = image
//                self.tableView.reloadData()
            }
        }
        
        setImage.addDependency(photoFetchOperation)
//        storeData.addDependency(photoFetchOperation)
        
        photoFetchQueue.addOperations([photoFetchOperation/*, storeData*/], waitUntilFinished: false)
        OperationQueue.main.addOperation(setImage)
        
        fetchOperations[userController.users[indexPath.row].name] = photoFetchOperation
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailVC = segue.destination as? UserDetailViewController,
            let indexPath = tableView.indexPathForSelectedRow else { return }
        detailVC.user = userController.users[indexPath.row]
        detailVC.photoFetchQueue = photoFetchQueue
    }
    

}
