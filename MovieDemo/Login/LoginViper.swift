//
//  LoginViper.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//

import SwiftUI
import Foundation

protocol LoginPresenterProtocol: AnyObject {
    func login(email: String, password: String, isLoggedIn: Binding<Bool>)
}

protocol LoginInteractorProtocol: AnyObject {
    func authenticate(email: String, password: String, completion: @escaping (Bool) -> Void)
}

protocol LoginRouterProtocol {
    func navigateToMovieList(isLoggedIn: Binding<Bool>)
}

class LoginInteractor: LoginInteractorProtocol {
    func authenticate(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let isValid = email == "test@example.com" && password == "password123"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(isValid)
        }
    }
}

class LoginPresenter: ObservableObject, LoginPresenterProtocol {
    @Published var errorMessage: String?
    
    var interactor: LoginInteractorProtocol
    var router: LoginRouterProtocol

    init(interactor: LoginInteractorProtocol, router: LoginRouterProtocol) {
        self.interactor = interactor
        self.router = router
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

class LoginRouter: LoginRouterProtocol {
   
    func navigateToMovieList(isLoggedIn: Binding<Bool>) {
        DispatchQueue.main.async {
            isLoggedIn.wrappedValue = true
        }
    }
    
    static func setupLoginModule(isLoggedIn: Binding<Bool>) -> some View {
        let interactor = LoginInteractor()
        let router = LoginRouter()
        let presenter = LoginPresenter(interactor: interactor, router: router)
        let loginView = LoginView(presenter: presenter, isLoggedIn: isLoggedIn)

        return loginView
    }
}

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var presenter: LoginPresenter
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @Binding var isLoggedIn: Bool

    init(presenter: LoginPresenter, isLoggedIn: Binding<Bool>) {
        self.presenter = presenter
        self._isLoggedIn = isLoggedIn
    }

    var body: some View {
        VStack {
            Spacer()
            
            Text("TopMovies")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.gray)  // Color gris para el encabezado
                .padding(.bottom, 40)
            
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)  // Agregar sombra sutil
                    .onTapGesture {
                        clearError()
                    }

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)  // Agregar sombra sutil
                    .onTapGesture {
                        clearError()
                    }

                if let errorMessage = presenter.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                        .opacity(errorMessage.isEmpty ? 0 : 1)
                        .transition(.opacity)
                }

                Button(action: {
                    loginUser()
                }) {
                    Text(isLoading ? "Logging in..." : "Login")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(isLoading ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
                .padding(.top, 30)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(Color(UIColor.systemGray5).edgesIgnoringSafeArea(.all))  // Fondo gris claro
        .onTapGesture {
            hideKeyboard()
        }
    }

    private func loginUser() {
        isLoading = true
        presenter.login(email: email, password: password, isLoggedIn: $isLoggedIn)
    }

    private func clearError() {
        presenter.errorMessage = nil
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
