//
//  BeyableService.swift
//
//
//  Created by Ouamassi Brahim on 25/01/2024.
//

import Foundation
import Combine
/// Service class for handling Beyable API requests
@available(iOS 13.0, *)
class BeyableService {
    /// Shared instance of the BeyableService.
    static let shared = BeyableService()
    /// Base URL of the Beyable API.
    private var baseApiURL = ""
    /// URLSession for handling network requests.
    private let urlSession = URLSession.shared
    /// Set to manage subscriptions.
    private var subscriptions = Set<AnyCancellable>()
    /// JSONDecoder for decoding JSON responses.
    private let jsonDecoder = JSONDecoder()
    /// Queue to store pending requests.
    private var requestQueue: [() -> Void] = []
    /// Indicates if a request is currently being processed.
    private var isProcessing = false
    /// Private initializer to prevent direct instantiation of BeyableService.
    private init() {}
    
    
    /// Called after user initialize the SDK
    /// - Parameter baseUrl: preproduction url or production url
    public func setBaseUrlApi(baseUrl : String){
        self.baseApiURL = baseUrl
    }
    
    
    /// Sends a request to the Beyable API and returns a Future publisher.
    /// - Parameters:
    ///   - endpoint: endpoint: The API endpoint to send the request to.
    ///   - body: The body of the request.
    /// - Returns: A publisher that emits the result of the request.
    func sendRequest<T: Codable, U: Codable>(from endpoint: String, body: U) -> AnyPublisher<T, BeyableDataAPIError> {
        return Future<T, BeyableDataAPIError> { [unowned self] promise in
            self.enqueueRequest(endpoint: endpoint, body: body) { (result: Result<T, BeyableDataAPIError>) in
                switch result {
                case .success(let value):
                    print(value)
                    promise(.success(value))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    
    /// Enqueues a request to the Beyable API.
    /// - Parameters:
    ///   - endpoint: The API endpoint to send the request to.
    ///   - body: The body of the request.
    ///   - completion: Completion handler to process the result of the request.
    private func enqueueRequest<T: Codable, U: Codable>(endpoint: String, body: U, completion: @escaping (Result<T, BeyableDataAPIError>) -> Void) {
        guard let url = createURL(with: endpoint) else {
            completion(.failure(.urlError(URLError(.unsupportedURL))))
            return
        }
        var request = URLRequest(url: url)
        let currentLanguageCode = Bundle.main.preferredLocalizations[0]
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(currentLanguageCode, forHTTPHeaderField: "AcceptLanguage")
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            request.setValue("UrlReferrer", forHTTPHeaderField: bundleIdentifier)
        }
        if let name = Bundle.main.applicationName {
            request.setValue("UserHostAddress", forHTTPHeaderField: name)
        }
        request.setValue(DataStorageHelper.getData(type: String.self, forKey: .apiKey), forHTTPHeaderField: "Authorization")
        
        
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(body)
            request.httpBody = jsonData
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }
        
        NSLog(request.log())
        
        urlSession.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    throw BeyableDataAPIError.responseError(
                        (response as? HTTPURLResponse)?.statusCode ?? 500)
                }
                
                // Déboguer les données reçues
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }
                return data
            }
            .decode(type: T.self, decoder: jsonDecoder)
            .mapError { error -> BeyableDataAPIError in
                if let decodingError = error as? DecodingError {
                    return .decodingError(decodingError)
                } else if let urlError = error as? URLError {
                    return .urlError(urlError)
                } else {
                    return .anyError
                }
            }
            .sink(receiveCompletion: { receiveCompletion in
                switch receiveCompletion {
                case .failure(let error):
                    completion(.failure(error))
                case .finished:
                    break
                }
            }, receiveValue: { value in
                completion(.success(value))
            })
            .store(in: &subscriptions)
    }
    
    
    /// Creates a URL with the given endpoint.
    /// - Parameter endpoint: The API endpoint.
    /// - Returns: The URL for the endpoint.
    private func createURL(with endpoint: String) -> URL? {
        guard let urlComponents = URLComponents(string: "\(baseApiURL)\(endpoint)") else { return nil }
        return urlComponents.url
    }
    
    
    /// Handles completion of a request.
    /// - Parameter endpoint: The endpoint of the completed request.
    public func handleCompletion(endpoint : String) {
        isProcessing = false
        processNextRequest() // Process the next request in the queue
    }
    
    
    /// Processes the next request in the queue.
    private func processNextRequest() {
        guard !requestQueue.isEmpty else { return }
        guard !isProcessing else { return }
        
        isProcessing = true
        let requestClosure = requestQueue.removeFirst()
        requestClosure()
    }
}
