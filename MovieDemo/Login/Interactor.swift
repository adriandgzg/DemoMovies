//
//  Interactor.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//



import SwiftUI
import Foundation


class LoginInteractor: LoginInteractorProtocol {
    private let repository: LoginRepositoryProtocol

    init(repository: LoginRepositoryProtocol = LoginRepository()) {
        self.repository = repository
    }

    func authenticate(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let isValid = email == "test@example.com" && password == "password123"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if isValid {
                self.repository.saveLoginStatus(isLoggedIn: true)
            }
            completion(isValid)
        }
    }
}

