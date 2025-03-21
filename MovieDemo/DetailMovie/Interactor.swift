//
//  Interactor.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.


class DetailMovieInteractor: DetailMovieInteractorProtocol {
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }

    func getMovieDetail(movieId: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        repository.fetchMovieDetail(movieId: movieId) { result in
            completion(result)
        }
    }
}
