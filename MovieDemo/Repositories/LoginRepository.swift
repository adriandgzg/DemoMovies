//
//  LoginRepository.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//
import Foundation


class LoginRepository: LoginRepositoryProtocol {
    private let loginKey = "isLoggedIn"

    func saveLoginStatus(isLoggedIn: Bool) {
        UserDefaults.standard.set(isLoggedIn, forKey: loginKey)
    }

    func getLoginStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: loginKey)
    }
}
