//
//  NetworkManager.swift
//
//  Created by Thomas Woodfin on 03/07/21.
//

import Foundation

typealias ModelRequestCompletion = (Result<DataResponse<Decodable>, Error>) -> Void
typealias DataRequestCompletion = (Result<DataResponse<Data>, Error>) -> Void

class NetworkManager {
    
    var session: URLSession
    
    private struct NilDecodable: Decodable { }
    
    init() {
        session = URLSession.shared
    }
    
    func executeRequest<T: Decodable>(requestConfiguration: RequestConfigurationProtocol, responseHandler: ResponseHandlerProtocol = ResponseHandler(), responseModel: T.Type, modelRequestCompletion: ModelRequestCompletion?) {
        executeRequest(requestConfiguration: requestConfiguration, responseHandler: responseHandler, responseModel: responseModel, modelRequestCompletion: modelRequestCompletion, dataRequestCompletion: nil)
    }
    
    func executeRequest(requestConfiguration: RequestConfigurationProtocol, responseHandler: ResponseHandlerProtocol = ResponseHandler(), dataRequestCompletion: DataRequestCompletion?) {
        executeRequest(requestConfiguration: requestConfiguration, responseHandler: responseHandler, responseModel: NilDecodable.self, modelRequestCompletion: nil, dataRequestCompletion: dataRequestCompletion)
    }
    
    private func executeRequest<T: Decodable>(requestConfiguration: RequestConfigurationProtocol, responseHandler: ResponseHandlerProtocol = ResponseHandler(), responseModel: T.Type, modelRequestCompletion: ModelRequestCompletion?, dataRequestCompletion: DataRequestCompletion?) {
        requestConfiguration.generateRequest { result in
            withExtendedLifetime(requestConfiguration) {
                switch result {
                case .success(let request):
                    let task = self.dataTask(request: request, responseHandler: responseHandler, responseModel: responseModel, modelRequestCompletion: modelRequestCompletion, dataRequestCompletion: dataRequestCompletion)
                    task.resume()
                case .failure(let error):
                    modelRequestCompletion?(.failure(error))
                    dataRequestCompletion?(.failure(error))
                }
            }
        }
    }
    
    func dataTask<T: Decodable>(request: URLRequest, responseHandler: ResponseHandlerProtocol, responseModel: T.Type, modelRequestCompletion: ModelRequestCompletion?, dataRequestCompletion: DataRequestCompletion?) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                modelRequestCompletion?(.failure(NetworkError.networkFailure(error: error)))
                dataRequestCompletion?(.failure(NetworkError.networkFailure(error: error)))
                return
            }
            
            do {
                try responseHandler.validateResponse(response: response, data: data)
            } catch (let validateResponseError) {
                modelRequestCompletion?(.failure(validateResponseError))
                dataRequestCompletion?(.failure(validateResponseError))
                return
            }
            
            if !(responseModel is NilDecodable.Type), let data = data {
                do {
                    let dataObject: Decodable = try JSONDecoder().decode(responseModel, from: data)
                    let dataResponse = DataResponse(data: dataObject, urlResponse: response)
                    modelRequestCompletion?(.success(dataResponse))
                    return
                } catch {
                    modelRequestCompletion?(.failure(NetworkError.decodeModelFailure(error: error)))
                }
            }
            let modelDataResponse = DataResponse<Decodable>(data: nil, urlResponse: response)
            modelRequestCompletion?(.success(modelDataResponse))
            
            let dataDataResponse = DataResponse<Data>(data: data, urlResponse: response)
            dataRequestCompletion?(.success(dataDataResponse))
        }
        return task
    }
}
