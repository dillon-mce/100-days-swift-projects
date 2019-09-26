//
//  ViewController.swift
//  Project25
//
//  Created by Dillon McElhinney on 9/21/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var images: [UIImage] = []
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Selfie Share"
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera,
                                           target: self,
                                           action: #selector(importPicture))

        let messageButton = UIBarButtonItem(barButtonSystemItem: .compose,
                                            target: self,
                                            action: #selector(composeMessage))
        navigationItem.rightBarButtonItems = [cameraButton, messageButton]



        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(showConnectionPrompt))
        let infoButton = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(showInfo))
        navigationItem.leftBarButtonItems = [addButton, infoButton]

        mcSession = MCSession(peer: peerID,
                              securityIdentity: nil,
                              encryptionPreference: .required)

        mcSession?.delegate = self
    }

    // MARK: - Collection View Methods

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell",
                                                      for: indexPath)

        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }

        return cell
    }

    // MARK: - Image Picker Controller Methods

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)

        images.insert(image, at: 0)
        collectionView.reloadData()

        sendImage(image)
    }

    // MARK: - Actions

    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others",
                                   message: nil,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session",
                                   style: .default,
                                   handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session",
                                   style: .default,
                                   handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel",
                                   style: .cancel))
        present(ac, animated: true)
    }

    @objc func composeMessage() {
        let ac = UIAlertController(title: "Send a message",
                                   message: "Say whatever you want. Try to keep it nice though.",
                                   preferredStyle: .alert)
        var textField: UITextField!
        ac.addTextField { textfield in
            textField = textfield
            textField.placeholder = "Your message"
        }
        let send = UIAlertAction(title: "Send",
                                 style: .default) { _ in
                                    self.sendMessage(textField.text)
        }
        ac.addAction(send)
        let cancel = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        ac.addAction(cancel)
        present(ac, animated: true)
    }

    @objc func showInfo() {
        guard let mcSession = mcSession else { return }
        let title = "Session Info"
        var message = "Connected Users:\n"
        message += mcSession.connectedPeers.map { $0.displayName }.joined(separator: "\n")
        presentAlert(title: title, message: message)
    }

    private func sendMessage(_ message: String?) {
        guard let mcSession = mcSession else { return }
        guard mcSession.connectedPeers.count > 0 else { return }
        guard let message = message else { return }
        guard let messageData = message.data(using: .utf8) else { return }
        do {
            try mcSession.send(messageData,
                                toPeers: mcSession.connectedPeers,
                                with: .reliable)
        } catch {
            let title = "Error Sending Message"
            let message = error.localizedDescription
            presentAlert(title: title, message: message)
        }
    }

    private func startHosting(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25",
                                                      discoveryInfo: nil,
                                                      session: mcSession)
        mcAdvertiserAssistant?.start()
    }

    private func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25",
                                                session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }

    private func sendImage(_ image: UIImage) {
        guard let mcSession = mcSession else { return }
        guard mcSession.connectedPeers.count > 0 else { return }
        guard let imageData = image.pngData() else { return }

        do {
            try mcSession.send(imageData,
                               toPeers: mcSession.connectedPeers,
                               with: .reliable)
        } catch {
            let title = "Error Sending Image"
            let message = error.localizedDescription
            presentAlert(title: title, message: message)
        }
    }

    private func presentAlert(title: String? = nil,
                              message: String? = nil) {
        let ac = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK",
                                   style: .default))
        DispatchQueue.main.async {
            self.present(ac, animated: true)
        }
    }
}

// MARK: - Multipeer Connectivity Methods

extension ViewController: MCSessionDelegate, MCBrowserViewControllerDelegate {
    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {

        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")

        case .connecting:
            print("Connecting: \(peerID.displayName)")

        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
            let title = "\(peerID.displayName) Disconnected"
            presentAlert(title: title)

        @unknown default:
            print("Unknown state received: \(peerID.displayName)")
        }
    }

    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {

        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            } else if let message = String(data: data, encoding: .utf8) {
                let title = "\(peerID.displayName) Says:"
                self?.presentAlert(title: title, message: message)
            }
        }
    }

    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {

    }

    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {

    }

    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }

    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}
