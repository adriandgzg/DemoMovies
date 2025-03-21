//
//  Presenter.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//
import SwiftUI

class DetailMoviePresenter: ObservableObject, DetailMoviePresenterProtocol {
    @Published var movieDetail: MovieDetail?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = true

    private let interactor: DetailMovieInteractorProtocol
    private let router: DetailMovieRouterProtocol

    init(interactor: DetailMovieInteractorProtocol, router: DetailMovieRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func fetchMovieDetail(movieId: Int) {
        interactor.getMovieDetail(movieId: movieId) { result in
            switch result {
            case .success(let movieDetail):
                DispatchQueue.main.async {
                    self.movieDetail = movieDetail
                    self.isLoading = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func navigateBackToMovieList() {
        router.navigateBackToMovieList()
    }
}
