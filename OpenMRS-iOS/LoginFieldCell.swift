//
//  LoginFieldCell.swift
//  OpenMRS-iOS
//
//  Created by Parker on 4/20/16.
//  Copyright © 2016 Erway Software. All rights reserved.
//

import UIKit

class LoginFieldCell : UITableViewCell
{
    @IBOutlet var legendLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(reuseIdentifier: String) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
    }
}
