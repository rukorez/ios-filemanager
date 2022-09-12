//
//  SettingsTableViewController.swift
//  MyCustomFileManger
//
//  Created by Филипп Степанов on 08.09.2022.
//

import UIKit

protocol SettingsTableViewControllerProtocol {
    func sort()
    func unsort()
    func showSizeOfImage()
    func unShowSizeOfImage()
}

class SettingsTableViewController: UITableViewController {
    
    var delegate: SettingsTableViewControllerProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func sortedAction(_ sender: UISwitch) {
        sender.isOn ? delegate?.sort() : delegate?.unsort()
    }
    
    @IBAction func showSizeForImage(_ sender: UISwitch) {
        sender.isOn ? delegate?.showSizeOfImage() : delegate?.unShowSizeOfImage()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            tableView.deselectRow(at: indexPath, animated: true)
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "PasswordViewController") as? PasswordViewController else { return }
            vc.changePassword = true
            present(vc, animated: true)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
