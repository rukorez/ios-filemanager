//
//  StorageTableViewController.swift
//  MyCustomFileManger
//
//  Created by Филипп Степанов on 08.09.2022.
//

import UIKit

class StorageTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func closeButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let storageType = StorageType(rawValue: indexPath.row) {
            storage = storageType
            tableView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "storageTypeChanged"), object: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if storage.rawValue == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
    }

}
