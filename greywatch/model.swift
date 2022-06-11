import Foundation
import Darwin

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

  var md: String {
    return(
      (self.link != nil) ?
      "[\(self.ip)](\(self.link!))" :
        "_[\(self.ip)](https://ipinfo.io/\(self.ip))_"
    )
  }
  
}

class GNModel: ObservableObject {
  
  @Published var seen: [GreynoiseResponse] = []
  @Published var queryLimitExceeded = false
  
  weak var timer: Timer?
  let shortTimerDuration = 1.0
  let longTimerDuration = 0.5
  
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
  
    let gnapikey = UserDefaults.standard.string(forKey: "GNAPIKEY")
    
    if (queryLimitExceeded) {
      stopTimer()
      return()
    }
    
    netstat()
      .notin(seen.compactMap { $0.ip })
      .filter { !($0.matches(privateIPv4Regex)) }
      .notin(dig(GREYNOISE_API_HOST))
      .notin(dig(IPAPI_HOST))
      .forEach { ip in
        
        if (!queryLimitExceeded) {
          
          let url = URL(string: "https://api.greynoise.io/v3/community/\(ip)")!
          let configuration = URLSessionConfiguration.ephemeral
          let session = URLSession(configuration: configuration)
          
          var request = URLRequest(url: url)
          request.httpMethod = "GET"
          
          if (gnapikey != nil) {
            request.setValue(gnapikey!, forHTTPHeaderField: "key")
          }
          
//          debugPrint("request: \(request)")
          
          let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            if let response = response as? HTTPURLResponse {
              
              if (response.statusCode == 429) {
                
//                debugPrint("STATUS")
                
                DispatchQueue.main.async {
                  self.queryLimitExceeded = true
                }
                
              } else {
                
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
                
              }
              
            }
            
          })
          
          task.resume()

        }
        
      }
  }
  
}
