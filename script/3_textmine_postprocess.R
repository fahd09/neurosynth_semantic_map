# This script does all the post text-mining work on abstracts
# like generating words lists and exploring frequences etc
# Fahd Alhazmi, 12/17/15 

script_dir <- './script/'
data_dir <- './data/'
# This will take a while to excute (+1 minute on my Macbook)
source(paste0(script_dir, '2_textmine_preprocess.R') )
# dim(dtm_raw_matrix)


# Write the list of words to external file
stemmed_words_vec_9987<- colnames(dtm_raw_matrix)
stemmed_words_sorted <- sort(stemmed_words_vec_9987)
write(stemmed_words_sorted, file=paste0(data_dir, "/stemmed_words_list.txt"))

# also save in RData file
save(stemmed_words_vec_9987,file=paste0(data_dir, "/stemmed_words_vec_9987.RData") )
#writeMat(paste0(data_dir, "/stemmed_words_vec_9987.mat") , data=stemmed_words_vec_9987)

# explore term frequencies
freq.term<- colSums(dtm_raw_matrix)
freq.study<- rowSums(dtm_raw_matrix)
freqsorted<-sort(freq.term)

# summary(freqsorted)

# lower/top 10 words
#as.data.frame(freqsorted[1:10])
#as.data.frame(freqsorted[length(freqsorted)- (9:0)]) 

# All words sorted by number of letters, then by alphabet
ord<-order(nchar(names(freqsorted)),names(freqsorted))
sorted_stemmed_words_9987<- data.frame(word=names(freqsorted[ord]),length=nchar(names(freqsorted[ord])))
write.table(sorted_stemmed_words_9987, 
            file=paste0(data_dir, "/sorted_stemmed_words.csv"), sep = ',',
            row.names = FALSE, col.names = TRUE)

# Similar words
sorted_words_stem<-names(freqsorted[order(nchar(names(freqsorted)),names(freqsorted))])
# finding similar words
lex<-data.frame()
for (word in 1:length(sorted_words_stem)){
  similars <- agrep(sorted_words_stem[word],sorted_words_stem, max.distance=0)
  lex[word,1]<- sorted_words_stem[word]
  lex[word,2]<- length(sorted_words_stem[similars])
  lex[word,3]<- paste(sorted_words_stem[similars],collapse=" ")
}
names(lex)<-c("root","length_leafs","leafs")

# show similar words of length 4
# lex[lex$length_leafs==4,c(1,3)] 

write.table(lex, 
            file=paste0(data_dir, "/similar_words.csv"), sep = ',',
            row.names = FALSE, col.names = TRUE)


# Now map stemmed words to their original form

load(paste0(data_dir, '/stemmed_words_vec_9987.RData') )
roots<-stemmed_words_vec_9987 # sorted_words_stem
load(paste0(data_dir, '/full_words_vec_9987.RData') )
stem_full <- data.frame()
rot<- tm_map(Corpus(VectorSource(data.frame(words=full_words_vec_9987)$words)), stemDocument)$content
full_to_stem <- data.frame(orginal=full_words_vec_9987, stemmed=rot)
for (w in 1:length(roots)) {
  stem_full[w,1]<- roots[w]
  stem_full[w,2]<- paste0(full_to_stem$orginal[full_to_stem$stemmed == roots[w]], collapse = ', ')
}
names(stem_full)<-c("stem","words")
#head(stem_full,10)
write.table(stem_full, 
            file=paste0(data_dir, "/stem_to_full_mapping.csv"), sep = ',',
            row.names = FALSE, col.names = TRUE)

# note that there are some "stems" that don't have corresponding original form
# but this is due to using slightly different word set 
# that contain most stem words, but not all






library(ggplot2)

g<-ggplot(data=data.frame(wordsfq = as.vector(freq.term))) + 
  geom_density(aes(log10(wordsfq))) +
  labs(x="Log_10(Word Frequencies)",y="Density",
       title="Density of Word Frequency") +
  theme_classic()
ggsave('./plots/words_freq.png', g)

g<-ggplot(data=data.frame(wordsfq = as.vector(freq.study))) + 
  stat_qq(aes(sample= wordsfq)) +
  labs(title="QQ-Plot for studies Frequencies") +
  theme_classic()
ggsave('./plots/studies_freq.png', g)


