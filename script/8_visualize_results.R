rm(list=ls())

library(R.matlab)
library(plyr)
library(ggplot2)
library(reshape2)
library(wordcloud)

#######################
# initialize variables
#######################

data_dir <- './data'

FiFj <- readMat(paste0(data_dir, '/FiFjLambda_20comps_fulltau_lambda.mat'))
Fis <- data.frame(FiFj$Fi20[,1:5])
names(Fis) <- c("V1","V2","V3", "V4", "V5")
Fjs <- data.frame(FiFj$Fj20[,1:5])
names(Fjs) <- c("V1","V2","V3", "V4", "V5")


FiAssign<-read.csv(paste0(data_dir, '/studies_clusters_binarized.csv') ,header = T)
FiAssign<- FiAssign[,-1] # delete first column
FiAssign<- apply(FiAssign,1, function(x) which(x==1))
FiAssign<-as.factor(FiAssign)
#FiAssign<-as.factor(paste0("Cluster ", FiAssign))


FjAssign<-read.csv(paste0(data_dir, '/words_clusters_binarized.csv') ,header = T)
FjAssign<- FjAssign[,-1] # delete first column
FjAssign<- apply(FjAssign,1, function(x) which(x==1))
FjAssign<-as.factor(FjAssign)
#FjAssign<-as.factor(paste0("Cluster ", FjAssign))

# load studies and words..
stemmed_words_vec_9987 <- read.table(file=paste0(data_dir, '/stemmed_words_list.txt'))
stemmed_words_vec_9987 <- as.character(stemmed_words_vec_9987$V1)
pmids <- read.csv(paste0(data_dir, '/studies_metadata.csv'))
pmids <- pmids[,-c(1)] # delete the index column that starts from 0

load(paste0(data_dir, '/stemmed_words_freq_table.RData'))

Fjs_words <- cbind(word=stemmed_words_vec_9987, FjAssign, freq=freq.df$freq, Fjs)
Fis_studies <- cbind(pmids, Fis, FiAssign)

# add ggplot default colors to fi_studies and fj_words table and save to results
library(scales)
colors <- hue_pal()(6)
Fis_studies$color <- colors[Fis_studies$FiAssign]
Fjs_words$color <- colors[Fjs_words$FjAssign]
write.csv(Fis_studies, file = './results/studies_matrix.csv', row.names = FALSE)
write.csv(Fjs_words, file = './results/words_matrix.csv', row.names = FALSE)

clust_evals <- read.csv(paste0(data_dir, '/clustering_eval_results.csv'))

#######################
# visualziations
#######################

# studies (Fis)

# 1 vs 2
chulls <- ddply(Fis_studies, .(FiAssign), function(df) df[chull(df$V1, df$V2), ])
g<- ggplot(data=Fis,
           aes(x=V1,
               y=V2,
               color=FiAssign
           )) +
  geom_vline(xintercept = 0)+
  geom_hline(yintercept = 0)+
  geom_point(aes(color=FiAssign), size=1, alpha=.3) +
  labs(color="Assignments") +
  #geom_polygon(data=chulls, aes(x=V1, y=V2, group=FiAssign), fill=NA, size=1)+
  #geom_point(size=2, alpha= .2) +
  ggtitle("Studies' Component Scores: 1 vs. 2")+
  xlab("Component 1: 0.42%, \u03BB = 0.25") + 
  ylab("Component 2: 0.35%, \u03BB = 0.20") +
  #scale_colour_hue() +
  #scale_colour_brewer(palette = "Set1") + #
  theme_bw()

#Accent, Dark2, Paired, Pastel1, Pastel2, Set1, Set2, Set3
print(g)

ggsave("./plots/studies_1vs2.png",g)

# 1 vs 3
chulls <- ddply(Fis_studies, .(FiAssign), function(df) df[chull(df$V1, df$V3), ])
g<- ggplot(data=Fis,
           aes(x=V1,
               y=V3,
               color=FiAssign
           )) +
  geom_vline(xintercept = 0)+
  geom_hline(yintercept = 0)+
  geom_point(aes(color=FiAssign), size=1, alpha=0.3) +
  labs(color="Assignments") +
  #geom_polygon(data=chulls, aes(x=V1, y=V3, group=FiAssign), fill=NA, size=1)+
  #geom_point(size=2, alpha= .2) +
  ggtitle("Studies' Component Scores: 1 vs. 3")+
  xlab("Component 1: 0.42%, \u03BB = 0.25") + 
  ylab("Component 3: 0.31%, \u03BB = 0.18") +
  theme_bw()
print(g)

ggsave("./plots/studies_color_1vs3.png",g)

# 4 vs 5
chulls <- ddply(Fis_studies, .(FiAssign), function(df) df[chull(df$V4, df$V5), ])
g<- ggplot(data=Fis,
           aes(x=V4,
               y=V5,
               color=FiAssign
           )) +
  geom_vline(xintercept = 0)+
  geom_hline(yintercept = 0)+
  geom_point(aes(color=FiAssign), size=1, alpha=0.3) +
  labs(color="Assignments") +
  #geom_polygon(data=chulls, aes(x=V4, y=V5, group=FiAssign), fill=NA, size=1)+
  #geom_point(size=2, alpha= .2) +
  ggtitle("Studies' Component Scores: 4 vs. 5")+
  xlab("Component 4: 0.26%, \u03BB = 0.15") + 
  ylab("Component 5: 0.25%, \u03BB = 0.15") +
  theme_bw()

print(g)

ggsave("./plots/studies_color_4vs5.png",g)


# Words 

# 1 vs 2
chulls <- ddply(Fjs_words, .(FjAssign), function(df) df[chull(df$V1, df$V2), ])
g<- ggplot(data=Fjs_words,
           aes(x=V1,
               y=V2,
               color=FjAssign
           )) +
  geom_vline(xintercept = 0, alpha=.5)+
  geom_hline(yintercept = 0, alpha=.5)+
  geom_point(aes(color=FjAssign), size=1, alpha=0.3) +
  labs(color="Assignments") +
  #geom_polygon(data=chulls, aes(x=V1, y=V2, group=FjAssign), fill=NA, size=1)+
  #geom_point(size=2, alpha= .2) +
  ggtitle("Words' Component Scores: 1 vs. 2")+
  xlab("Component 1: 0.42%, \u03BB = 0.25") + 
  ylab("Component 2: 0.35%, \u03BB = 0.20") +
  theme_bw()

print(g)


ggsave("./plots/words_color_1vs2.png",g)

# 1 vs 3
chulls <- ddply(Fjs_words, .(FjAssign), function(df) df[chull(df$V1, df$V3), ])
g<- ggplot(data=Fjs,
           aes(x=V1,
               y=V3,
               color=FjAssign
           )) +
  geom_vline(xintercept = 0)+
  geom_hline(yintercept = 0)+
  geom_point(aes(color=FjAssign), size=1, alpha=0.3) +
  labs(color="Assignments") +
  #geom_polygon(data=chulls, aes(x=V1, y=V3, group=FjAssign), fill=NA, size=1)+
  #geom_point(size=2, alpha= .2) +
  ggtitle("Words' Component Scores: 1 vs. 3")+
  xlab("Component 1: 0.42%, \u03BB = 0.25") + 
  ylab("Component 3: 0.31%, \u03BB = 0.18") +
  theme_bw()
print(g)

ggsave("./plots/words_color_1vs3.png",g)

# 4 vs 5
chulls <- ddply(Fjs_words, .(FjAssign), function(df) df[chull(df$V4, df$V5), ])
g<- ggplot(data=Fjs,
           aes(x=V4,
               y=V5,
               color=FjAssign
           )) +
  geom_vline(xintercept = 0)+
  geom_hline(yintercept = 0)+
  geom_point(aes(color=FjAssign), size=1, alpha=0.3) +
  labs(color="Assignments") +
  #geom_polygon(data=chulls, aes(x=V4, y=V5, group=FjAssign), fill=NA, size=1)+
  #geom_point(size=2, alpha= .2) +
  ggtitle("Words' Component Scores: 4 vs. 5")+
  xlab("Component 4: 0.26%, \u03BB = 0.15") + 
  ylab("Component 5: 0.25%, \u03BB = 0.15") +
  theme_bw()

print(g)
ggsave("./plots/words_color_4vs5.png",g)

# Comp1 Positive Extreme Words

pos.inds <- order(Fjs_words$V1, decreasing = T)[1:20]
paste0(as.character(Fjs_words$word[pos.inds]), collapse = ', ')
neg.inds <- order(Fjs_words$V1)[1:20]
paste0(as.character(Fjs_words$word[neg.inds]), collapse = ', ')

# Comp2 Positive Extreme Words

pos.inds <- order(Fjs_words$V2, decreasing = T)[1:20]
paste0(as.character(Fjs_words$word[pos.inds]), collapse = ', ')
neg.inds <- order(Fjs_words$V2)[1:20]
paste0(as.character(Fjs_words$word[neg.inds]), collapse = ', ')

# Comp3 Positive Extreme Words

pos.inds <- order(Fjs_words$V3, decreasing = T)[1:20]
paste0(as.character(Fjs_words$word[pos.inds]), collapse = ', ')
neg.inds <- order(Fjs_words$V3)[1:20]
paste0(as.character(Fjs_words$word[neg.inds]), collapse = ', ')

# Comp 4

pos.inds <- order(Fjs_words$V4, decreasing = T)[1:20]
paste0(as.character(Fjs_words$word[pos.inds]), collapse = ', ')
neg.inds <- order(Fjs_words$V4)[1:20]
paste0(as.character(Fjs_words$word[neg.inds]), collapse = ', ')

# comp 5

pos.inds <- order(Fjs_words$V5, decreasing = T)[1:20]
paste0(as.character(Fjs_words$word[pos.inds]), collapse = ', ')
neg.inds <- order(Fjs_words$V5)[1:20]
paste0(as.character(Fjs_words$word[neg.inds]), collapse = ', ')


# Studies
# Comp1 Positive Extreme Studies

pos.inds <- order(Fis_studies$V1, decreasing = T)[1:20]
cat(as.character(Fis_studies$pubmed[pos.inds]), sep = ', ')
neg.inds <- order(Fis_studies$V1)[1:20]
cat(as.character(Fis_studies$pubmed[neg.inds]), sep = ', ')

pos.inds <- order(Fis_studies$V2, decreasing = T)[1:20]
cat(as.character(Fis_studies$pubmed[pos.inds]), sep = ', ')
neg.inds <- order(Fis_studies$V2)[1:20]
cat(as.character(Fis_studies$pubmed[neg.inds]), sep = ', ')


pos.inds <- order(Fis_studies$V3, decreasing = T)[1:20]
cat(as.character(Fis_studies$pubmed[pos.inds]), sep = ', ')
neg.inds <- order(Fis_studies$V3)[1:20]
cat(as.character(Fis_studies$pubmed[neg.inds]), sep = ', ')


pos.inds <- order(Fis_studies$V4, decreasing = T)[1:20]
cat(as.character(Fis_studies$pubmed[pos.inds]), sep = ', ')
neg.inds <- order(Fis_studies$V4)[1:20]
cat(as.character(Fis_studies$pubmed[neg.inds]), sep = ', ')


pos.inds <- order(Fis_studies$V5, decreasing = T)[1:20]
cat(as.character(Fis_studies$pubmed[pos.inds]), sep = ', ')
neg.inds <- order(Fis_studies$V5)[1:20]
cat(as.character(Fis_studies$pubmed[neg.inds]), sep = ', ')


pos.inds <- order(Fis_studies$V1, decreasing = T)[1:20]
cat(Fis_studies[pos.inds,c(7)], sep='\n')
cat(as.character(Fis_studies[pos.inds,c(8)]), sep='\n')

neg.inds <- order(Fis_studies$V1)[1:20]
cat(Fis_studies[neg.inds,c(7)], sep='\n')
cat(as.character(Fis_studies[neg.inds,c(8)]), sep='\n')


pos.inds <- order(Fis_studies$V2, decreasing = T)[1:20]
cat(Fis_studies[pos.inds,c(7)], sep='\n')
cat(as.character(Fis_studies[pos.inds,c(8)]), sep='\n')

neg.inds <- order(Fis_studies$V2)[1:20]
cat(Fis_studies[neg.inds,c(7)], sep='\n')
cat(as.character(Fis_studies[neg.inds,c(8)]), sep='\n')


pos.inds <- order(Fis_studies$V3, decreasing = T)[1:20]
cat(Fis_studies[pos.inds,c(7)], sep='\n')
cat(as.character(Fis_studies[pos.inds,c(8)]), sep='\n')

neg.inds <- order(Fis_studies$V3)[1:20]
cat(Fis_studies[neg.inds,c(7)], sep='\n')
cat(as.character(Fis_studies[neg.inds,c(8)]), sep='\n')


pos.inds <- order(Fis_studies$V4, decreasing = T)[1:20]
cat(Fis_studies[pos.inds,c(7)], sep='\n')
cat(as.character(Fis_studies[pos.inds,c(8)]), sep='\n')

neg.inds <- order(Fis_studies$V4)[1:20]
cat(Fis_studies[neg.inds,c(7)], sep='\n')
cat(as.character(Fis_studies[neg.inds,c(8)]), sep='\n')

pos.inds <- order(Fis_studies$V5, decreasing = T)[1:20]
cat(Fis_studies[pos.inds,c(7)], sep='\n')
cat(as.character(Fis_studies[pos.inds,c(8)]), sep='\n')

neg.inds <- order(Fis_studies$V5)[1:20]
cat(Fis_studies[neg.inds,c(7)], sep='\n')
cat(as.character(Fis_studies[neg.inds,c(8)]), sep='\n')

## Words and studie closest to the center

fastEucCalc <- function (x, c) 
{
  if (ncol(x) == 1) {
    return((x^2) %*% matrix(1, 1, nrow(c)) + matrix(1, nrow(x), 
                                                    1) %*% t((c^2)) - 2 * x %*% t(c))
  }
  else {
    x2 = colSums(t(x)^2)
    c2 = colSums(t(c)^2)
    return(x2 %*% matrix(1, 1, nrow(c)) + matrix(1, nrow(x), 
                                                 1) %*% c2 - (2 * x %*% t(c)))
  }
}

clust <- 1      # change this..

# words
fj.centers <- t( sapply(1:6, function(x) apply(Fjs[FjAssign==x,],2,mean)) )
Dsup <- fastEucCalc(as.matrix(Fjs[FjAssign==clust,]), fj.centers)
minD <- apply(Dsup, 1, min)
cat(stemmed_words_vec_9987[FjAssign==clust][order(minD)[1:20]], sep=', ')

# studies
fi.centers <- t( sapply(1:6, function(x) apply(Fis[FiAssign==x,],2,mean)) )
Dsup <- fastEucCalc(as.matrix(Fis[FiAssign==clust,]), fi.centers)
minD <- apply(Dsup, 1, min)
cat(as.character(Fis_studies$pubmed[FiAssign==clust][order(minD)[1:20]]), sep= '\n')
cat(as.character(Fis_studies$title[FiAssign==clust][order(minD)[1:20]]), sep= '\n')


######### top 20 average vs. unique studies

fi.centers <- t(as.matrix(c(0,0,0,0,0)))
Dsup <- fastEucCalc(as.matrix(Fis), fi.centers)
minD <- apply(Dsup, 1, min)

cat(as.character(Fis_studies$pubmed[order(minD)[1:20]]), sep= '\n')
cat(as.character(Fis_studies$title[order(minD)[1:20]]), sep= '\n')
cat(FiAssign[order(minD)[1:20]], sep= '\n')


cat(as.character(Fis_studies$pubmed[order(minD, decreasing = TRUE)[1:20]]), sep= '\n')
cat(as.character(Fis_studies$title[order(minD, decreasing = TRUE)[1:20]]), sep= '\n')
cat(FiAssign[order(minD,decreasing = TRUE)[1:20]], sep= '\n')


# top 20 average vs. unique words

fj.centers <- t(as.matrix(c(0,0,0,0,0)))
Dsup <- fastEucCalc(as.matrix(Fjs), fj.centers)
minD <- apply(Dsup, 1, min)

cat(as.character(Fjs_words$word[order(minD)[1:20]]), sep= '\n')
cat(as.character(Fjs_words$FjAssign[order(minD)[1:20]]), sep= '\n')

cat(as.character(Fjs_words$word[order(minD, decreasing = TRUE)[1:20]]), sep= '\n')
cat(as.character(Fjs_words$FjAssign[order(minD, decreasing = TRUE)[1:20]]), sep= '\n')



###################################
# Cluster Evaluation results
###################################

g1<- ggplot(data=clust_evals, aes(x=X, y=studies_crit)) +
  geom_line() +
  geom_point(size=2) +
  geom_text(label=clust_evals$X, vjust=-1) +
  ylim(limits=c(2000,2560)) +
  labs(title="Cluster Evaluation of Studies",
       x="Cluster", y="Calinski- Harabasz Index") +
  theme_bw()


ggsave('./plots/studies_clust_eval.png',g1)



# list words in clusters to look for interpretations..

paste(stemmed_words_vec_9987[which(FjAssign==1)], collapse = ', ') #knowedge representation and language processing
paste(stemmed_words_vec_9987[which(FjAssign==2)], collapse = ', ') #Lifesoan and brain disorders
paste(stemmed_words_vec_9987[which(FjAssign==3)], collapse = ', ') #Sensation and movement
paste(stemmed_words_vec_9987[which(FjAssign==4)], collapse = ', ') #Cognition and psychology
paste(stemmed_words_vec_9987[which(FjAssign==5)], collapse = ', ') #Decisions, emotions and Drug Abuse
paste(stemmed_words_vec_9987[which(FjAssign==6)], collapse = ', ') #molecular and genetics



##############################
# Scree plot
##############################


tau <- FiFj$tau
gg<-ggplot(data.frame(component=1:length(tau),value=tau) , aes(y=value, x=component)) + 
  geom_point() + theme_bw() + geom_path() +
  labs(title="Scree Plot of explained variance of all components",
       x= "Component", y="Variance Explained (%)")
ggsave('./plots/scree_plot_all_comps.png',gg)


################################
# Temporal Analysis
################################

year_clust_raw <- table(Fis_studies$year,Fis_studies$FiAssign)
year_clust_raw <- t(year_clust_raw)
year_clust_raw <- year_clust_raw[,4:18]
year_clust_freq <- 
  apply(year_clust_raw, 1, 
        function(xx) xx/apply(year_clust_raw, c(2), 
                              function(x) sum(x)))
year_clust_freq <- t(year_clust_freq)

p.dat<-melt(year_clust_freq)
names(p.dat) <- c("Cluster", "Year", "Publications")
p.dat$Cluster <- as.factor(p.dat$Cluster)


g<-ggplot(p.dat , aes(x=Year,y=Publications, group=Cluster)) +
  geom_point(aes(color=Cluster), size=1, color="white")+
  geom_line(aes(color=Cluster), size=1)+
  scale_x_discrete(limits=c(2000,2005,2010,2014)) +
  theme_bw() +
  labs(x="Year", y="% of studies", title="Relative Frequency of Studies\nBy Year By Cluster") +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("./plots/temporal_trends.png",g)
ggsave("./plots/temporal_trends.tiff",g)
#write.csv(year_clust_raw, paste0(data_dir, '/year_clust_raw.csv'))
#write.csv(year_clust_freq, paste0(data_dir, '/year_clust_freq.csv'))


#############################
# Word Clouds
#############################


words.coordinates.all <- data.frame(round(Fjs,2) , word=stemmed_words_vec_9987, freq=freq.df$freq, clust=FjAssign)

num <- 20
term.matrix <- cbind(c(words.coordinates.all$freq[order(words.coordinates.all$V1)[1:num]], 
                       rep(0, num)), 
                     c(rep(0,num), 
                       words.coordinates.all$freq[order(words.coordinates.all$V1, decreasing = T)[1:num]]) )
ext20_c1 <- c(order(words.coordinates.all$V1)[1:num], 
              order(words.coordinates.all$V1, decreasing = T)[1:num])
row.names(term.matrix) <- words.coordinates.all$word[ext20_c1]
png(file="./plots/word_cloud_comp1.png",height=600,width=600)
comparison.cloud(term.matrix[,c(2,1)],scale=c(7,3),
                 max.words=300,random.order=F,
                 colors=c("#D73027","#2171B5"),
                 rot.per = 0, fixed.asp = F)
dev.off()


num <- 20
term.matrix <- cbind(c(words.coordinates.all$freq[order(words.coordinates.all$V2)[1:num]], rep(0, num)), 
                     c(rep(0,num), words.coordinates.all$freq[order(words.coordinates.all$V2, decreasing = T)[1:num]]) )
ext20_c1 <- c(order(words.coordinates.all$V2)[1:num], 
              order(words.coordinates.all$V2, decreasing = T)[1:num])
row.names(term.matrix) <- words.coordinates.all$word[ext20_c1]
png(file="./plots/word_cloud_comp2.png",height=600,width=600)
comparison.cloud(term.matrix[,c(2,1)],scale=c(7,3),
                 max.words=300,random.order=F,
                 colors=c("#D73027","#2171B5"),
                 rot.per = 0, fixed.asp = F)
dev.off()


num <- 20
term.matrix <- cbind(c(words.coordinates.all$freq[order(words.coordinates.all$V3)[1:num]], rep(0, num)), 
                     c(rep(0,num), words.coordinates.all$freq[order(words.coordinates.all$V3, decreasing = T)[1:num]]) )
ext20_c1 <- c(order(words.coordinates.all$V3)[1:num], 
              order(words.coordinates.all$V3, decreasing = T)[1:num])
row.names(term.matrix) <- words.coordinates.all$word[ext20_c1]
png(file="./plots/word_cloud_comp3.png",height=600,width=600)
comparison.cloud(term.matrix[,c(2,1)],scale=c(7,3),
                 max.words=300,random.order=F,
                 colors=c("#D73027","#2171B5"),
                 rot.per = 0, fixed.asp = F)
dev.off()


num <- 20
term.matrix <- cbind(c(words.coordinates.all$freq[order(words.coordinates.all$V4)[1:num]], rep(0, num)), 
                     c(rep(0,num), words.coordinates.all$freq[order(words.coordinates.all$V4, decreasing = T)[1:num]]) )
ext20_c1 <- c(order(words.coordinates.all$V4)[1:num], 
              order(words.coordinates.all$V4, decreasing = T)[1:num])
row.names(term.matrix) <- words.coordinates.all$word[ext20_c1]
png(file="./plots/word_cloud_comp4.png",height=600,width=600)
comparison.cloud(term.matrix[,c(2,1)],scale=c(7,3),
                 max.words=300,random.order=F,
                 colors=c("#D73027","#2171B5"),
                 rot.per = 0, fixed.asp = F)
dev.off()


num <- 20
term.matrix <- cbind(c(words.coordinates.all$freq[order(words.coordinates.all$V5)[1:num]], rep(0, num)), 
                     c(rep(0,num), words.coordinates.all$freq[order(words.coordinates.all$V5, decreasing = T)[1:num]]) )
ext20_c1 <- c(order(words.coordinates.all$V5)[1:num], 
              order(words.coordinates.all$V5, decreasing = T)[1:num])
row.names(term.matrix) <- words.coordinates.all$word[ext20_c1]
png(file="./plots/word_cloud_comp5.png",height=600,width=600)
comparison.cloud(term.matrix[,c(2,1)],scale=c(7,3),
                 max.words=300,random.order=F,
                 colors=c("#D73027","#2171B5"),
                 rot.per = 0, fixed.asp = F)
dev.off()


####################################
# neurological vs psychiatric
####################################

neurological<- c(97, 693, 1115, 832, 1988, 1271, 913)
# alzheim 97
# dementia 693
# frontotempor 1115
# dystonia 832
# parkinson 1988
# huntington 1271
# epilepsi 913

psychiatric <- c(45,232, 296, 2959, 138, 704, 150, 1882, 2473, 2119, 2897)
# adhd 45
# autism 232
# bipolar 296
# unipolar 2959
# anorexia 138
# depress 704
# antidepress 150
# obsess 1882
# schizophrenia 2473
# posttraumat 2119
# traumat 2897

words.temp1 <- cbind(words.coordinates.all[psychiatric,], class='psychiatric')
words.temp2 <- cbind(words.coordinates.all[neurological,], class='neurological')

words.classes <- rbind(words.temp1,words.temp2)

words.classes <- words.classes[,c("word","freq","class","clust","V1","V2","V3","V4","V5")]
write.csv(words.classes,
          file= paste0(data_dir, '/psychiatric_vs_neurological.csv'), 
          quote = FALSE,
          row.names = FALSE)

g12<-ggplot(data=words.classes, aes(x=V1, y=V2, color=class, label=word)) +
  geom_vline(xintercept = 0, color= "grey")+
  geom_hline(yintercept = 0, color= "grey")+
  #geom_point(aes(color=clust), size=3, alpha=.7) +
  geom_text(size=5) +
  labs(x="Component 1", y="Component 2", color= "Disorder\nClass") +
  #facet_wrap(~class) +
  theme_minimal()
print(g12)

ggsave('./plots/neuro_vs_psychiat_1v2.png', g12)





######################################
# Correlation Plots
######################################

comps <- read.csv(paste0(data_dir, '/cmps_yeo_correlations.csv'),header=F)
clusts <- read.csv(paste0(data_dir, '/clusts_yeo_correlations.csv'),header=F)

colnames(comps) <- paste0("YC", c(1:14))
comps <- comps[,1:12]
#comps <- comps[c(5,4,3,2,1),c(1:12)]
cor_melted <- melt(round(as.matrix(comps), 2))
cor_melted$Var1 <- factor(cor_melted$Var1, levels = c(5,4,3,2,1))
g1 <- ggplot(data = cor_melted, aes(y=Var1, x=Var2, fill=value)) + 
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") +
  geom_text(aes(y=Var1, x=Var2, label = value), color = "black", size = 4) +
  theme_classic()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  #coord_fixed() +
  labs(x="Yeo et al. (2015) Maps", y="The 5 Components",
       title="Correlation heatmap between semantic components \nand Yeo et al. (2015) maps")



clusts <- read.csv(paste0(data_dir, '/clusts_yeo_correlations.csv'),header=F)
colnames(clusts) <- paste0("YC", c(1:14))
clusts <- clusts[,1:12]
cor_melted <- melt(round(as.matrix(clusts), 2))
cor_melted$Var1 <- factor(cor_melted$Var1, levels = c(6, 5,4,3,2,1))
g2 <- ggplot(data = cor_melted, aes(y=Var1, x=Var2, fill=value)) + 
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") +
  geom_text(aes(y=Var1, x=Var2, label = value), color = "black", size = 4) +
  theme_classic()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  #coord_fixed() +
  labs(x="Yeo et al. (2015) Maps", y="The 5 Components",
       title="Correlation heatmap between semantic clusters \nand Yeo et al. (2015) maps")

ggsave('./plots/comps_correlations.png', g1)
ggsave('./plots/clust_correlations.png', g2)
