//
//  CustomTableViewCell.swift
//  calendar-ios
//
//  Created by 강민서 on 6/8/24.
//

import UIKit
import M13Checkbox

class CustomTableViewCell: UITableViewCell {
    
    var checkbox: M13Checkbox!
    
//    @IBOutlet weak var textFieldLabel: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        setupViews()
//        setupConstraints()
    }

}
