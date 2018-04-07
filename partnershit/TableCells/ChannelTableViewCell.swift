//
//  ChannelTableViewCell.swift
//  partnershit
//
//  Created by user on 3/4/2018.
//  Copyright © 2018 AnthonyChan. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    @IBOutlet var channelName: UILabel!
    @IBOutlet weak var channelCodeBtn: UIButton!
    @IBAction func channelCodeBtn(_ sender: Any) {
        UIPasteboard.general.string = self.channelCodeBtn.currentTitle
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
