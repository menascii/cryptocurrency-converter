
import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let exchangeRateURL = "https://rest.coinapi.io/v1/exchangerate"
    let apiKey = "Enter API Key"

    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    let coinArray = ["BTC","ETH","LTC","XRP","D"]
    
    func getCoinPrice(for currencyData: CurrencyData) {
        
        let urlString = "\(exchangeRateURL)/\(currencyData.crypto)/\(currencyData.currency)?apikey=\(apiKey)"
        print(urlString)
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let bitcoinPrice = self.parseJSON(safeData) {
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdatePrice(price: priceString, currency: currencyData.currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    func getCoinLogo(for currencyData: CurrencyData) {
        
    }
    
    func parseJSON(_ data: Data) -> Double? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
