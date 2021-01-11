#Open R, click file, open script, and select this script
#in the script window, you can either select edit > run all
#to run this entire script,
#or you can step through it by highlight each bit of code between comments and hitting ctrl+R

#Libraries
#in case the library are not already installed run "install.package('name_of_the_library')
library(tm)#dealing with text
library(dplyr)#dataframe manipulation
library(ggplot2)#for plotting
library(scales)#for scaling 
library(wordcloud)#wordcloud
library(RWeka)#for bigrams
library(syuzhet)#for sentiment analysis1
library(sentimentr)# for sentiment analysis 2



#Read file
#be sure that path points to the directory that contains the dataset, 
#in the case the project was downloaded from Github it should be ".../NLP-sentiment-tripadvisor
path<-getwd()
setwd(path)
df=read.csv("reviews.csv",header=FALSE, col.names = c("Date", "V2", "Title", "review"))
str(df)

#Build Corpus
corpus <- iconv(df$review)
corpus <- Corpus(VectorSource(corpus))
inspect(corpus[1:5])

#Define stopwords
myStopwords = c(stopwords(kind = "en"),"also","lac","salin","...")

#Term document matrix
tdm <- TermDocumentMatrix(corpus)
tdm
tdm <- as.matrix(tdm)
tdm[1:10, 1:30]

#checking zipfs law
freq=rowSums(tdm)
head(freq,10)
plot(sort(freq, decreasing = T),col="blue",main="Word frequencies", xlab="Frequency-based rank", ylab = "Frequency")

#Plotting the log-frequency against log-rank should follow, according to Zipf’s Law, an inverse line with a slope of -1. 
Zipf_plot(tdm, "l")

#Clean text
corpus<-tm_map(corpus, tolower)
corpus<-tm_map(corpus, removePunctuation)
corpus<-tm_map(corpus, stripWhitespace)
corpus<-tm_map(corpus, removeNumbers)
cleanset<-tm_map(corpus, removeWords, myStopwords)
inspect(cleanset[1:3])

#Fixing plural of some recurrent words
cleanset <- tm_map(cleanset, gsub, 
                          pattern = 'waitresses', 
                          replacement = 'weiters')
cleanset <- tm_map(cleanset, gsub, 
                          pattern = 'restaurants', 
                          replacement = 'restaurant')
cleanset <- tm_map(cleanset, gsub, 
                          pattern = 'rooms', 
                          replacement = 'room')


#Term document matrix
tdm <- TermDocumentMatrix(cleanset)
tdm
tdm <- as.matrix(tdm)
tdm[1:10, 1:30]

#Bar Plot
w <- rowSums(tdm)
w <- subset(w, w>=25)
barplot(w,
        las = 2,
        col = rainbow(50))

#Word cloud
v <- sort(rowSums(tdm),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)

set.seed(2222)
wordcloud(words = d$word, freq = d$freq, min.freq = 10,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))


###BIGRAMS###

#Build Corpus
corpus.ngrams <- iconv(df$review)
corpus.ngrams = VCorpus(VectorSource(corpus.ngrams))

##Clean text
corpus.ngrams<-tm_map(corpus.ngrams, tolower)
corpus.ngrams<-tm_map(corpus.ngrams, removePunctuation)
corpus.ngrams<-tm_map(corpus.ngrams, stripWhitespace)
corpus.ngrams<-tm_map(corpus.ngrams, removeNumbers)
cleanset.ngrams<-tm_map(corpus.ngrams, removeWords, myStopwords)

cleanset.ngrams <- tm_map(cleanset.ngrams, gsub, 
                          pattern = 'waitresses', 
                          replacement = 'weiters')
cleanset.ngrams <- tm_map(cleanset.ngrams, gsub, 
                          pattern = 'restaurants', 
                          replacement = 'restaurant')
cleanset.ngrams <- tm_map(cleanset.ngrams, gsub, 
                          pattern = 'rooms', 
                          replacement = 'room')
cleanset.ngrams <- tm_map(cleanset.ngrams, PlainTextDocument)

#n-gram tokenizer to create a TDM that uses as terms the bigrams that appear in the corpus.
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
tdm.bigram = TermDocumentMatrix(cleanset.ngrams,
                                control = list (tokenize = BigramTokenizer))

#extract the frequency of each bigram and analyse the twenty most frequent ones.
freq = sort(rowSums(as.matrix(tdm.bigram)),decreasing = TRUE)
freq.df = data.frame(word=names(freq), freq=freq)
head(freq.df, 20)

#bigram wordcloud
wordcloud(words = freq.df$word,
          freq = freq.df$freq,
          random.order = F,
          colors=brewer.pal(8, "Dark2"),
          max.words=100,
          scale=c(2,.5)
)
#frequencies horizontal plot
ggplot(head(freq.df,15), aes(reorder(word,freq), freq)) +   
  geom_bar(stat="identity") + coord_flip() + 
  xlab("Bigrams") + ylab("Frequency") +
  ggtitle("Most frequent bigrams")


###SENTIMENT ANALYSIS###
df=read.csv("reviews.csv",header=FALSE, col.names = c("Date", "V2", "Title", "review"))
sentiment <- iconv(df$review)

#Obtain sentiment scores->Syhouze
s<-get_nrc_sentiment(sentiment)
s[1:10,]
s$score<-s$positive-s$negative
s[1:10,9:11]

#Bar plot
barplot(colSums(s),
        las = 2,
        col = rainbow(10),
        ylab = 'Count',
        main = ' Hotel Lac Salin sentiment scores')


#Obtain sentiment score->sentimentr
sentiment=sentiment_by(df$review)
summary(sentiment$ave_sentiment)
qplot(sentiment$ave_sentiment,   geom="histogram",binwidth=0.1,main="Review Sentiment Histogram")

#add to the dataframe for further invesitgations
df$ave_sentiment=sentiment$ave_sentiment
df$sd_sentiment=sentiment$sd


######END######


#TrigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))
#tdm.trigram = TermDocumentMatrix(cleanset.ngrams,
                                # control = list(tokenize = TrigramTokenizer))


#freq = sort(rowSums(as.matrix(tdm.trigram)),decreasing = TRUE)
#freq.df = data.frame(word=names(freq), freq=freq)
#head(freq.df, 20)


#wordcloud(words = freq.df$word,
 #         freq = freq.df$freq,
 #         random.order = F,
 #         colors=brewer.pal(8, "Dark2"),
 #         max.words=100,
 #         scale=c(1,.5)
#)

