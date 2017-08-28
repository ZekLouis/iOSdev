//
//  ViewController.swift
//  HelloWorld
//
//  Created by Louis Gaume on 25/08/2017.
//  Copyright © 2017 Louis Gaume. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    var albums = [Album]()
    var api : APIController!
    @IBOutlet var appsTableView : UITableView!
    let kCellIdentifier : String = "SearchResultCell"
    var imageCache = [String: UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        api = APIController(delegate: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        api.searchItunesFor(searchTerm: "Beatles")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier) as! UITableViewCell
        let album = self.albums[indexPath.row]
        
        // Obtenez le prix formaté en chaîne, pour l'afficher dans le sous-titre
        cell.detailTextLabel?.text = album.prix
        // Mettez à jour le texte de textLabel pour utiliser le titre provenant du modèle de l'album
        cell.detailTextLabel?.text = album.titre
        // Commencez par configurer l'image de la cellule à partir d'un fichier statique
        // Sans cela, nous allons nous retrouver sans une prévisualisation de l'image !
        cell.imageView?.image = UIImage(named: "Blank52")
        let miniatureURLString = album.miniatureImageURL
        let miniatureURL = NSURL(string: miniatureURLString)!
        
        // Si cette image se trouve déjà en cache, ne plus la recharger
        if let img = imageCache[miniatureURLString] {
            cell.imageView?.image = img
        }
        else {
            // L'image n'existe pas en cache, la télécharger
            // Nous devrions faire cela dans un thread d'arrière-plan
            let request: NSURLRequest = NSURLRequest(url: miniatureURL as URL)
            let mainQueue = OperationQueue.main
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convertir les données téléchargées en un objet UIImage
                    let image = UIImage(data: data!)
                    // Stocker l'image dans notre cache
                    self.imageCache[miniatureURLString] = image
                    // Mettre à jour la cellule
                    DispatchQueue.main.async(execute: {
                        if let cellToUpdate = tableView.cellForRow(at: indexPath) {
                            cellToUpdate.imageView?.image = image
                        }
                    })
                }
                else {
                    print("Error:")
                }
            })   
        }
        return cell
    }
    
    func didReceiveAPIResults(results: NSArray){
        DispatchQueue.main.async(execute: {
            self.albums = Album.albumsWithJSON(results: results)
            self.appsTableView!.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }

}

