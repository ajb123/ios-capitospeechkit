//
//  ViewController.swift
//  SampleApp
//
//  Created by James Gartland on 24/03/2017.
//  Copyright © 2017 James Gartland. All rights reserved.
//

import UIKit
import CapitoSpeechKit
import TWMessageBarManager
import MBProgressHUD

class CAPViewController: UIViewController {

    lazy var readyImage: UIImage = {
        return UIImage(named: "rec2")!
    }()
    lazy var busyImage: UIImage = {
        return UIImage(named: "rec1")!
    }()

    
    var isRecording: Bool = false
    var controller: CapitoController?
    
    @IBOutlet weak var microphone: UIButton!
    @IBOutlet weak var transcriptionView: UITextView!
    @IBOutlet weak var info: UIButton!
    @IBOutlet weak var textControlBar: UISearchBar!
    @IBOutlet weak var textControl: UIButton!
    @IBOutlet weak var infoText: UITextView!
    @IBOutlet weak var transcriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialise and hide text control bar
        self.initialiseTextControlBar()

        // Set info text
        let versionInfo = self.appVersionNumberDisplayString()
        let versionStr = self.infoText.text.appending(versionInfo)
        
        self.infoText.text = versionStr
        
        self.view.sendSubview(toBack: self.transcriptionLabel)
        self.view.sendSubview(toBack: self.transcriptionView)
    }

    @IBAction func onMicrophoneClick(_ sender: UIButton?) {
        if self.isRecording {
            CapitoController.getInstance().cancelTalking()
        } else {
            CapitoController.getInstance().push(toTalk: self, withDialogueContext: nil)
            self.transcriptionLabel.text = ""
        }
    }
    
    @IBAction func onTextControlClick(_ sender: UIButton?) {
        var adelta: CGFloat = 1.0
        
        // check if toolbar was visible or hidden before the animation
        let isHidden = self.textControlBar.isHidden
        
        // if search bar was visible set delta to negative value
        if !isHidden {
            adelta = 0.0
        } else {
            // if search bar was hidden then make it visible
            self.textControlBar.isHidden = false
        }
        
        UIView.animate(withDuration: 0.7, delay: 0.2, options: .allowAnimatedContent, animations: {
            self.textControlBar.alpha = adelta
        }) { (finished) in
            if !isHidden {
                self.textControlBar.isHidden = true
                self.textControlBar.resignFirstResponder()
            }
        }
    }
    
    @IBAction func onInfoClick(_ sender: UIButton?) {
        self.infoText.isHidden = !self.infoText.isHidden
    }

    func initialiseTextControlBar() {
        self.textControlBar.isHidden = true
        self.textControlBar.delegate = self
        self.textControlBar.alpha = 0.0
    }

    func appVersionNumberDisplayString() -> String {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let majorVersion = infoDictionary["CFBundleShortVersionString"],
              let minorVersion = infoDictionary["CFBundleVersion"] else {
            return ""
        }

        return "\(majorVersion).\(minorVersion)"
    }
}

// Handling Responses
extension CAPViewController {
    func bootstrapView(response: CapitoResponse) {
        // process response
        print("Response Code: %@", response.responseCode)
        print("Message Text: %@", response.message)
        print("Context: %@", response.context)
        print("Data: %@", response.data)
        // This is where the app-specific code should be placed to handle the response from the Capito Cloud
    }

    func handle(text: String) {
        self.showProcessingHUD(text: "Processing...")

        CapitoController.getInstance().text(self, input: text, withDialogueContext: nil)
    }
    
    func handle(response: CapitoResponse) {
        if response.messageType == "WARNING" {
            self.showErrorMessage(text: response.message)
        } else {
            self.bootstrapView(response: response)
        }
    }
}

// Errors and ProcessHUD
extension CAPViewController {
    
    func showProcessingHUD(text: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.minShowTime = 1.0
        hud.label.text = "Processing..."
        hud.detailsLabel.text = text
    }
    func hideProcessingHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }

    func showError(_ error: Error) {
        TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: error.localizedDescription, type: .error, duration: 6.0)
    }
    func showErrorMessage(text: String) {
        TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: text, type: .error, duration: 6.0)
    }
}

extension CAPViewController: SpeechDelegate {
    func speechControllerDidBeginRecording() {
        self.isRecording = true
        self.microphone.setImage(busyImage, for: .normal)
    }
    
    func speechControllerDidFinishRecording() {
        self.isRecording = true
        self.microphone.setImage(readyImage, for: .normal)
    }
    
    func speechControllerProcessing(_ transcription: CapitoTranscription!, suggestion: String!) {
        self.showProcessingHUD(text: "Processing...")
        self.transcriptionLabel.text = String(format: "\"%@\"", transcription.firstResult().replacingOccurrences(of: " | ", with: " "))
    }
    
    func speechControllerDidFinish(withResults response: CapitoResponse!) {
        self.hideProcessingHUD()
        self.handle(response: response)
    }
    
    func speechControllerDidFinishWithError(_ error: Error!) {
        self.hideProcessingHUD()
        self.showError(error)
    }
}

extension CAPViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.textControlBar.resignFirstResponder()

        // Do the search...
        if let text = searchBar.text {
            print("Sending text event: \(text)")

            self.onTextControlClick(nil)
            self.handle(text: text)
        }
    }
}

extension CAPViewController: TextDelegate {
    func textControllerDidFinish(withResults response: CapitoResponse!) {
        self.hideProcessingHUD()
        self.handle(response: response)
    }

    func textControllerDidFinishWithError(_ error: Error!) {
        self.hideProcessingHUD()
        self.showError(error)
    }
}
