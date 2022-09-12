//
//  FileManagerTableViewController.swift
//  MyCustomFileManger
//
//  Created by Филипп Степанов on 05.09.2022.
//

import UIKit

final class FileManagerTableViewController: UITableViewController {
    
    var isLogin: Bool = true
    
    var isShowSizeImage: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isShowSizeImage")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isShowSizeImage")
            UserDefaults.standard.synchronize()
        }
    }
    
    var model = Model()
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private lazy var imageNumber:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaults.standard.set(true, forKey: "isSorted")
        UserDefaults.standard.synchronize()
        showPasswordVC()
        if let tab = tabBarController?.viewControllers?[1] {
            (tab as? SettingsTableViewController)?.delegate = self
        }
    }
    
    @IBAction func createFile(_ sender: Any) {
        let alertVC = UIAlertController(title: "Введите название и содержимое файла", message: nil, preferredStyle: .alert)
        alertVC.addTextField { textField in
            textField.placeholder = "Название файла"
        }
        alertVC.addTextField { textField in
            textField.placeholder = "Содержимое файла"
        }
        let alertAction = UIAlertAction(title: "OK", style: .default) { action in
            guard let name = alertVC.textFields?[0].text, name != "",
                  let content = alertVC.textFields?[1].text, content != "" else { return }
            self.model.createFile(name: name, content: content)
            self.tableView.reloadData()
        }
        alertVC.addAction(alertAction)
        present(alertVC, animated: true)
    }
    
    @IBAction func createFolder(_ sender: Any) {
        let alertVC = UIAlertController(title: "Введите название папки", message: nil, preferredStyle: .alert)
        alertVC.addTextField { textField in
            textField.placeholder = "Название папки"
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            guard let text = alertVC.textFields?[0].text, text != "" else { return }
            self.model.createFolder(text: text)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true)
    }
    
    @IBAction func addImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    private func showPasswordVC() {
        if isLogin {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "PasswordViewController") else { return }
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.files.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let item = model.files[indexPath.row]
        cell.textLabel?.text = item.lastPathComponent
        
        var isFolder: ObjCBool = false
        FileManager.default.fileExists(atPath: item.path, isDirectory: &isFolder)
        if isFolder.boolValue == true {
            cell.detailTextLabel?.text = "Папка"
        } else {
            if isShowSizeImage {
                if item.pathExtension == "jpeg" || item.pathExtension == "png" {
                    let size = try! item.resourceValues(forKeys: [.fileSizeKey])
                    if let size = size.fileSize {
                        cell.detailTextLabel?.text = "\(size) bytes"
                    }
                } else {
                    cell.detailTextLabel?.text = "Файл"
                }
            } else {
                cell.detailTextLabel?.text = "Файл"
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = model.files[indexPath.row]
        
        var isFolder: ObjCBool = false
        FileManager.default.fileExists(atPath: item.path, isDirectory: &isFolder)
        if isFolder.boolValue == true {
            if let tableVC = storyboard?.instantiateViewController(withIdentifier: "FileManagerTableViewController") as? FileManagerTableViewController {
                tableVC.model.url = item
                tableVC.isLogin = false
                navigationController?.pushViewController(tableVC, animated: true)
            }
        } else {
            do {
                let content = try NSString(contentsOfFile: item.path, encoding: String.Encoding.utf8.rawValue)
                let alertVC = UIAlertController(title: item.lastPathComponent, message: content as String, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default)
                alertVC.addAction(alertAction)
                present(alertVC, animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = model.files[indexPath.row]
            do {
                try FileManager.default.removeItem(at: item)
            } catch {
                print(error.localizedDescription)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}

extension FileManagerTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageNumber += 1
        guard let urlAt = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }
        let urlTo = model.url.appendingPathComponent("image" + String(imageNumber) + "." + urlAt.pathExtension)
        do {
            _ = try FileManager.default.replaceItemAt(urlTo, withItemAt: urlAt)
            self.tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true)
    }
}

extension FileManagerTableViewController: SettingsTableViewControllerProtocol {
    
    func sort() {
        UserDefaults.standard.set(true, forKey: "isSorted")
        UserDefaults.standard.synchronize()
        tableView.reloadData()
    }
    
    func unsort() {
        UserDefaults.standard.set(false, forKey: "isSorted")
        UserDefaults.standard.synchronize()
        tableView.reloadData()
    }
    
    func showSizeOfImage() {
        UserDefaults.standard.set(true, forKey: "isShowSizeImage")
        UserDefaults.standard.synchronize()
        tableView.reloadData()
    }
    
    func unShowSizeOfImage() {
        UserDefaults.standard.set(false, forKey: "isShowSizeImage")
        UserDefaults.standard.synchronize()
        tableView.reloadData()
    }
    
    
}
