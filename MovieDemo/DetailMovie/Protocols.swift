//
//  Protocols.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//

// MARK: - Protocolos VIPER

protocol DetailMovieViewProtocol: AnyObject {
    func showMovieDetail()
    func showError(_ message: String)
}

protocol DetailMoviePresenterProtocol: AnyObject {
    func fetchMovieDetail(movieId: Int)
}

protocol DetailMovieInteractorProtocol: AnyObject {
    func getMovieDetail(movieId: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void)
}

protocol DetailMovieRouterProtocol {
    func navigateBackToMovieList()
}
