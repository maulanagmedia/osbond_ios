//
//  BuyTokenController.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 25/03/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class BuyTokenController: UIViewController, SBCardPopupContent, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard: Bool = true
    var allowsSwipeToDismissPopupCard: Bool = true
    
    static func create() -> UIViewController{
      
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "buyTokenController") as! BuyTokenController
        return storyboard
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let newHight = collectionView.bounds.size.height
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(newHight))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return listPaket.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PaketTokenViewCell
        
        let customItem = listPaket[indexPath.row]
        
   
        DispatchQueue.main.async {
            cell.ivPaket.imageFromServerURL((customItem.item2).replacingOccurrences(of: " ", with: "%20"), placeHolder: UIImage(named: "ic_kupon_gratis"))

        }
        
        cell.lNamaPaket.text = customItem.item3
        cell.lKeterangan.text = customItem.item4
        cell.lHarga.text = "Harga Rp " + ItemValidation().ChangeToCurrencyFormat(customItem.item5)
        
        cell.rbPaket.isSelected = customItem.item6 == "0" ? false : true
        
        cell.rbPaket.addTarget(self, action: #selector(onRbPaketClicked(sender:)), for: .touchUpInside)
        cell.rbPaket.accessibilityIdentifier = customItem.item1
        
        return cell
    }
    
    @objc func onRbPaketClicked(sender: UIButton) {
        
        let id = sender.accessibilityIdentifier!
        for item in self.listPaket {
            
            if id == item.item1 {
                
                self.selectedPaket = id
                self.currentFlag = item.item7
                item.item6 = "1"
                
                DispatchQueue.main.async {
                    
                    if item.item7 == "1"{
                        
                        self.vCabang.isHidden = true
                    }else{
                        self.vCabang.isHidden = false
                    }
                }
                
            }else{
                
                item.item6 = "0"
            }
        }
        
        DispatchQueue.main.async {
            
            self.colPaket.reloadData()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listCabang.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let item = listCabang[row]
        return item.item2
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let item = listCabang[row]
        self.tempIdCabang = item.item1
        self.tempNamaCabang = item.item2
        print(item.item2)
    }
    
    @IBOutlet weak var colPaket: UICollectionView!
    @IBOutlet weak var pacPaket: UIPageControl!
    @IBOutlet weak var vCabang: UIView!
    @IBOutlet weak var tJumlah: UITextField!
    @IBOutlet weak var lCabang: UILabel!
    
    let session = SessionManager.getObject()
    let TAG = "HOMEVIEW "
    var listPaket = [CustomItem]()
    var listCabang = [CustomItem]()
    var selectedPaket = ""
    var selectedCabang = ""
    var tempIdCabang = ""
    var tempNamaCabang = ""
    var currentFlag = ""
    var pbLoading: progressLoading = progressLoading()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pacPaket.numberOfPages = listPaket.count
        if listPaket.count > 0
        {
            pacPaket.currentPage = 0
        }

        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(sender:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(sender:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.getPaket()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        
        DispatchQueue.main.async {
            self.view.frame.origin.y = -150 // Move view 150 points upward
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        
        DispatchQueue.main.async {
            self.view.frame.origin.y = 0 // Move view to original position
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func getPaket(){
        
        self.showLoading()
        let url = URL(string: ServerURL.getPaket)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        request.httpMethod = "GET"
        
        let proses = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            self.hideLoading()
            if data != nil{
             
                if let jsonValue = String(data: data!, encoding: .ascii){
                    if let jsonData = jsonValue.data(using: .utf8) {
                        
                        do {
                            
                            self.listPaket.removeAll()
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                            
                            let metadata = json.value(forKey: "metadata") as? NSDictionary
                            let responseApi = json.value(forKey: "response") as? NSArray
                            
                            let status = metadata?.value(forKey: "status") as? Int64
                            let message = metadata?.value(forKey: "message") as? String
                            
                            if status == 200 {
                                
                                for jo in responseApi! {
                                    
                                    let dataRow = jo as? [String: String]
                                    self.listPaket.append(CustomItem(item1: (dataRow?["id"])!
                                        ,item2: (dataRow?["image"])!
                                        ,item3: (dataRow?["label"])!
                                        ,item4: (dataRow?["keterangan"])!
                                        ,item5: (dataRow?["harga"])!
                                        ,item6: "0"
                                        ,item7: (dataRow?["flag"])!
                                    ))
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    self.colPaket.reloadData()
                                    self.pacPaket.numberOfPages = self.listPaket.count
                                    
                                }
                                
                            }else if status == 401 {
                                
                                self.redirectToLogin()
                            }else{
                                CustomToast.show(message: message ?? "", controller: self)
                            }
                            
                        }catch let parsingError{
                            
                            print("Error", parsingError)
                            CustomToast.show(message: parsingError.localizedDescription, controller: self)
                        }
                    }
                }
                
                self.getCabang()
            }else{
                
                CustomToast.show(message: "Please check your internet connection", controller: self)
            }
        }
        
        proses.resume()
    }
    
    func getCabang(){
        
        self.showLoading()
        let url = URL(string: ServerURL.getCabang)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        request.httpMethod = "GET"
        
        let proses = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            self.hideLoading()
            if data != nil {
                
                if let jsonValue = String(data: data!, encoding: .ascii){
                    if let jsonData = jsonValue.data(using: .utf8) {
                        
                        do {
                            
                            self.listCabang.removeAll()
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                            
                            let metadata = json.value(forKey: "metadata") as? NSDictionary
                            let responseApi = json.value(forKey: "response") as? NSArray
                            
                            let status = metadata?.value(forKey: "status") as? Int64
                            let message = metadata?.value(forKey: "message") as? String
                            
                            if status == 200 {
                                
                                for jo in responseApi! {
                                    
                                    let dataRow = jo as? [String: String]
                                    self.listCabang.append(CustomItem(item1: (dataRow?["id"])!
                                        ,item2: (dataRow?["cabang"])!
                                    ))
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    if self.listCabang.count > 0 {
                                        
                                        self.selectedCabang = self.listCabang[0].item1
                                        self.lCabang.text = self.listCabang[0].item2
                                    }
                                }
                                
                            }else if status == 401 {
                                
                                self.redirectToLogin()
                            }else{
                                CustomToast.show(message: message ?? "", controller: self)
                            }
                            
                        }catch let parsingError{
                            
                            print("Error", parsingError)
                            CustomToast.show(message: parsingError.localizedDescription, controller: self)
                        }
                    }
                }
            }else{
                
                CustomToast.show(message: "Please check your internet connection", controller: self)
            }
        }
        
        proses.resume()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let horizontalCenter = width / 2
        
        pacPaket.currentPage = Int(offSet + horizontalCenter) / Int(width)
    }

    @IBAction func setOnCloseClicked(_ sender: Any) {
        
        self.popupViewController?.close()
    }
    
    @IBAction func onBeliClicked(_ sender: Any) {
        
        if selectedPaket == "" {
            
            CustomToast.show(message: "Harap pilih paket", controller: self)
            return
        }
        
        if self.tJumlah.text == "" || self.tJumlah.text == "0"{
            
            CustomToast.show(message: "Jumlah harap diisi", controller: self)
            return
        }
        
        let alert = UIAlertController(title: "Konfirmasi", message: "Anda yakin ingin memproses transaksi?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            self.getCheckoutDetail()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Batal", style: .default, handler: { action in
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func getCheckoutDetail(){
        
        self.showLoading()
        let url = URL(string: ServerURL.getCheckoutData)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        
        let data : [String: Any] =
            ["id_paket": self.selectedPaket
                , "id_cabang": (self.currentFlag == "1" ? "0" : self.selectedCabang)
        ]
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            let jsonStr = String(data:jsonData, encoding: .ascii)
            
            request.httpBody = jsonStr?.data(using: .utf8)
            
            request.httpMethod = "POST"
            
        }catch{
            
        }
        
        let proses = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            self.hideLoading()
            
            if data != nil {
                
                if let jsonValue = String(data: data!, encoding: .ascii){
                    if let jsonData = jsonValue.data(using: .utf8) {
                        
                        do {
                            
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                            
                            let metadata = json.value(forKey: "metadata") as? NSDictionary
                            let responseApi = json.value(forKey: "response") as? [String : Any?]
                            
                            let status = metadata?.value(forKey: "status") as? Int64
                            let message = metadata?.value(forKey: "message") as? String
                            
                            DispatchQueue.main.async {
                                
                                CustomToast.show(message: message ?? "", controller: self)
                            }
                            
                            if status == 200 {
                                
                                for item in self.listPaket {
                                    
                                    if self.selectedPaket == item.item1 {
                                        
                                        CheckoutTokenController.selectedPaket = item
                                    }
                                }
                                
                                CheckoutTokenController.idTransaksiMidtrans = String(responseApi?["id"] as! Int64)
                                CheckoutTokenController.namaBarangMidtrans = responseApi?["name"] as! String
                                CheckoutTokenController.hargaMidtrans = responseApi?["price"] as! String
                                
                                
                                DispatchQueue.main.async {
                                    
                                    //self.popupViewController?.close()
                                    
                                    CheckoutTokenController.jumlahToken = self.tJumlah.text!
                                    self.performSegue(withIdentifier: "segCheckoutDetail", sender: self)
                                }
                            }else if status == 401 {
                                
                                self.redirectToLogin()
                            }
                            
                        }catch let parsingError{
                            
                            self.hideLoading()
                            print("Error", parsingError)
                            CustomToast.show(message: parsingError.localizedDescription, controller: self)
                        }
                    }
                }
            }else{
                
                CustomToast.show(message: "Please check your internet connection", controller: self)
            }
        }
        
        proses.resume()
    }
    
    
    @IBAction func onUbahCabangClicked(_ sender: Any) {
        
        if self.listCabang.count > 0 {
        
            let vc = UIViewController()
            vc.preferredContentSize = CGSize(width: 250,height: 250)
            let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
            
            pickerView.delegate = self
            pickerView.dataSource = self
            
            var x = 0
            for item in self.listCabang {
                
                if self.selectedCabang == item.item1 {
                    
                    pickerView.selectRow(x, inComponent: 0, animated: false)
                    break
                }
                
                x += 1
            }
            
            vc.view.addSubview(pickerView)
            
            let editRadiusAlert = UIAlertController(title: "Pilih Cabang", message: "", preferredStyle: UIAlertController.Style.alert)
            editRadiusAlert.setValue(vc, forKey: "contentViewController")
            editRadiusAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { action in
                
                    self.selectedCabang = self.tempIdCabang
                    self.lCabang.text = self.tempNamaCabang
                
                }))
            editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(editRadiusAlert, animated: true)
        }else{
            
            CustomToast.show(message: "Harap tunggu hingga data cabang termuat", controller: self)
        }
    }
    
    func showLoading(){
        
        DispatchQueue.main.async {
            
            self.pbLoading.showActivityIndicator(uiView: self.view)
        }
    }
    
    func hideLoading(){
        
        DispatchQueue.main.async {
            
            self.pbLoading.hideActivityIndicator(uiView: self.view)
        }
    }
    
    func redirectToLogin(){
        
        DispatchQueue.main.async {
            
            ViewController.specialState = 1
            let firebaseAuth = Auth.auth()
            
            // logout FB
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
}
