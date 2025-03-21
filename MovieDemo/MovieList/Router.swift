//
//  Router.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//



class MovieListRouter: MovieListRouterProtocol {
    @Binding var selectedMovie: Movie?
    @Binding var isDetailViewActive: Bool

    init(selectedMovie: Binding<Movie?>, isDetailViewActive: Binding<Bool>) {
        _selectedMovie = selectedMovie
        _isDetailViewActive = isDetailViewActive
    }

    func navigateToMovieDetail(movie: Movie) {
        DispatchQueue.main.async {
            self.selectedMovie = movie
            self.isDetailViewActive = true
        }
    }
}
