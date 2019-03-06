//
//  HomeViewController.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 04/03/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var collectionHeaderView: UICollectionView!
    @IBOutlet weak var headerPageControl: UIPageControl!
    let session = SessionManager()
    let TAG = "HOMEVIEW "
    
    /*var imgArr:[String] = [
        "image1.jpg"
        ,"image2.jpg"
        ,"image3.jpg"
        ,"image4.jpg"
        ,"image5.jpg"
        ,"image6.jpg"
    ]*/
    
    var listHeader = [CustomItem]()
    
    var timer = Timer()
    var counter = 0
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return listHeader.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HeaderViewCell
        
        let customItem = listHeader[indexPath.row]
        let urlImage = URL(string: (customItem.item1).replacingOccurrences(of: " ", with: "%20"))
        
        if urlImage != nil {
         
            let data = try? Data(contentsOf: urlImage!)
            
            if let imageData = data {
                let image = UIImage(data: imageData)
                cell.ivHeader.image = image
            }
        }else{
            
            print(TAG+customItem.item1)
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerPageControl.numberOfPages = listHeader.count
        if listHeader.count > 0
        {
            headerPageControl.currentPage = 0
        }
        
        self.getHeaderImages()
    }
    
    @objc func changeImage() {
        
        if listHeader.count > 0 {
         
            if counter < listHeader.count {
                let index = IndexPath.init(item: counter, section: 0)
                self.collectionHeaderView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                //headerPageControl.currentPage = counter
                counter += 1
            } else {
                counter = 0
                let index = IndexPath.init(item: counter, section: 0)
                self.collectionHeaderView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
                //headerPageControl.currentPage = counter
                counter = 1
            }
        }
        
    }
    
    func getHeaderImages(){
        
        let url = URL(string: ServerURL.getImageSlider)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        request.httpMethod = "GET"
        
        let proses = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            if let jsonValue = String(data: data!, encoding: .ascii){
                if let jsonData = jsonValue.data(using: .utf8) {
                    
                    do {
                        
                        self.listHeader.removeAll()
                        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                        
                        let metadata = json.value(forKey: "metadata") as? NSDictionary
                        let responseApi = json.value(forKey: "response") as? NSArray
                        
                        let status = metadata?.value(forKey: "status") as? Int64
                        let message = metadata?.value(forKey: "message") as? String
                        
                        if status == 200 {
                            
                            CustomToast.show(message: message ?? "", controller: self)
                            for jo in responseApi! {
                                
                                let dataRow = jo as? [String: String]
                                self.listHeader.append(CustomItem(item1: (dataRow?["picture"])!))
                            }
                            
                            self.collectionHeaderView.reloadData()
                            self.headerPageControl.numberOfPages = self.listHeader.count
                            DispatchQueue.main.async {
                                self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
                            }
                            
                        }else{
                            CustomToast.show(message: message ?? "", controller: self)
                        }
                        
                    }catch let parsingError{
                        
                        print("Error", parsingError)
                    }
                }
            }
        }
        
        proses.resume()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerPageControl.currentPage =    Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
}
