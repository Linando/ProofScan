//
//  MatchSuffixCell.swift
//  ProofScan
//
//  Created by Ricky Erdiansyah on 02/05/20.
//  Copyright © 2020 Linando Saputra. All rights reserved.
//

import UIKit

class MatchSuffixCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(UserDefaults.standard.bool(forKey: "ImageMatchSuffix"), animated: false)
        switchView.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        accessoryView = switchView
    }

    @objc func valueChanged(sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "ImageMatchSuffix")
        print((textLabel?.text ?? "") + " switch is " + (sender.isOn ? "ON" : "OFF"))
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
