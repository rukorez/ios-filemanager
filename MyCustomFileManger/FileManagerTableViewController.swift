//
//  FileManagerTableViewController.swift
//  MyCustomFileManger
//
//  Created by Филипп Степанов on 05.09.2022.
//

import UIKit

final class FileManagerTableViewController: UITableViewController {
    
    private lazy var url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    private var files: [URL] {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            return files
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    private lazy var imageNumber:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

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
            let path = self.url.appendingPathComponent(name).path
            do {
                try NSString(string: content).write(toFile: path, atomically: true, encoding: String.Encoding.utf8.rawValue)
            } catch {
                print(error.localizedDescription)
            }
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
            let newUrl = self.url.appendingPathComponent(text)
            do {
                try FileManager.default.createDirectory(at: newUrl, withIntermediateDirectories: false)
            } catch {
                print(error.localizedDescription)
            }
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
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let item = files[indexPath.row]
        cell.textLabel?.text = item.lastPathComponent
        
        var isFolder: ObjCBool = false
        FileManager.default.fileExists(atPath: item.path, isDirectory: &isFolder)
        if isFolder.boolValue == true {
            cell.detailTextLabel?.text = "Папка"
        } else {
            cell.detailTextLabel?.text = "Файл"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = files[indexPath.row]
        
        var isFolder: ObjCBool = false
        FileManager.default.fileExists(atPath: item.path, isDirectory: &isFolder)
        if isFolder.boolValue == true {
            if let tableVC = storyboard?.instantiateViewController(withIdentifier: "FileManagerTableViewController") as? FileManagerTableViewController {
                tableVC.url = item
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
            let item = files[indexPath.row]
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
        let urlTo = url.appendingPathComponent("image" + String(imageNumber) + "." + urlAt.pathExtension)
        do {
            _ = try FileManager.default.replaceItemAt(urlTo, withItemAt: urlAt)
            self.tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true)
    }
}
