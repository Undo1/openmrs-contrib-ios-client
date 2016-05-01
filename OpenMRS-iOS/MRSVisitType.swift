//
//  MRSVisitType.swift
//  OpenMRS-iOS
//
//  Created by Parker Erway on 1/22/15.
//

import Foundation

class MRSVisitType : NSObject, NSCoding
{
    var uuid: String!
    var display: String!

    override init() {
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        super.init()
        self.uuid = aDecoder.decodeObjectForKey("uuid") as! String
        self.display = aDecoder.decodeObjectForKey("display") as! String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        [aCoder.encodeObject(self.uuid, forKey: "uuid")]
        [aCoder.encodeObject(self.display, forKey: "display")]
    }
}