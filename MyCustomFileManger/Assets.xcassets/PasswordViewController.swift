//
//  PasswordViewController.swift
//  MyCustomFileManger
//
//  Created by Филипп Степанов on 07.09.2022.
//

import UIKit

class PasswordViewController: UIViewController {
    
    var changePassword: Bool = false
    var numberOfEnterPassword: Int = 0
    
    var password: String = ""
    
    var keychainService = KeychainService()
    
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField?.delegate = self
        setButton()
    }
    
    @IBAction func buttunAction(_ sender: Any) {
        if changePassword {
            updatePassword()
        } else {
            if let bool = setButton() {
                if bool {
                    checkPassword()
                } else {
                    addPassword()
                }
            }
        }
    }
    
    private func setButton() -> Bool? {
        if changePassword {
            signButton?.setTitle("Введите пароль", for: .normal)
            label.text = "Введите новый пароль"
            return nil
        } else {
            if let _ = self.keychainService.getPassword(login: "Fil", serviceName: "FileManager") {
                signButton?.setTitle("Введите пароль", for: .normal)
                return true
            } else {
                signButton?.setTitle("Создать пароль", for: .normal)
                return false
            }
        }
    }
    
    private func addPassword() {
        guard let password = textField.text else { return }
        guard password.count >= 4 else {
            label.text = "Пароль должен содержать не менее 4 символов"
            return
        }
        if numberOfEnterPassword == 0 {
            textField.text = ""
            self.password = password
            label.text = "Введите пароль еще раз"
            numberOfEnterPassword += 1
        } else if numberOfEnterPassword == 1 {
            if password == self.password {
                label.text = "Пароль успешно сохранен"
                numberOfEnterPassword = 0
                self.keychainService.addPassword(login: "Fil", password: password, serviceName: "FileManager")
                dismiss(animated: true)
            } else {
                label.text = "Пароли не совпадают"
                numberOfEnterPassword = 0
            }
        }
    }
    
    private func checkPassword() {
        if let result = self.keychainService.getPassword(login: "Fil", serviceName: "FileManager") {
            if textField.text == result {
                dismiss(animated: true)
            } else {
                label.text = "Неверный пароль"
            }
        }
    }
    
    private func updatePassword() {
        guard let password = textField.text else { return }
        guard password.count >= 4 else {
            label.text = "Пароль должен содержать не менее 4 символов"
            return
        }
        label.text = "Пароль успешно сохранен"
        self.keychainService.updatePassword(login: "Fil", newPassword: password, serviceName: "FileManager")
        dismiss(animated: true)
    }
    
}

extension PasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        buttunAction(signButton ?? UIButton())
        return true
    }
    
}
