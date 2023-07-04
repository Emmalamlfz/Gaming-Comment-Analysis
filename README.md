# Genshin-Impact-Comment-Analysis
School Project--Operation Optimization with a Dive into Genshin Impact’s Comment

[Final Report/Deliverable](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/blob/main/Genshin%20Impact.pdf)

 ## Table of content:
   
 [1. Business Problem Statement](#item-one)
 
 [2. Business & Technical Objectives](#item-two)
 
 [3. Technical Objectives](#item-three)

 [4. Stakeholder Strategy](#item-four)

 [5. Project Design](#item-five)

 [6. Data Set](#item-six)

<a id="item-one"></a>
## 1. Business Problem Statement
Genshin Impact, a prevailing open-word action role-playing game launched in Sep 2020, has
recently reached its second anniversary. It was awarded Best Mobile Game in 2021 and remains
on the list of top-grossing mobile games worldwide since its launch (2020-2022).

As the player pool grows larger, the number and the variety of comments in the application stores
also grow larger. As popular as it is today, a potential reputation drop would be costly. And
meanwhile, for the two developing new games with similar target players, what might be the
alerts, and what can be referenced?

 <a id="item-two"></a>
## 2. Business & Technical Objectives
### Business Objectives
* To deal with the growing variety in comments, the operation team wants to update the autoreply corpus. To design new automatic replies, the distribution of sentiment and topics are requested.
* What is complained by the players, and what is appreciated? In knowing these, improvements can be made for Genshin Impact and the appreciated features can be referenced by the two developing games.
* In preventing a reputation crisis, the operation team wants to detect what is the timing to take some maintenance actions in advance.

 <a id="item-three"></a>
## 3. Technical Objectives
* Conduct sentiment analysis and LDA over the comments to know the sentiment and topic distribution.
* Develop a classification model that served as a pre-warning model to decide whether the comments are showing an alert so that actions need to be taken to appease the players.
* Through word cloud analysis and LDA on focused groups of comments, to find out what is doing bad for refinement, and what is doing good for the new games' reference.

<a id="item-four"></a>
## 4. Stakeholder Strategy

![image](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/3b696aa3-b233-4916-82cd-43d7420b5f44)

<a id="item-five"></a>
## 5. Project Design
###  Data Management
In terms of data management for this project, we initially extracted Genshin’s comments, game performance data and industry data from various external sources. Before loading the data-todata warehouse, we conducted data validation, cleaning, transformation and integration, including dealing with data inconsistency, removing duplication and outliers, imputing missing values as needed, and deriving new variables. In the process of analysis, we selected valuable features from the warehouse and took advantage of BI tools to derive insights.

![Figure 1. Process of data management](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/f4604ca3-c2ab-4230-8428-1e0b997fa14b)

### Analytical Pathway

![Figure 2. Analytical pathway](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/afbcd622-3d5c-4a72-b086-b64c25094929)

<a id="item-six"></a>
## 6. Data Set
### Players’ Comments from Google Play Store
Our data was crawled from the Google Play store. Originally, there are 8 variables, which include both numerical and categorical variables: “reviewID”, “content”, “score”, “thumbsUpCount”,
“reviewCreatedVersion”, “at”, “replyContent”, “repliedAt”. We newly created 7 additional variables: “Polarity”, “subjectivity”, “ABS”, “attitude”, “review_length”, “usefulness”, “days of
comment”. In total, we have 15 variables (See Appendix 1).
There are 1273 observations in the dataset. We also have 642 fresh comments dated after 14 Oct as our deployment dataset. When building the classification model, we used 70% of historical data as the training set and 30% as the testing set.

### Google Trends
We crawled weekly google impact data from the official website of google trends for Genshin from September 2020 to October 2022. There are 2 variables “week” and “google impact”. We use this data to compute the time series analysis and prediction (See Appendix 2) .

###  Performance Data of Genshin Impact
On the other hand, we scrabbled some variables to find whether they have correlation with the performance of the Genshin Impact, which includes numerical variables: "App_revenue", "app_downloads", "Avg_google_impact", "Num_hours_watched_Twitch", and "Average_Monthly_Players", and "google_impact"(See Appendix 3).

## Data Preparation
### Data Cleaning
* missing data (version number is missing for some comments)
* data dislocation
* emoji in the comments
* duplications

### Data Construction
**ABS**

In the score of reviews, high-scoring reviews are as important as low-scoring reviews, because they will reflect the player's attitude towards the game. Therefore, we define the deviation degree of each score from the mean by constructing ABS index, to judge the extreme degree of score. The specific equation is as follows:

$$ABS =  |score − mean score|$$

**Days of comment**

The difference between the date the review was published and the crawler date can reflect the time variable, which is conducive to studying the relationship between the number of days the review was published and the number of likes.

**Usefulness**

For the operation team, useful reviews have practical value for decision-making, so it is necessary to judge the usefulness of reviews. We set the quartile (6) of the historical data as the threshold,
and when the thumbs up number of the review is bigger than 6, the review is regarded as useful (1), otherwise it is regarded as useless (0)

**Polarity**

Quantify the sentiment of reviews from negative to positive. The range of Polarity attribute is
from –1(extremely negative) to 1(extremely positive).

**Subjectivity**

Quantify “private states” (opinions, emotions, sentiments, beliefs, speculations) from the reviews, range from 0 to 1.

**Review_length**

The total length of the reviews was calculated based on the number of words.

**Attitude**

In preventing the player attitude decline, we constructed an indicator as the base measure of the pre-warning model for operation team to detect when to take maintenance actions in advance.
We leveraged score and sentiment polarity to construct player attitude from comments, giving weights of 0.3 and 0.7 separately. The range for attitude is from -0.4 to 2.2.

 $$𝐴𝑡𝑡𝑖𝑡𝑢𝑑𝑒 = 0.3 ∗ 𝑆𝑐𝑜𝑟𝑒 + 0.7 ∗ 𝑃𝑜𝑙𝑎𝑟𝑖𝑡𝑦$$

![image](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/2a80bbf1-915d-432e-bf7f-9698624cf9a6)

![image](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/01ea1538-2968-4946-bd06-7a305d84dd56)

We took polarity into account because there were cases where the review is with a high score but negative sentiment, suggesting the inconsistency of score and sentiment polarity. So, the
score alone may not truly represent the reviewer’s attitude. Hence it is essential to consider the sentiment polarity when constructing the attitude.

![image](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/7143cfd6-8831-4564-ab51-b87bef20a642)

Secondly, we focus more on negative or low-score reviews from players since they reflect the attitude drop lie in players which may ultimately lead to a reputation drop. Among all useful
comments (number of thumbs > 6) in our data set, if we group them by score, there are 59% low/medium comments. If we group them by polarity, there are 79% negative/neutral comments.
So, clearly, polarity captured more comments of our interest. Therefore, we give polarity more weight than score. By giving more weight to polarity, the indicator will be more sensitive to
negative and neutral polarity therefore effectively capturing the attitude drop. This is in line with the concern of the operation team.

![image](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/4de2324f-5f35-4266-8bed-ce9b63391a55)

## 7.Objective 1: Update the Auto-Reply Corpus
### 7.1 Topic Modeling – LDA
First, data pre-processing was conducted for LDA. During the data pre-processing, we also derived additional comment-based stop words which have high frequency but play trifling roles in defining the topics.
![image](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/54129219-4e36-4552-802c-61eeb4c87c17)

Considering both model performance and contextual information about the game, we came up with an acceptable model (chunk size = 4, passes = 10, UMass coherence = -2.5639, CV coherence = 0.4093) displaying four topics.

![image](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/c2cd05b9-5568-4550-8193-547953556759)
![image](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/8e1b4e62-9c56-4d1d-bebf-0067e72977ce)

Summarizing the most relevant terms, we named the four topics.

![image](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/413e8d7d-bbfa-4e56-92f9-69f4c701574c)

The first topic, which covers the greatest proportion of tokens, is about the story design. The related comments show appreciation to the story design where characters are elaborately involved.

The second topic is about the technical problems encountered when playing the game on mobile devices. The main problems include: the game is occupying too much storage, the controller sometimes does not work as smoothly as expected, or there are some bugs reported.
The third topic is about the Graphic. The game is excellent in its Graphic of both the world and the characters. Each update brings a surprise. The fourth topic is about character design. Besides an amazing look and well-designed outfit, the motions of the characters, especially the effects during the fighting, are highly appraised.

![image](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/5e374a5d-d524-4f7e-a4b1-d7032d00a9be)

Among all the comments, topics about Graphic and story design occupy a lion’s share. Next follows the character design and technical problems. Therefore, we suggested the operation team redesign the auto-reply corpus into such a distribution of topics.

### 7.2 Distribution of Sentiment (Polarity)
Besides topic, sentiment distribution, especially polarity, is also a crucial factor to consider. Within the range from -1 to 1, we divided the polarity of sentiment into 4 parts: strong negative, moderate negative, moderate positive and strong positive, with -0.5, 0 and 0.5 as the separations.

![Figure 9. Sentiment (Polarity) distribution](https://github.com/Emmalamlfz/Genshin-Impact-Comment-Analysis/assets/110097027/dab9d069-3231-432d-ae70-5de9a97923a8)

Following a relative normal distribution, there are 55% positive comments, and 45% negative comments. In re-designing the autoreply corpus, such a sentiment distribution can also serve as a guide for the operation team.








