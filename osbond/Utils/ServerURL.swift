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
    public static let saveProfile = baseURL + "profile/edit/"
    public static let getFreeCupon = baseURL + "main/kupon_gratis/"
    public static let getOTP = baseURL + "main/kirim_otp/"
    public static let checkOTP = baseURL + "main/check_otp/"
    public static let getToken = baseURL + "Kupon/"
    public static let getBarcode = baseURL + "Barcode/"
    public static let shareToken = baseURL + "kupon/kirim/"
    public static let getPaket = baseURL + "master/ms_paket/"
    public static let getCabang = baseURL + "master/ms_cabang/"
    public static let getCheckoutData = baseURL + "beli/create_barang/"
}
