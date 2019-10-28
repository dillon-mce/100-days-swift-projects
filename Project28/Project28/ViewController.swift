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
            let title = "Biometry unavailable"
            let message = "Your device is not configured for biometric authentication."
            self.presentErrorAlert(title: title,
                                   message: message)
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
    }

    @objc private func saveSecretMessage() {
        guard !secret.isHidden else { return }

        KeychainWrapper.standard.set(secret.text, forKey: Key.secretMessage)
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"

    }

}

enum Key {
    static secretMessage = "SecretMessage"
}

extension UIAlertAction {
    static let ok = UIAlertAction(title: "OK",
                                  style: .default)
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
