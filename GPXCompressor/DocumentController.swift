//
//  DocumentController.swift
//  GPXCompressor
//
//  Created by Vincent on 7/12/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Cocoa

class DocumentController: NSDocumentController {

    override class func restoreWindow(withIdentifier identifier: NSUserInterfaceItemIdentifier, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Void) {
        completionHandler(nil, NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil))
    }
}
