# NLP-sentiment-tripadvisor
Data scrape from Tripadvisor and sentiment analysis on the reviews 

In this project data are scraped from TripAdvisor tanks to the work done from Giuseppe Gambino available [here](https://github.com/giuseppegambino/Scraping-TripAdvisor-with-Python-2020) and different analyses of text documents at a word and sentence level are performed. 

The scope of the work is to support Hotel Lac Salin owners in their marketing strategy.

# The github repo contains the following:
- **NLP.R**: this file contains the R script that contains the analysis performed, the code is provided as an R script
- **reviews.csv**: this file contains "Hotel Lac Salin" English reviews scraped from [TripAdvisor](https://www.tripadvisor.com/Hotel_Review-g194799-d529602-Reviews-Lac_Salin_Spa_Mountain_Resort-Livigno_Province_of_Sondrio_Lombardy.html)
- **report.pdf**: this file contains a summary of the work performed and the conclusions that can be drawn from it

# How to run
To run the project, download the files contained in the repo, open "NLP.R" with RStudio and run it, ensure that the enviroment is opened in the right working directory and reviews.csv is present in that directory.

# Libraries to import
- tm
- dplyr
- ggplot2
- wordcloud
- RWeka
- syuzhet
- sentimentr
