//
//  Presenter.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//

class MovieListPresenter: ObservableObject, MovieListPresenterProtocol {
    @Published var movies: [Movie] = []
    @Published var errorMessage: String?
    
    private let interactor: MovieListInteractorProtocol

    init(interactor: MovieListInteractorProtocol) {
        self.interactor = interactor
    }

    func fetchTopRatedMovies() {
        interactor.getTopRatedMovies { result in
            switch result {
            case .success(let movies):
                self.movies = movies
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func didSelectMovie(_ movie: Movie) {
        //no aplica por que se controla en programacion reactiva en la vista directamente
    }
}
