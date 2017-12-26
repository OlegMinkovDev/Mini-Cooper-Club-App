//
//  RouteCell.swift
//  Mini Cooper Club App
//
//  Created by Олег Минков on 01.08.16.
//  Copyright © 2016 Oleg Minkov. All rights reserved.
//

import UIKit

class RouteCell: UITableViewCell {

    @IBOutlet weak var textTF: UITextField!
    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var imageIV: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
