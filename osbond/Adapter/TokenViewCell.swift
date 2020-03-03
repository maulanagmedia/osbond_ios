//
//  TokenViewCell.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 21/03/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit

class TokenViewCell: UITableViewCell {
    
    @IBOutlet weak var iv_bgtoken: UIImageView!
    @IBOutlet weak var iv_logoright: UIImageView!
    @IBOutlet weak var l_cabang: UILabel!
    @IBOutlet weak var iv_logocenter: UIImageView!
    @IBOutlet weak var l_package: UILabel!
    @IBOutlet weak var v_description: UIView!
    @IBOutlet weak var l_duedate: UILabel!
    @IBOutlet weak var l_used: UILabel!
    @IBOutlet weak var l_timeleft: UILabel!
    @IBOutlet weak var l_token: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
