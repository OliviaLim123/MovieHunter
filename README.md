# MOVIE HUNTER APPLICATION

Are you ready to dive into the world of movies? Find the best movie to watch with Movie Hunter!

Github link: 

# PREVIEW

https://github.com/user-attachments/assets/37ce7c70-73c6-4867-8da3-ed34485209d6

# MOVIE HUNTER FEATURES

1.	Discover Movies in Real-Time: Stay up to date with the latest now-playing, top-rated, popular, and upcoming categories.
2.	Dive into Movie Details: Uncover comprehensive movie information, including ratings, release year, duration, producers, cast, and even trailers, for an immersive viewing experience.
3.	Smart Search Options: Find your next movie easily by typing a keyword or using the built-in microphone to search with your voice. 
4.	Never Miss a Movie: Add movies to your personalised reminder list to keep track of films you are excited to watch. 
5.	Create Your Own Collection: Add your favourite movies to your personalised movie library, all in one place for quick access.

# SYSTEM EXTENSIONS 

1.	Widget: Displaying top four now playing movies
    https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension/ 
3.	Notification: Notifying the user about scheduled movie reminders
    https://developer.apple.com/documentation/usernotifications 
4.	Safari extension: Navigate to YouTube to watch the movie’s trailer.  
    https://developer.apple.com/safari/extensions/ 

# ERROR HANDLING STRATEGY 

The Movie Hunter application has a MovieError Enum, which defines various types of errors that may occur, each associated with a specific error message. This enum aims to streamline error handling throughout the application by providing descriptive error cases that can be used in guard-let statements. When there is an error, the appropriate case from MovieError is thrown instead of using generic error handling (see Figure below as one example).

<img width="647" alt="Screenshot 2024-10-13 at 8 34 01 am" src="https://github.com/user-attachments/assets/3649d824-494e-4ae9-9973-d8b5afe9a98e">


