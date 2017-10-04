SpriteKit Sample Game
==============
Source: "Learn Sprite Kit for iOS Game Development" By Leland Long

#Demo
![alt tag](https://github.com/fbroom/SpriteKitGame/blob/master/demo.gif)


#Chapters
* [x] Chapter 1: Hello World


* [x] Chapter 2: SKActions and SKTexture: Your First Animated Sprite
 * [x] Created a new Game Scene that will get created after the initial Splash Screen
 * [x] Created an animated sprite for the main player using SKTextures and SKAction


* [x] Chapter 3: Sprite Movement with User Input
 * [x] Created a new class for the main player
 * [x] Handled movement of the player (left and right) in touchesBeganWithEvent
 * [x] Moved all textures into a new Class Textures to handle creating animated textures
 * [x] Added additional animations for the sprite when it stops after running left or right


* [x] Chapter 4: Edges, Boundaries, and Ledges
 * [x] Added a physics body to our player and defined its properties (density, linear damping and restitution)
 * [x] Used categoryBitMask and contactTestBitMask to handle collisions of the player with the edges
 * [x] Added a new brick base
 * [x] Added a new jump event to the player in touchesBeganWithEvent
 * [x] Added new ledges for the player to walk and jump on


* [x] Chapter 5: More Animated Sprites: Enemies and Bonuses
 * [x] Added new enemy Ratz class
 * [x] Added new bonus Coin class
 * [x] Handled collisions between Ratz, Coins and Ratz<>Coins


* [x] Chapter 6: Creating a Cast of Characters
 * [x] Modified the spawning process of enemies and coins to use a plist file


* [x] Chapter 7: Points and Scoring
 * [x] Added scoring
 * [x] Added sounds


* [x] Chapter 8: Contacts and Collisions
 * [x] Added pipes and holes for enemies and coins to go through
 * [x] Checking for enemies and coins getting stuck in the method update
 * [x] Added player and coin contact event to collect coin and update score
 * [x] Added particle effects
 * [x] Let player collect coins from below the ledges using intersectsNode
 * [x] Let player hit enemies from below the ledges
 * [x] Add spark particle effect for when enemies are collected
 * [x] Player gets killed when there is a contact between enemy and player


* [x] Chapter 9: Adding More Scenes and Levels
 * [x] Player has more lives if player dies
 * [x] Game over implemented
 * [x] Save and show high scores
 * [x] Added more levels

