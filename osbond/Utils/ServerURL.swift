//
//  ServerURL.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 21/02/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit

class ServerURL: NSObject {

    static let baseURL = "http://osbond.gmedia.bz/"
    
    public static let login = baseURL + "auth"
    public static let register = baseURL + "register"
    public static let getImageSlider = baseURL + "slider/"
    public static let getProfile = baseURL + "profile/view/"
}
