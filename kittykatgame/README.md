# SUMMER PROJECT COMPLETE


## GOAL
My goal for this summer was to recreate Diner Dash inside the span of a Summer while also working full time. 
I had an end goal in mind and knew what I was working towards generally but there were a lot of factors in play this Summer


## DILEMMAS

### SCOPE-CREEP
The most common problem one encounters when making a game is scope-creep I imagine. You constantly have these grand and exciting ideas with no plans on how, just knowing it sounds cool. 
I was CONSTANTLY catching my self re-iterating on concepts I had already decided on weeks ago. 
This led to a lot of burnout and killed a lot of momentum I had. But eventually I had an end product in mind and forced myself to stick with it

### POOR PROGRAMMING DESIGN PATTERNS
Another issue I ran into was the fact I was learning while I was programming. 
For example, at the beginning of the project, I had no concept of the Publish-Subscribe design pattern that Godot relies on heavily, but by the end of the project I kept realizing how much harder I was making things by not utilizing this design structure

Additionally, I created a lot of things without utilizing either inheritance or composition to its full potential. 
To a lesser extent, I did not use composition, but due to Godot's Node system, composition was more or less 'forced' to be used(not that this is a bad thing, just that one is faced with the need to use the design method to use Godot well -- if at all)


### POOR PROGRAMMING IN GENERAL
A lot of this code is just purely sloppy and awful. 
I am not happy with it as I am generally a perfectionist, but I had a deadline in mind, so beauty was not something I had the liberty of appreciating this Summer. 
I met my main goal, so now I can focus on cleaning up the product in a semi-legible way (just look at my file structure :cold_sweat: :finnadie:)

### FOCUSING TOO MUCH ON BUGS
This may seem strange, but I learned to just walk away from bugs if I knew generally what was causing the bug and generally what avoided the bug as I had to learn the logic "If it works and looks stupid, it still works" more or less. 
I knew I could come back to the bugs instead of focusing all energy on something before I even had a working product. 
This is a problem I've had in the past and this is the biggest cause of my programming burnout I believe so this was strangely rewarding to overcome

### BALANCING WORK (AND SANITY)
This one was also difficult as given the scope of the game, and my limited free time, I knew I was going to be under a time crunch but I also enjoyed what I did.
It still was difficult hearing my Steam library calling out to me ;(, beckoning me to play just a little!!!! But I knew I had a goal in mind and it was an important goal. 


### LIMITED RESOURCES
There aren't many "tutorials" on making Diner Dash in Godot (in fact, there are none, I checked).
I had to be creative and resourceful in coming up with solutions. 
For example, clicking and dragging the customers to a table is very similar to a drag and drop feature, so I researched how one could implement a drag and drop feature in Godot and modified it to mimic the logic of how Diner Dash handles gameplay.
Other times, I didn't even have that luxury and had to try to come up with solutions myself--I became VERY familiar with Godot's documentation during this project--learning how different things interact in Godot.
Sometimes I even watched gameplay videos repeatedly in an attempt to reverse-engineer a gameplay concept programmatically.

### HONORABLE MENTIONS
I additionally recognized how difficult inheritance and composition can be at times. Sometimes it's obvious (all enemies have health, so of course they would be composed of a health object).
However, sometimes it is difficult rationalizing whether an attribute should belong to object "x" or object "y". 
For example, in the context of this project I couldn't decide whether the party of customers, or the table object (or some third party object like a signal bus) should keep track of things(e.g. waiting time, current state, orders, table number, etc.). 
One issue I encountered here is that I designed it with the party keeping track of this, but after having a lot of this programmed, I realized it made more sense to be a part of the table (e.g. everytime a customer party leaves you can just "clear" the receipt so to speak and start fresh) but with help from a signal bus keeping track of things overall, this helps reduce memory fragmentation since there can be any number of customers in the restaurant but only one party is seated at a given table. 
If I were to do this project over again (spoiler alert, I am), this is one design decision I would change
This is just one example of the ways this project helped reinforce my understanding of these concepts.

## TAKEAWAYS

Ultimately, I achieved my end-goal of recreating diner dash. It looks terrible, it's a buggy mess, it barely functions as a "game" but it works and meets my requirements.  
As someone working full-time on top of this 3-month time frame, I believe this is a good outcome. I have learned alot from this project and am proud of this piece of crap haha.

## WHAT'S NEXT?

My goal, now, is to utilize what I learned and to rebuild the game from scratch utilizing the design patterns I have picked up during this project and have a more proper and maintainable product. 
Since this three-month period was purely a test of my ability, I don't have a specific release timeline in mind for this game, but I hope to release it eventually (once school starts, the pace will slow, but the vision’s still there). 




# WANT SOME BULLET POINTS YOU TL;DR NERDS? (I CERTAINLY WOULD)
- Learned the importance of design patterns such as the **Publish-Subscribe** pattern, and reinforced the importance of other structures like **inheritance** and **composition**
	- These were heavily reinforced through Godot naturally emphasizing all three of these in its engine design. 
- Practiced **rapid prototyping** as well as **scope management**
- Managed to (mostly) avoid things like **burnout** and **scope creep**
	- Managed to generally stick to my goal to finish my project in time
- Balanced this project with a full-time job	
- Ultimately gained the understanding of how to ship a functional prototype, warts and all
