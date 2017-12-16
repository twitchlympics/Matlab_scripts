# Matlab_scripts


With this project wer try to recreate and model the distribution of viewers across different channels on the online streaming platform "Twitch"

to measure how compatible a streamer and a viewer are, we allocate a certain number 
of random attributes to each viewer and streamer and then use a vectorproduct to determine compatibility.
The larger the vector product, the more compatible a pair of viewers and streamers are.
Each viewer will watch the streamer with witch he shares the highest vector product.

Of course there are streamers with different levels of overall quality.
for example: there might a few very high quality channels and a lot of average ones and some very low quality streamers.
vice versa the dedication of viewer is also not constant among a population.
some viewers may watch their highest compatibility chanel no matter what, 
while others require a certain level of compatibility(satisfaction) to be watching at all.

We simulate these differences among the population if both streamers and viewers by simply not norming the attribute vector.
This results in the sum of all attributes for a streamer also beaing his quality while the sum of all the attributes of a 
certain viewer represent his overall dedication.

this results int the viewership distribution being a very good approximation of actual viewership. (the higher the number of attributes is, the better is the distribution)
e.g.: if we only use one attribute, the streamer with the highest quality will get all the views. 

(we assume a normal distribution for quality and dedication)

This function is already implemented in the code.
from here on we would like to extend this function to not only represent a static timestep, but also the dynamic system, that exists in reality.
(viewers coming and going, streamers going online or offline and so on.)
