rm(list=ls())
gc()

library(R.matlab)
library(clusterCrit)
library(TExPosition)


data_dir <- './data'
mat.in <- readMat(paste0(data_dir, "/FiFjLambda_20comps_fulltau_lambda.mat"))



clust.assess <- function(to.clust,clust.nums,meth,crit){
	
	ch.vals <- vector("numeric",length(clust.nums))
	names(ch.vals) <- as.character(clust.nums)

	for(i in 1:length(clust.nums)){
		hc <- hclust(dist(to.clust),method=meth)
		cls <- cutree(hc, k = clust.nums[i])
		ch.vals[i] <- intCriteria(to.clust, cls, crit)
		print(i)
	}
	return(ch.vals)
}

##This function is stolen from here: http://lamages.blogspot.com/2013/04/how-to-change-alpha-value-of-colours-in.html
##With some slight modifcations.
add.alpha <- function(col, alpha=0.65){
	apply(
		sapply(col, col2rgb)/255, 
		2, 
		function(x){
			rgb(x[1], x[2], x[3], alpha=alpha)
		}
	)  
}



comps.to.use <- 1:5
k.tests <- 3:15


##for FJ
fj.res <- clust.assess(mat.in$Fj20[,comps.to.use], k.tests,"ward.D2","Calinski_Harabasz")

##for FI
fi.res <- clust.assess(mat.in$Fi20[, comps.to.use], k.tests,"ward.D2","Calinski_Harabasz")

##for Both...
both.res <- clust.assess(rbind(mat.in$Fi20[, comps.to.use],mat.in$Fj20[, comps.to.use]), k.tests,"ward.D2","Calinski_Harabasz")

# save results
results<-data.frame(studies_crit=unlist(fi.res),words_crit=unlist(fj.res), both_crit=unlist(both.res))
write.csv(results, file=paste0(data_dir, "/clustering_eval_results.csv"))



####BOTH OF THESE SUGGEST 6 CLUSTERS.


dev.new()
plot(names(unlist(fj.res)), unlist(fj.res),type="l")
points(names(unlist(fj.res)), unlist(fj.res))

dev.new()
plot(names(unlist(fi.res)), unlist(fi.res),type="l")
points(names(unlist(fi.res)), unlist(fi.res))

dev.new()
plot(names(unlist(both.res)), unlist(both.res),type="l")
points(names(unlist(both.res)), unlist(both.res))

###### Make cluster assignments

k.grps <- 6


##I can do knn with fii2fi
fj.hc <- hclust(dist(mat.in$Fj20[,comps.to.use]),"ward.D2")
fj.6 <- cutree(fj.hc, k = k.grps)
fj.des <- makeNominalData(as.matrix(fj.6))
fj.massedDESIGN <- t(apply(fj.des, 1, "/", colSums(fj.des)))
fj.centers <- t(fj.massedDESIGN) %*% mat.in$Fj20[,comps.to.use]
fj.Dsup <- fastEucCalc(mat.in$Fi20[,comps.to.use], fj.centers)
fj.minD <- apply(fj.Dsup, 1, min)
fi.to.fj.Group_Assigned = Re(fj.Dsup == repmat(fj.minD, 1, nrow(fj.centers)))



fi.hc <- hclust(dist(mat.in$Fi20[,comps.to.use]),"ward.D2")
fi.6 <- cutree(fi.hc, k = k.grps)
fi.des <- makeNominalData(as.matrix(fi.6))
fi.massedDESIGN <- t(apply(fi.des, 1, "/", colSums(fi.des)))
fi.centers <- t(fi.massedDESIGN) %*% mat.in$Fi20[,comps.to.use]
fi.Dsup <- fastEucCalc(mat.in$Fj20[,comps.to.use], fi.centers)
fi.minD <- apply(fi.Dsup, 1, min)
fj.to.fi.Group_Assigned = Re(fi.Dsup == repmat(fi.minD, 1, nrow(fi.centers)))



both.hc <- hclust(dist(rbind(mat.in$Fi20[,comps.to.use],mat.in$Fj20[,comps.to.use])),"ward.D2")
both.6 <- cutree(both.hc, k = k.grps)
both.des <- makeNominalData(as.matrix(both.6))

fi.assign <- both.des[1:nrow(mat.in$Fi20),]
fj.assign <- both.des[(nrow(fi.assign)+1):nrow(both.des),]


load(paste0(data_dir, "/stemmed_words_vec_9987.RData"))

rownames(fj.to.fi.Group_Assigned) <- rownames(fj.des) <- rownames(fj.assign) <- stemmed_words_vec_9987


t(fj.des) %*% fj.to.fi.Group_Assigned
t(fj.des) %*% fj.assign
t(fj.to.fi.Group_Assigned) %*% fj.assign

colSums(fj.des)/sum(fj.des)
colSums(fi.to.fj.Group_Assigned)/sum(fi.to.fj.Group_Assigned)

colSums(fi.des)/sum(fi.des)
colSums(fj.to.fi.Group_Assigned)/sum(fj.to.fi.Group_Assigned)

write.csv(fi.des, file=paste0(data_dir, "/studies_clusters_binarized.csv"))
write.csv(fj.to.fi.Group_Assigned, file=paste0(data_dir, "/words_clusters_binarized.csv"))


####clustering of FI and then assigning FJ is most reasonable to me because it's a better/more even distribution
# fi.des
# fj.to.fi.Group_Assigned

xa<-1
ya<-2

prettyPlot(mat.in$Fj20,col=add.alpha(createColorVectorsByDesign(fj.to.fi.Group_Assigned)$oc,0.35),pch=20,x_axis=xa,y_axis=ya,xlab="C1",ylab="C2")
just.6 <- mat.in$Fj20[which(fj.to.fi.Group_Assigned[,6]==1),]
rownames(just.6) <- rownames(fj.to.fi.Group_Assigned[which(fj.to.fi.Group_Assigned[,6]==1),])
prettyPlot(just.6,col="red",dev.new=F,axes=F,new.plot=F,x_axis=xa,y_axis=ya,pch=20)


xa<-4
ya<-5

prettyPlot(mat.in$Fj20,col=add.alpha(createColorVectorsByDesign(fj.to.fi.Group_Assigned)$oc,0.35),pch=20,x_axis=xa,y_axis=ya,xlab="C4",ylab="C5")
just.6 <- mat.in$Fj20[which(fj.to.fi.Group_Assigned[,6]==1),]
rownames(just.6) <- rownames(fj.to.fi.Group_Assigned[which(fj.to.fi.Group_Assigned[,6]==1),])
prettyPlot(just.6,col="red",dev.new=F,axes=F,new.plot=F,x_axis=xa,y_axis=ya,pch=20)

someinteresting <- mat.in$Fj20[which(rowSums(mat.in$Fj20[,4:5] < (-0.8))==2),]
rownames(someinteresting) <- rownames(fj.to.fi.Group_Assigned[which(rowSums(mat.in$Fj20[,4:5] < (-0.8))==2),])
prettyPlot(someinteresting,col="grey80",dev.new=F,axes=F,new.plot=F,x_axis=xa,y_axis=ya)


# Write stdies assignments to a file

studies_ci <- read.csv('./data/studies_clusters_binarized.csv')
studies_ci <- studies_ci[,-c(1)]  # delete the first column
idx_assignments <- apply(studies_ci, 1, function(x) which(x==1))
write.table(idx_assignments, 
            file=paste0(data_dir, "/idx_assignments_6clusters.txt"),
            row.names = F, col.names = F)
