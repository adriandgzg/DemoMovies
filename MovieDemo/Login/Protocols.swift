//
//  Untitled.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//

import Foundation
import SwiftUI
protocol LoginPresenterProtocol: AnyObject {
    func login(email: String, password: String, isLoggedIn: Binding<Bool>)
    func checkLoginStatus(isLoggedIn: Binding<Bool>)
}

protocol LoginInteractorProtocol: AnyObject {
    func authenticate(email: String, password: String, completion: @escaping (Bool) -> Void)
}

protocol LoginRouterProtocol {
    func navigateToMovieList(isLoggedIn: Binding<Bool>)
}

protocol LoginRepositoryProtocol {
    func saveLoginStatus(isLoggedIn: Bool)
    func getLoginStatus() -> Bool
}
