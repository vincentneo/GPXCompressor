//
//  ViewController.swift
//  GPXCompressor
//
//  Created by Vincent on 5/12/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Cocoa
import CoreGPX

class ViewController: NSViewController {

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var radiusField: NSTextField!
    @IBOutlet weak var percentageField: NSTextField!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    //@IBOutlet weak var statusLabel: NSTextField!
    //@IBOutlet weak var spinningIndicator: NSProgressIndicator!
    
    let delegate = NSApplication.shared.delegate
    let docController = DocumentController.shared
    
    @IBAction func openButtonAction(_ sender: Any) {
        let popup = NSOpenPanel()

        popup.message = "Please select a GPX file."
        //popup.showsResizeIndicator = true
        popup.allowsMultipleSelection = false
        popup.worksWhenModal = true
        popup.resolvesAliases = true
        popup.allowedFileTypes = ["gpx", "GPX"]
        
        popup.beginSheetModal(for: view.window!) { response in
            if response == NSApplication.ModalResponse.OK {
                guard let url = popup.url else { return }
                self.textField.stringValue = url.path
                //self.parser = GPXParser(withURL: url)
                //self.view.window?.title = url.lastPathComponent
                
                do {
                    let doc = self.docController.currentDocument
                    let newDoc = try Document(contentsOf: url, ofType: "DocumentType")
                    
                    NSDocumentController.shared.addDocument(newDoc)
                    newDoc.addWindowController(self.view.window!.windowController!)
                    doc?.close()
                    self.parser = GPXParser(withURL: url)
                }
                catch {
                    print("ViewController, openButtonAction:: \(error)")
                }
            }
        }
        
        
    }
    
    /// Switches button and process indicators, depending on current state
    func switchStatus(_ sender: NSButton) {
        if self.loadingIndicator.isHidden {
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimation(nil)
            sender.title = "Processing"
            sender.isEnabled = false
        }
        else {
            self.loadingIndicator.isHidden = true
            self.loadingIndicator.stopAnimation(nil)
            sender.title = "Process"
            sender.isEnabled = true
        }
        
    }

    @IBAction func processButtonClicked(_ sender: NSButton) {
        DispatchQueue.global(qos: .userInitiated).async {
            var compressType: GPXCompression.lossyTypes = .stripDuplicates
            
            var options = [GPXCompression.lossyOptions]()
            var exit = false
            
            DispatchQueue.main.sync {
                self.switchStatus(sender)
                
                self.checkBox[0] ? options.append(.waypoint) : nil
                self.checkBox[1] ? options.append(.trackpoint) : nil
                self.checkBox[2] ? options.append(.routepoint) : nil
                
                if self.parser == nil {
                    self.errorOccurred(type: .noFileSelected)
                    self.switchStatus(sender)
                    exit = true
                    return
                }
                
                if options.isEmpty {
                    self.errorOccurred(type: .noTypeSelected)
                    self.switchStatus(sender)
                    exit = true
                    return
                }
                
                if self.radioSelection == 1 {
                    guard let radius = Double(self.radiusField.stringValue) else {
                        self.errorOccurred(type: .radius)
                        self.switchStatus(sender)
                        exit = true
                               return
                           }
                    compressType = .stripNearbyData(distanceRadius: radius)
                }
                if self.radioSelection == 2 {
                    guard let percent = Double(self.percentageField.stringValue) else {
                        self.errorOccurred(type: .percentNotNumber)
                        self.switchStatus(sender)
                        exit = true
                               return
                           }
                    if percent <= 0 || percent >= 100 {
                        self.errorOccurred(type: .percentOutOfRange)
                        self.switchStatus(sender)
                        exit = true
                        return
                    }
                    compressType = .randomRemoval(percentage: percent / 100)
                }

            }
            if exit { return }

            guard let newGPX = self.parser?.lossyParsing(type: compressType, affecting: options) else {
                return
            }

            print(newGPX.gpx())
            
            let currentDoc = self.docController.currentDocument as! Document
            
            currentDoc.rawGPX = newGPX.gpx()
            
            DispatchQueue.main.sync {
                let popup = NSSavePanel()
                popup.message = "Choose a directory to save"
                popup.nameFieldStringValue = currentDoc.displayName
                popup.directoryURL = currentDoc.fileURL?.deletingLastPathComponent()
                popup.allowedFileTypes = ["gpx"]
                popup.allowsOtherFileTypes = true

                popup.beginSheetModal(for: self.view.window!) {
                    response in
                    if response == .OK {
                        guard let url = popup.url else { return }
                        do {
                            try currentDoc.write(to: url, ofType: "DocumentType")
                        }
                        catch {
                            print(error)
                        }
                        
                    }
                }
                
                self.switchStatus(sender)
            }
            
        }
    }
    
    var radioSelection = 0
    
    @IBAction func radioButtonClicked(_ sender: NSButton) {
        radioSelection = sender.tag
        
        if radioSelection == 0 {
            radiusField.isEnabled = false
            percentageField.isEnabled = false
        }
        else if radioSelection == 1 {
            radiusField.isEnabled = true
            percentageField.isEnabled = false
        }
        else if radioSelection == 2 {
            radiusField.isEnabled = false
            percentageField.isEnabled = true
        }
    }
    
    var checkBox: [Bool] = [false, true, false]
    
    @IBAction func checkBoxClicked(_ sender: NSButton) {
        checkBox[sender.tag] = sender.state == .on ? true : false
    }
    
    var parser: GPXParser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.isHidden = true
        
        if radioSelection == 0 {
            radiusField.isEnabled = false
            percentageField.isEnabled = false
        }
        

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

// User-related errors responder
extension ViewController {
    enum fieldType {
        case radius
        case percentNotNumber
        case percentOutOfRange
        case noFileSelected
        case noTypeSelected
    }
    
    func errorOccurred(type: fieldType) {
        let alert = NSAlert()
        switch type {
            
        case .radius: alert.messageText = "Invalid Radius"
        case .percentNotNumber: alert.messageText = "Invalid Percentage, contains text"
        case .percentOutOfRange: alert.messageText = "Percentage out of range (1-99)"
        case .noFileSelected: alert.messageText = "No files selected"
        alert.icon = NSImage(named: NSImage.cautionName)
            
        case .noTypeSelected:
            alert.messageText = "Please select remove types"
            alert.informativeText = "Select either track points, route points or waypoints to be removed for compressing."
        }
        
        alert.runModal()
    }
}
