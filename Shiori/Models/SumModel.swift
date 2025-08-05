//
//  SumModel.swift
//  Shiori
//
//  Created by Henrique Hida on 04/08/25.
//

import Foundation

struct SumModel: Identifiable {
    let id: UUID = UUID()
    var title: String
    var content: String
    var wasRead: Bool
    var originalUrl: String
    let createAt: Date = Date()
}
