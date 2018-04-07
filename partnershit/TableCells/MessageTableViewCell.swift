//
//  MessageTableViewCell.swift
//  partnershit
//
//  Created by user on 3/4/2018.
//  Copyright © 2018 AnthonyChan. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTxt: UILabel!
    @IBOutlet weak var msgTxt: UILabel!
    @IBOutlet weak var dateTxt: UILabel!
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
