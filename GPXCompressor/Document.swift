//
//  Document.swift
//  GPXCompressor
//
//  Created by Vincent on 5/12/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Cocoa
import CoreGPX

class Document: NSDocument {
    
    var rawGPX: String?
    var url: URL?

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return false
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
        let vc = windowController.contentViewController as! ViewController
        guard let path = fileURL?.path else {return}
        vc.textField.stringValue = path
        guard let url = url else { return }
        vc.parser = GPXParser(withURL: url)
        //vc.parser = GPXParser(withData: data)
    }

    /*override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }*/
    
    override func write(to url: URL, ofType typeName: String) throws {
        guard let rawGPX = rawGPX else {
            throw NSError(domain: NSOSStatusErrorDomain, code: NSFileReadNoSuchFileError, userInfo: nil)
        }
        do {
            try rawGPX.write(to: url, atomically: false, encoding: .utf8)
        }
        
    }
/*
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        self.data = data
        //throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
 */
    override func read(from url: URL, ofType typeName: String) throws {
        self.url = url
    }
    override var isEntireFileLoaded: Bool {
        return false
    }


}

