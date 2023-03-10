//
//  FAQViewController.swift
//  TheCoralSafari
//
//  Created by Daniel King on 3/7/23.
//

import UIKit

class FAQViewController: UIViewController, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        faqs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FAQCell", for: indexPath) as! FAQCell

            let faq = faqs[indexPath.item]

            let title = faq.title

            cell.titleLabel.text = title

            return cell
    }
    

    var faqs: [FAQ] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        faqs = FAQ.FAQs
        print(faqs)

        collectionView.dataSource = self
        

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout

        layout.minimumInteritemSpacing = 4

        layout.minimumLineSpacing = 4

        let numberOfColumns: CGFloat = 3

        let width = (collectionView.bounds.width - layout.minimumInteritemSpacing * (numberOfColumns - 1)) / numberOfColumns

        layout.itemSize = CGSize(width: width, height: width)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
