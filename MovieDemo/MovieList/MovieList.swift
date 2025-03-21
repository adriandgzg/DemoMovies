//
//  MovieList.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//

import SwiftUI

// Definir un valor de expiración de los datos en minutos
let dataExpirationTimeInMinutes = 3

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
        // Intentar cargar datos desde UserDefaults
        if let savedMovies = loadMoviesFromStorage() {
            let timeElapsed = Date().timeIntervalSince(savedMovies.timestamp)
            // Si los datos tienen menos de 3 minutos, cargamos los almacenados
            if timeElapsed < TimeInterval(dataExpirationTimeInMinutes * 60) {
                completion(.success(savedMovies.movies))
                return
            }
        }

        // Si no hay datos guardados o si han pasado más de 3 minutos, consumimos el servicio
        repository.fetchTopRatedMovies { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    // Guardar los nuevos datos
                    self.saveMoviesToStorage(movies)
                    completion(.success(movies))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    // Guardar las películas en UserDefaults
    private func saveMoviesToStorage(_ movies: [Movie]) {
        let moviesData = try? JSONEncoder().encode(movies)
        let moviesWithTimestamp = MoviesWithTimestamp(movies: movies, timestamp: Date())
        
        if let encodedData = try? JSONEncoder().encode(moviesWithTimestamp) {
            UserDefaults.standard.set(encodedData, forKey: "savedMovies")
        }
    }

    // Cargar las películas desde UserDefaults
    private func loadMoviesFromStorage() -> MoviesWithTimestamp? {
        guard let savedData = UserDefaults.standard.data(forKey: "savedMovies"),
              let savedMovies = try? JSONDecoder().decode(MoviesWithTimestamp.self, from: savedData) else {
            return nil
        }
        return savedMovies
    }
}

// Modelo para guardar películas con su timestamp
struct MoviesWithTimestamp: Codable {
    let movies: [Movie]
    let timestamp: Date
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
