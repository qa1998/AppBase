//
//  BankFakeRepository.swift
//  AppBase
//

import Combine
import Foundation

final class BankFakeRepository: BankRepositoryProtocol {

    private let requestDelay: TimeInterval = 0.8

    func getBanks() -> AnyPublisher<[Bank], APIError> {
        UseCasePublisher.make { completion in
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + self.requestDelay) {
                completion(.success(Self.sampleBanks))
            }
        }
    }

    private static let sampleBanks: [Bank] = [
        Bank(id: 43, name: "Ngân hàng TMCP Ngoại Thương Việt Nam", code: "VCB", bin: "970436", shortName: "Vietcombank", logo: "https://cdn.vietqr.io/img/VCB.png"),
        Bank(id: 17, name: "Ngân hàng TMCP Công thương Việt Nam", code: "ICB", bin: "970415", shortName: "VietinBank", logo: "https://cdn.vietqr.io/img/ICB.png"),
        Bank(id: 4, name: "Ngân hàng TMCP Đầu tư và Phát triển Việt Nam", code: "BIDV", bin: "970418", shortName: "BIDV", logo: "https://cdn.vietqr.io/img/BIDV.png")
    ]
}
