//
//  CustomTableViewCell.swift
//  calendar-ios
//
//  Created by 강민서 on 6/8/24.
//

import UIKit
import M13Checkbox

class CustomTableViewCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var checkBox: M13Checkbox!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBAction func checkBoxValueChanged(_ sender: M13Checkbox) {
    }
    
    weak var delegate: CustomTableViewCellDelegate?
    
    let LABEL_RED = UIColor(named: "CategoryRedLabel")
    let LABEL_BLUE = UIColor(named: "CategoryBlueLabel")
    let LABEL_PURPLE = UIColor(named: "CategoryPurpleLabel")
    let LABEL_YELLOW = UIColor(named: "CategoryYellowLabel")
    
    let VIEW_RED = UIColor(named: "TodoRedBackground")
    let VIEW_BLUE = UIColor(named: "TodoBlueBackground")
    let VIEW_PURPLE = UIColor(named: "TodoPurpleBackground")
    let VIEW_YELLOW = UIColor(named: "TodoYellowBackground")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCheckbox()
        setupRoundedCorners()
        addTapGestureToTitleLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupRoundedCorners()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0))
    }
    
    // 제목 레이블에 TapGesture 추가
    private func addTapGestureToTitleLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tapGesture)
    }
    
    // 제목 레이블 탭 처리
    @objc private func titleLabelTapped() {
        delegate?.titleLabelTapped(in: self, with: titleLabel.text ?? "")
    }
    
    // 카테고리에 따라 View와 Label 색상 변경
    func configureBackgroundColor(category: String) {
        switch category {
        case "IMPORTANT":
            self.labelView.backgroundColor = LABEL_RED
            self.contentView.backgroundColor = VIEW_RED
            self.checkBox.tintColor = LABEL_RED
        case "STUDY":
            self.labelView.backgroundColor = LABEL_BLUE
            self.contentView.backgroundColor = VIEW_BLUE
            self.checkBox.tintColor = LABEL_BLUE
        case "DAILY":
            self.labelView.backgroundColor = LABEL_PURPLE
            self.contentView.backgroundColor = VIEW_PURPLE
            self.checkBox.tintColor = LABEL_PURPLE
        case "EXERCISE":
            self.labelView.backgroundColor = LABEL_YELLOW
            self.contentView.backgroundColor = VIEW_YELLOW
            self.checkBox.tintColor = LABEL_YELLOW
        default:
            self.labelView.backgroundColor = .clear
            self.contentView.backgroundColor = .white
        }
    }
    
    // contentView 모서리 둥글게 설정
    private func setupRoundedCorners() {
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }
    
    // 체크박스 초기화 및 설정
    private func setupCheckbox() {
        checkBox.boxType = .square // 네모 모양
        checkBox.markType = .checkmark // 체크마크
        checkBox.stateChangeAnimation = .bounce(.fill) // 애니메이션
    }
    
    // 셀 하이라이트 비활성화
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }

}

protocol CustomTableViewCellDelegate: AnyObject {
    func titleLabelTapped(in cell: CustomTableViewCell, with title: String)
}
