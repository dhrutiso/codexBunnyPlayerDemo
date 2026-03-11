import Foundation

struct VMAPResult {
    let preRollURL: URL?
}

enum VMAPServiceError: Error {
    case invalidData
    case invalidURL
}

final class VMAPService: NSObject {
    private var completion: ((Result<VMAPResult, Error>) -> Void)?
    private var foundAdTagURL: URL?

    func fetchPreRoll(from vmapURL: URL, completion: @escaping (Result<VMAPResult, Error>) -> Void) {
        self.completion = completion

        URLSession.shared.dataTask(with: vmapURL) { [weak self] data, _, error in
            guard let self else { return }

            if let error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data else {
                DispatchQueue.main.async { completion(.failure(VMAPServiceError.invalidData)) }
                return
            }

            self.parseVMAP(data: data)
        }.resume()
    }

    private func parseVMAP(data: Data) {
        foundAdTagURL = nil
        let parser = XMLParser(data: data)
        parser.delegate = self
        if !parser.parse() {
            DispatchQueue.main.async {
                self.completion?(.failure(parser.parserError ?? VMAPServiceError.invalidData))
            }
            return
        }

        guard let foundAdTagURL else {
            DispatchQueue.main.async {
                self.completion?(.success(VMAPResult(preRollURL: nil)))
            }
            return
        }

        resolveAdMediaURL(from: foundAdTagURL)
    }

    private func resolveAdMediaURL(from adTagURL: URL) {
        URLSession.shared.dataTask(with: adTagURL) { [weak self] data, _, error in
            guard let self else { return }
            if let error {
                DispatchQueue.main.async { self.completion?(.failure(error)) }
                return
            }

            guard let data else {
                DispatchQueue.main.async { self.completion?(.failure(VMAPServiceError.invalidData)) }
                return
            }

            if let mediaURL = self.extractFirstMediaFileURL(fromVAST: data) {
                DispatchQueue.main.async {
                    self.completion?(.success(VMAPResult(preRollURL: mediaURL)))
                }
            } else {
                DispatchQueue.main.async {
                    self.completion?(.success(VMAPResult(preRollURL: adTagURL)))
                }
            }
        }.resume()
    }

    private func extractFirstMediaFileURL(fromVAST data: Data) -> URL? {
        let xml = String(data: data, encoding: .utf8) ?? ""
        guard
            let start = xml.range(of: "<MediaFile"),
            let close = xml[start.upperBound...].range(of: ">"),
            let end = xml[close.upperBound...].range(of: "</MediaFile>")
        else {
            return nil
        }

        let urlString = xml[close.upperBound..<end.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        return URL(string: urlString)
    }
}

extension VMAPService: XMLParserDelegate {
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if foundAdTagURL == nil,
           let urlString = String(data: CDATABlock, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           let url = URL(string: urlString),
           url.absoluteString.lowercased().contains("vast") || url.pathExtension == "xml" {
            foundAdTagURL = url
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard foundAdTagURL == nil else { return }
        let value = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, let url = URL(string: value) else { return }
        if value.lowercased().contains("vast") || url.pathExtension == "xml" {
            foundAdTagURL = url
        }
    }
}
