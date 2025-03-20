//
//  Networking.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 19/03/25.
//

import Foundation

// MARK: - API Endpoints
struct APIEndpoints {
    static let baseURL = "https://api.themoviedb.org/3"
    static let topRatedMovies = "/movie/top_rated"
    static let movieDetail = "/movie/"
    static let apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjODlmOTk3YjlmODA1ZDc4M2M4MWZjMWU4NTRlZDdkMSIsIm5iZiI6MTYzNzI2ODExNC4wMjksInN1YiI6IjYxOTZiYTkyYmMyY2IzMDA0Mjc4M2U0NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.HDmRUOVag6DDHuvIytcYzfmjUxPUajw9Fo1oe-sjH0A"
}

// MARK: - Network Manager Protocol
protocol NetworkManagerProtocol {
    func fetchData<T: Decodable>(from endpoint: String, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void)
}

// MARK: - Network Manager Implementation
class NetworkManager: NetworkManagerProtocol {
    func fetchData<T: Decodable>(from endpoint: String, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: "\(APIEndpoints.baseURL)\(endpoint)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(APIEndpoints.apiKey)", forHTTPHeaderField: "Authorization")  // Agregar el token de autorización
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            // Debugging: Print response data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

// MARK: - Movie Repository Protocol
protocol MovieRepositoryProtocol {
    func fetchTopRatedMovies(completion: @escaping (Result<[Movie], Error>) -> Void)
    func fetchMovieDetail(movieId: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void)
}

// MARK: - Movie Repository Implementation
class MovieRepository: MovieRepositoryProtocol {
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func fetchTopRatedMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        networkManager.fetchData(from: APIEndpoints.topRatedMovies, responseType: MovieResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.results ?? [])) // Evita fallos si results es nil
            case .failure(let error):
                print("Error fetching top rated movies: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func fetchMovieDetail(movieId: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        let endpoint = "\(APIEndpoints.movieDetail)\(movieId)"
        networkManager.fetchData(from: endpoint, responseType: MovieDetail.self) { result in
            completion(result)
        }
    }
}

// MARK: - Movie Model
struct MovieResponse: Decodable {
    let results: [Movie]?
}

struct Movie: Decodable, Identifiable, Equatable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double

    enum CodingKeys: String, CodingKey {
        case id, title, overview, releaseDate = "release_date", voteAverage = "vote_average"
        case posterPath = "poster_path"
    }
}

struct MovieDetail: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let runtime: Int?
    let genres: [Genre]
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
}

struct Genre: Decodable {
    let id: Int
    let name: String
}
