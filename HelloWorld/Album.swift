//
//  Album.swift
//  HelloWorld
//
//  Created by Louis Gaume on 25/08/2017.
//  Copyright © 2017 Louis Gaume. All rights reserved.
//

import Foundation

struct Album {
    let titre: String
    let prix: String
    var miniatureImageURL: String
    var largeImageURL: String
    var itemURL: String
    var artisteURL: String
    
    init(nom: String, prix: String, miniatureImageURL: String, largeImageURL: String, itemURL: String, artisteURL: String){
        self.titre = nom
        self.prix = prix
        self.miniatureImageURL = miniatureImageURL
        self.largeImageURL = largeImageURL
        self.itemURL = itemURL
        self.artisteURL = artisteURL
    }
    
    static func albumsWithJSON(results: NSArray) -> [Album] {
        // Créer un tableau d'albums vide, à remplir depuis cette liste
        var albums = [Album]()
        
        // Stocker les résultats dans notre tableau
        if results.count>0 {
            
            // Parfois iTunes retourne une collection, pas un morceau, alors nous vérifions 'nom' pour les deux cas de figure
            for result in results {
                
                var nom = result["trackName"] as? String
                if nom == nil {
                    nom = result["collectionName"] as? String
                }
                
                // Parfois le prix est dans formattedPrice, d'autres fois dans collectionPrice... Et il arrive que ce soit un nombre flottant plutôt qu'une chaîne. C'est formidable!
                var prix = result["formattedPrice"] as? String
                if prix == nil {
                    prix = result["collectionPrice"] as? String
                    if price == nil {
                        var prixFloat: Float? = result["collectionPrice"] as? Float
                        var nf: NumberFormatter = NumberFormatter()
                        nf.maximumFractionDigits = 2
                        if prixFloat != nil {
                            prix = "$\(nf.stringFromNumber(prixFloat!)!)"
                        }
                    }
                }
                
                let miniatureURL = result["artworkUrl60"] as? String ?? ""
                let imageURL = result["artworkUrl100"] as? String ?? ""
                let artisteURL = result["artistViewUrl"] as? String ?? ""
                
                var itemURL = result["collectionViewUrl"] as? String
                if itemURL == nil {
                    itemURL = result["trackViewUrl"] as? String
                }
                
                var newAlbum = Album(nom: nom!, prix: prix!, miniatureImageURL: miniatureURL, largeImageURL: imageURL, itemURL: itemURL!, artisteURL: artisteURL)
                albums.append(newAlbum)
            }
        }
        return albums
    }
}
