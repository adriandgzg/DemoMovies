//
//  Protocols.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//

protocol MovieListViewProtocol: AnyObject {
    func showMovies()
    func showError(_ message: String)
}

protocol MovieListPresenterProtocol: AnyObject {
    func fetchTopRatedMovies()
    func didSelectMovie(_ movie: Movie)
}

protocol MovieListInteractorProtocol: AnyObject {
    func getTopRatedMovies(completion: @escaping (Result<[Movie], Error>) -> Void)
}

protocol MovieListRouterProtocol {
    func navigateToMovieDetail(movie: Movie)
}
