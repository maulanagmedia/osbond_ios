//
//  VKuponController.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 06/03/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import Foundation
import UIKit

class VKuponController: UIView {
    
    static let instance = VKuponController()
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var edtNomor: UITextField!
    @IBOutlet weak var superParentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("VKuponController", owner: self, options: nil)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init Coder has been implemented")
    }
    
    private func initUI(){
        
        superParentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        superParentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func showAlert(){
        
        DispatchQueue.main.async {
         
            UIApplication.shared.keyWindow?.addSubview(self.superParentView)
        }
    }
    
                        
    @IBAction func onSkipClicked(_ sender: Any) {
        
        DispatchQueue.main.async {
         
            self.superParentView.removeFromSuperview()
        }
    }
}
