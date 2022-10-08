//
//  ToDoItem.swift
//  table
//
//  Created by Risul Rashed
//

import Foundation

struct ToDoItem: Codable{
    var name: String
    var date: Date
    var note: String
    var reminder: Bool
    var notificationID: String?
    var completed: Bool
}
