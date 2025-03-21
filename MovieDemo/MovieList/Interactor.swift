//
//  Interactor.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//
import SwiftUI
import Foundation

// Definir un valor de expiración de los datos en minutos
let dataExpirationTimeInMinutes = 3




// Modelo para guardar películas con su timestamp
struct MoviesWithTimestamp: Codable {
    let movies: [Movie]
    let timestamp: Date
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
