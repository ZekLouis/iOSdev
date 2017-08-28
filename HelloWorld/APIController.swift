//
//  APIController.swift
//  HelloWorld
//
//  Created by Louis Gaume on 25/08/2017.
//  Copyright © 2017 Louis Gaume. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSArray)
}

class APIController{
    
    init(delegate : APIControllerProtocol){
        self.delegate = delegate
    }
    
    var delegate: APIControllerProtocol
    
    func searchItunesFor(searchTerm: String){
        // L'API iTunes demande des termes multiples, séparés par des + , alors remplacez les espaces par des +
        let itunesSearchTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
        
        // Maintenant échappez tout ce qui n'est pas URL-friendly
        if let escapedSearchTerm = itunesSearchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)   {
            let urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music&entity=album"
            let url = NSURL(string: urlPath)
            let session = URLSession.shared
            let task = session.dataTask(with: url! as URL, completionHandler: {data, response, error -> Void in
                print("Tâche teminée")
                if(error != nil) {
                    // Si une erreur survient lors de la requête web, l'afficher en console
                    print(error?.localizedDescription ?? "Error")
                }
                do{
                    var err: NSError?
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        if(err != nil) {
                            // Si une erreur survient pendant l'analyse du JSON, l'afficher en console
                            print("Erreur JSON \(err!.localizedDescription)")
                        }
                        if let results: NSArray = jsonResult["results"] as? NSArray {
                            self.delegate.didReceiveAPIResults(results: results)
                        }
                    }
                }catch{
                    print(error)
                }
                
            })
            
            // task est juste un objet avec toutes ces propriétés définies
            // Afin d'exécuter réellement la requête web, nous devons appeler resume()
            task.resume()
        }
    }

}
