import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the SKView
        guard let skView = self.view as? SKView else {
            print("View is not an SKView")
            return
        }
        
        
        // Create and configure the game scene
//        let scene = GameScene(size: skView.bounds.size)
        let scene = HomeScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFit
        //Enable physics
        scene.physicsWorld.contactDelegate = scene
        // Present the scene in the view
        skView.presentScene(scene)
        
        // Optional additional configuration
        skView.showsFPS = false
        skView.showsNodeCount = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
