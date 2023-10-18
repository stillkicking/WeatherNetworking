//
//  Publisher+Ext.swift
//  Weather
//
//  Created by jonathan saville on 11/09/2023.
//

import Combine

extension Publisher {
    
    func toResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        self.map(Result.success)
            .catch { error in Just(.failure(error)) }
            .eraseToAnyPublisher()
    }
}
