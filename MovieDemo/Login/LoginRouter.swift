//
//  LoginRouter.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//
import SwiftUI
import Foundation


class LoginRouter: LoginRouterProtocol {
   
    func navigateToMovieList(isLoggedIn: Binding<Bool>) {
        DispatchQueue.main.async {
            isLoggedIn.wrappedValue = true
        }
    }
    
    static func setupLoginModule(isLoggedIn: Binding<Bool>) -> some View {
        let repository = LoginRepository()
        let interactor = LoginInteractor(repository: repository)
        let router = LoginRouter()
        let presenter = LoginPresenter(interactor: interactor, router: router, repository: repository)
        let loginView = LoginView(presenter: presenter, isLoggedIn: isLoggedIn)

        return loginView
    }
}
