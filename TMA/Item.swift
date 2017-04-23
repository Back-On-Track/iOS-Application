//
//  Item.swift
//  TMA
//
//  Created by Arvinder Basi on 2/10/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift

let STUDY_EVENT = 0
let HOMEWORK_EVENT = 1
let PROJECT_EVENT = 2
let LAB_EVENT = 3
let OTHER_EVENT = 4

let eventType: [String] = ["Study", "Homework", "Project", "Lab", "Other"]

class Item: Object {
    dynamic var title: String!
    dynamic var date: Date!
    dynamic var endDate: Date!
    dynamic var course: Course!
    dynamic var duration: Float = 0.0 //hours
    dynamic var type: Int = OTHER_EVENT
    dynamic var goal: Goal?
}
