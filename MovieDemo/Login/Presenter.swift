//
//  Presenter.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//
import Foundation
import Combine
import SwiftUI

class LoginPresenter: ObservableObject, LoginPresenterProtocol {
    @Published var errorMessage: String?
    private let interactor: LoginInteractorProtocol
    private let router: LoginRouterProtocol
    private let repository: LoginRepositoryProtocol

    init(interactor: LoginInteractorProtocol, router: LoginRouterProtocol, repository: LoginRepositoryProtocol = LoginRepository()) {
        self.interactor = interactor
        self.router = router
        self.repository = repository
    }

    func checkLoginStatus(isLoggedIn: Binding<Bool>) {
        DispatchQueue.main.async {
            isLoggedIn.wrappedValue = self.repository.getLoginStatus()
        }
    }

    func login(email: String, password: String, isLoggedIn: Binding<Bool>) {
        interactor.authenticate(email: email, password: password) { success in
            DispatchQueue.main.async {
                if success {
                    self.router.navigateToMovieList(isLoggedIn: isLoggedIn)
                } else {
                    self.errorMessage = "Invalid credentials"
                }
            }
        }
    }
}
