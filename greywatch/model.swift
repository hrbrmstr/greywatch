import Foundation

struct GreynoiseResponse: Hashable, Codable, Identifiable {
  
  var id: UUID = UUID()
  
  let ip: String
  let noise, riot: Bool?
  let classification: String?
  let name: String?
  let link: String?
  let lastSeen: String?
  let message: String
  
  enum CodingKeys: String, CodingKey {
    case ip, noise, riot, classification, name, link
    case lastSeen = "last_seen"
    case message
  }
  
}

class GNModel: ObservableObject {
  
  @Published var seen: [GreynoiseResponse] = []
  weak var timer: Timer?
  let shortTimerDuration = 1.0
  let longTimerDuration = 30.0
  
  init() {
    startTimer()
  }
  
  deinit {
    stopTimer()
  }

  func startTimer() {
    stopTimer()
    timer = Timer.scheduledTimer(withTimeInterval: shortTimerDuration, repeats: false) { [weak self] _ in
      self?.updateIPList()
      self?.startLongerTimer()
    }
  }
  
  func startLongerTimer() {
    stopTimer()
    timer = Timer.scheduledTimer(withTimeInterval: longTimerDuration, repeats: true) { [weak self] _ in // TODO: make this configurable
      self?.updateIPList()
    }
  }
  
  func stopTimer() {
    timer?.invalidate()
  }
  
  func updateIPList() {
    
    netstat()
      .groups(pattern: IPv4Regex)
      .unique()
      .notin(seen.compactMap { $0.ip })
      .filter { !($0.matches(privateIPv4Regex)) }
      .notin(dig().components(separatedBy: "\n"))
      .forEach { ip in
          let url = URL(string: "https://api.greynoise.io/v3/community/\(ip)")!
          let configuration = URLSessionConfiguration.ephemeral
          let session = URLSession(configuration: configuration)
          let task = session.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data else { return }
            do {
              let decoder = JSONDecoder()
              let gnResponse = try decoder.decode(GreynoiseResponse.self, from: data)
              DispatchQueue.main.async {
                self.seen.append(gnResponse)
              }
            } catch let parseErr {
              debugPrint("\(parseErr)")
            }
          })
          task.resume()
        }
      }
  
}
