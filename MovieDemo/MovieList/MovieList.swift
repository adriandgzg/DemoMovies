//
//  MovieList.swift
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

class MovieListInteractor: MovieListInteractorProtocol {
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }

    func getTopRatedMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        repository.fetchTopRatedMovies { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

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

import SwiftUI

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

struct MovieListView: View {
    @ObservedObject private var presenter: MovieListPresenter
    @State private var isDetailViewActive = false
    @State private var selectedMovie: Movie?
    @State private var isRefreshing = false

    init(presenter: MovieListPresenter) {
        self.presenter = presenter
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(presenter.movies) { movie in
                        MovieCard(movie: movie)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .onTapGesture {
                                    selectedMovie = movie
                                    isDetailViewActive = true
                            }
                            .onAppear {
                                if movie == presenter.movies.last {
                                    refreshMovies()
                                }
                            }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Top Rated Movies")
            .onAppear {
                presenter.fetchTopRatedMovies()
            }
            .refreshable {
                refreshMovies()
            }
            .overlay {
                if isRefreshing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
            }
            .navigationDestination(isPresented: $isDetailViewActive) {
                if let movie = selectedMovie {
                    let interactor = DetailMovieInteractor()
                    let router = DetailMovieRouter()
                    let presenter = DetailMoviePresenter(interactor: interactor, router: router)
                    DetailMovieView(presenter: presenter, movieId: movie.id)
                }
            }
        }
    }

    private func refreshMovies() {
        guard !isRefreshing else { return }
        isRefreshing = true
        presenter.fetchTopRatedMovies()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isRefreshing = false
        }
    }
}

struct MovieCard: View {
    let movie: Movie

    var body: some View {
        ZStack {
            // Cargar la imagen de la película
            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath ?? "")")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .cornerRadius(15)
                    .clipped()
            } placeholder: {
                Color.gray.opacity(0.3)  // Placeholder gris mientras se carga la imagen
            }

            // Fondo oscuro con transparencia para el texto
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.black.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .cornerRadius(15)

            VStack {
                Spacer()
                Text(movie.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .shadow(radius: 10)
            }
            .padding()
        }
        .frame(height: 250)
        .background(Color.white)  // Color de fondo de la tarjeta
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

func setupMovieListModule() -> some View {
    let interactor = MovieListInteractor()
    let presenter = MovieListPresenter(interactor: interactor)
    let view = MovieListView(presenter: presenter)


    return view
}
