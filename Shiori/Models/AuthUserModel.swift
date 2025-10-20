//
//  UserModel.swift
//  Shiori
//
//  Created by Henrique Hida on 19/10/25.
//

import Foundation
import FirebaseAuth

struct AuthUserModel {
    let uid: String
    let email: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}
