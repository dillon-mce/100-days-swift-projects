//
//  ViewController.swift
//  Project28
//
//  Created by Dillon McElhinney on 10/27/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet var secret: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Nothing to see here"


        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(saveSecretMessage),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
    }

    @IBAction func authenticate(_ sender: Any) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                     error: &error) {
            let reason = "Use your fingerprint to unlock your secret messages."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        let title = "Authentication failed"
                        let message = "You could not be verified; please try again."
                        self?.presentErrorAlert(title: title,
                                                message: message)
                    }
                }
            }
        } else {
            unlockWithPassword()
        }
    }

    @objc private func adjustForKeyboard(notification: Notification) {
        let key = UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardValue = notification.userInfo?[key] as? NSValue else {
                    return
        }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame,
                                                from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            let bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
            secret.contentInset = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: bottom,
                                                   right: 0)
        }

        secret.scrollIndicatorInsets = secret.contentInset

        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }

    private func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"

        secret.text = KeychainWrapper.standard.string(forKey: Key.secretMessage)

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .done,
                            target: self,
                            action: #selector(saveSecretMessage))

        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Set Password",
                            style: .plain,
                            target: self,
                            action: #selector(setPassword))
    }

    @objc private func saveSecretMessage() {
        guard !secret.isHidden else { return }

        KeychainWrapper.standard.set(secret.text, forKey: Key.secretMessage)
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"

        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
    }

    @objc private func setPassword() {
        let alertController = UIAlertController(title: "Choose a password",
                                                message: nil,
                                                preferredStyle: .alert)
        var passwordField: UITextField!
        alertController.addTextField { textfield in
            textfield.placeholder = "Your new password"
            textfield.isSecureTextEntry = true

            passwordField = textfield
        }

        let set = UIAlertAction(title: "Set Password",
                                style: .default) { _ in
            guard let password = passwordField.text else { return }
            KeychainWrapper.standard.set(password,
                                         forKey: Key.password)
        }

        alertController.addAction(set)
        alertController.addAction(.cancel)

        present(alertController, animated: true)
    }

    @objc private func unlockWithPassword() {
        let alertController = UIAlertController(title: "What's the password?",
                                                message: nil,
                                                preferredStyle: .alert)
        var passwordField: UITextField!
        alertController.addTextField { textfield in
            textfield.placeholder = "Your password"
            textfield.isSecureTextEntry = true

            passwordField = textfield
        }

        let unlock = UIAlertAction(title: "Unlock",
                                style: .default) { _ in
            if passwordField.text ==  KeychainWrapper.standard.string(forKey: Key.password) ?? "" {
                self.unlockSecretMessage()
            }
        }

        alertController.addAction(unlock)
        alertController.addAction(.cancel)

        present(alertController, animated: true)
    }

}

enum Key {
    static let secretMessage = "SecretMessage"
    static let password = "SecretPassword"
}

extension UIAlertAction {
    static let ok = UIAlertAction(title: "OK",
                                  style: .default)
    static let cancel = UIAlertAction(title: "Cancel",
                                      style: .cancel)
}

extension ViewController {
    func presentErrorAlert(title: String, message: String?) {
        let ac = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
        ac.addAction(.ok)
        self.present(ac, animated: true)
    }
}
