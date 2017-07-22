# This script performs all the text-mining work on abstracts
# and produces the document-term matrix
# it should not be executed. See 3_textmine_postprocess.R
# Fahd Alhazmi, July 21, 2017

rm(list=ls())
library(tm)
library(lsa)
library(R.matlab)

# data directory where all files live

data_dir <- './data'

# import abstracts 

abstracts = read.csv(paste0(data_dir,"/abstracts.csv"),header = FALSE,stringsAsFactors=FALSE)
names(abstracts)<-c("ID","abstract") 

# get rid of abstracts with less than 10 charachters
abstracts<- abstracts[-which(nchar(abstracts[,2])<10),]

# TM starts here  
docs = Corpus(VectorSource(abstracts$abstract))
# show a sample document
# docs[[30]]$content

# function to convert specific characteres to spaces to avoid merging them with other words
tospace <- (function(x, pattern) gsub(pattern, " ", x))

docs = tm_map(docs, content_transformer(tolower))                       # convert all chars to lower-case
docs = tm_map(docs, content_transformer(tospace), '(f|ht)tp\\S+\\s*')   # remove web adresses
docs = tm_map(docs, content_transformer(tospace), "[/\\]")              # convert all useless slashes to spaces.
docs = tm_map(docs, content_transformer(tospace),"\\b[a-zA-Z0-9]{1,2}\\b") # drop 1-2 letter words
docs = tm_map(docs, content_transformer(removeNumbers))                 # remove numbers
docs = tm_map(docs, content_transformer(tospace), "[^[:alnum:]///' ]")  # convert all non-alphabets to spaces
docs = tm_map(docs, content_transformer(tospace), "[']")                # convert ' to spaces

# because we will stem words, words of different meanings will
# be lumped together in one stem; like positive and position
# here, we manipulate those words to get them into different stems

# List of transformed words :
# animate     -> animateate
# animated    -> animateate
# imageability -> imageabilityability
# indices     -> indiceses
# majority    -> majorityity
# modules     -> moduleses # modulate vs modules -
# organism    -> organismism
# position    -> positiones
# positioned  -> positiones
# positioning -> positiones
# positions   -> positiones
# positive    -> positiveive 
# positively  -> positiveive
# positivity  -> positiveive
# relatives   -> relativeses
# subjected   -> subjecteded
# subjective  -> subjecteded
# subjectively  -> subjecteded
# abstractions -> abstractionses
# behaviour   -> behavior
# naïve -> naive
# colour -> color

# use this command for testing:
# tm_map(Corpus(VectorSource(data.frame(text=c("positive positiones"))$text)),stemDocument)$content

custom_trnansformations <- function(x) {
  x<-gsub("(animate|animated)","animateate",x)
  x<-gsub("imageability","imageabilityability",x)
  x<-gsub("indices","indiceses",x)
  x<-gsub("majority","majorityity",x)
  x<-gsub("modules","moduleses",x)
  x<-gsub("organism","organismism",x)
  x<-gsub("(position|positioned|positioning|positions)","positiones",x)
  x<-gsub("(positive|positively|positivity)","positiveive",x)
  x<-gsub("relatives","relativeses",x)
  x<-gsub("(subjected|subjective|subjectively)","subjecteded",x)
  x<-gsub("abstractions","abstractionses",x)
  x<-gsub("behaviour","behavior",x)
  x<-gsub("colour","color",x)
  x<-gsub("naïve","naive",x)
  return(x)
}

docs = tm_map(docs, content_transformer(custom_trnansformations))

load(paste0(data_dir, '/deleted_words.RData'))
docs = tm_map(docs, content_transformer(removeWords), deleted_words)             # remove junk words
docs = tm_map(docs, stemDocument)                             # stem document
docs = tm_map(docs, content_transformer(stripWhitespace))     # stripe white spaces

# show a sample document after processing
# docs[[30]]$content

dtm <- DocumentTermMatrix(docs) # or TermDocumentMatrix
dtm <- removeSparseTerms(dtm,0.9987) # remove words that only appear in *10900*(1-0.9987)* studies. i.e. 15 studies

dtm_raw_matrix <- as.matrix(dtm)

# Now we work with studies
# we will delete all studies of less than 10 words

row.names(dtm_raw_matrix) <- abstracts$ID # for convenience
studies.sum <- rowSums(dtm_raw_matrix)    # calculates number of words in each study
words.sum <- colSums(dtm_raw_matrix)      # calculates number of studies for each word
dtm_raw_matrix <- dtm_raw_matrix[-c(which(studies.sum < 10)),] # remove studies with <10 words

# edit some words that may cause unnecessary pain and existential crisis
# from 'function' to 'function_' 
badwords<- c("break","function","global","repeat","return","switch")
for (w in 1:length(badwords)) {
  colnames(dtm_raw_matrix)[which(badwords[w]==colnames(dtm_raw_matrix))]<-paste0(badwords[w],"_")
}

# save raw document term matrix
writeMat(paste0(data_dir, "/dtm_9987sparsity.mat") ,data=dtm_raw_matrix) # ~ 270MB file

# # save doc ids
# load('./data/stemmed_words_vec_9987.RData')
# write.csv(data.frame(row.names(dtm_raw_matrix)), file='./data/studies_pubmed_list_final.csv')
