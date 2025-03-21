//
//  DetailMovie.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//

import SwiftUI


// MARK: - Movie Detail View

struct DetailMovieView: View {
    @StateObject private var presenter: DetailMoviePresenter
    @State private var movieId: Int
    @Environment(\.dismiss) private var dismiss

    init(presenter: DetailMoviePresenter, movieId: Int) {
        _presenter = StateObject(wrappedValue: presenter)
        _movieId = State(initialValue: movieId)
    }

    var body: some View {
        VStack {
            if presenter.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if let movieDetail = presenter.movieDetail {
                ScrollView {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movieDetail.posterPath ?? "")")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .cornerRadius(15)
                            .clipped()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                            .frame(height: 300)
                            .cornerRadius(15)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text(movieDetail.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)

                        Text(movieDetail.releaseDate)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text(movieDetail.overview)
                            .font(.body)
                            .foregroundColor(.black)
                            .lineLimit(nil)

                        Button(action: {
                            dismiss()
                        }) {
                            Text("Back to Movies List")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            presenter.fetchMovieDetail(movieId: movieId)
        }
    }
}



