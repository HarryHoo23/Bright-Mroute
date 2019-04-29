//
//  HandBookTableViewCell.swift
//  Mroute
//
//  Created by Zhongheng Hu on 25/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//

import UIKit

class HandBookTableViewCell: UITableViewCell {

    @IBOutlet weak var signImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
