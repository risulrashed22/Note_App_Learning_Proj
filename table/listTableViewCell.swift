//
//  listTableViewCell.swift
//  table
//
//  Created by Risul Rashed
//

import UIKit

// We created our own protocol for checkbutton
protocol ListTableViewCellDelegate: class{
    func checkBoxToggle(sender: listTableViewCell)
}

class listTableViewCell: UITableViewCell {
    
    weak var delegate: ListTableViewCellDelegate?
    
    @IBOutlet weak var ckeckBoxButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBAction func checkBoxPressed(_ sender: Any) {
        delegate?.checkBoxToggle(sender: self)
    }
    
}
