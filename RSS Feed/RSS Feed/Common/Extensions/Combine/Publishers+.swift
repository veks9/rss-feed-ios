//
//  Publishers+.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 21.04.2024..
//

import Foundation
import Combine

extension Publishers {
    static func CombineLatestArray<P>(_ array: [P]) -> AnyPublisher<[P.Output], P.Failure> where P : Publisher {
        guard array.count != 0 else { return Just([]).setFailureType(to: P.Failure.self).eraseToAnyPublisher() }
        return array.dropFirst().reduce(into: AnyPublisher(array[0].map{[$0]})) { res, ob in
            res = res.combineLatest(ob) { i1, i2 -> [P.Output] in
                return i1 + [i2]
            }.eraseToAnyPublisher()
        }
    }
}
