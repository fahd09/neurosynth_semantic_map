## simple recommender engine function.

require(ExPosition)
require(data.table)
require(plotrix)

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


nr.base.plotter <- function(coords, closest.studies, selected.study, studies.colors, x_axis=1, y_axis=2){
	
	#dev.new()
	
	# base of the plot
	plot(coords[,c(x_axis,y_axis)],axes=F,type="n", xlab=paste0("Component ",x_axis), ylab=paste0("Component ", y_axis))
	abline(h=0,lty=2,col="grey80")
	abline(v=0,lty=2,col="grey80")	
	
	## all
	points(coords[,c(x_axis,y_axis)],col=add.alpha(studies.colors,.2),pch=20,cex=.75)

	## the closest
	points(coords[closest.studies,c(x_axis,y_axis)],bg= add.alpha(studies.colors[closest.studies],.6),pch=21,cex=.75)

	## the selected study
	points(coords[selected.study,x_axis],coords[selected.study,y_axis],bg="red",pch=21,cex=1)

	
}


NeurosynthRecommend <- function(number.of.neighbors=50,pmid=NA){
	
	studies <- as.matrix(fread('studies_matrix.csv'))
	
	studies.coords <- gsub("[[:space:]]","", studies[,c("V1","V2","V3","V4","V5")])
		class(studies.coords) <- "numeric"
		studies.coords <- round(as.matrix(studies.coords),digits=6)
		rownames(studies.coords) <- gsub("[[:space:]]","", studies[,"pubmed"])
		colnames(studies.coords) <- paste0("Component ",1:5)

	studies.colors <- studies[,"color"]
		names(studies.colors) <- gsub("[[:space:]]","", studies[,"pubmed"])

	studies.info <- studies[,c("title","authors","year","journal","FiAssign")]
		rownames(studies.info) <- gsub("[[:space:]]","", studies[,"pubmed"])
		colnames(studies.info)[ncol(studies.info)] <- "Cluster"
	
		
	if( !(pmid %in% rownames(studies.coords)) ){
		warning("PMID does not exist in this list. We'll choose on for you!")
		pmid <- sample(rownames(studies.coords),1,1)
	}
	this.pmid <- which( rownames(studies.coords)==pmid )
	euc.dists <- apply(studies.coords[-this.pmid,], 1, function(x){ sum( (x-studies.coords[this.pmid,])^2 ) } )
	
	these.studies <- names(sort(euc.dists))[1:number.of.neighbors]
	#studies.info[ names(sort(euc.dists))[1:number.of.neighbors],]


	## functionalize and pass in axes.
	par(mfrow=c(2,2),oma=c(0,0,2,0))
	nr.base.plotter(studies.coords, these.studies, this.pmid, studies.colors, x_axis=1, y_axis=2)
	nr.base.plotter(studies.coords, these.studies, this.pmid, studies.colors, x_axis=1, y_axis=3)	
	nr.base.plotter(studies.coords, these.studies, this.pmid, studies.colors, x_axis=4, y_axis=5)
	plot(c(-1,1),c(-1,1),type="n",axes=F,xlab="",ylab="",sub="Top 5")
	s <- paste("(",these.studies,") ",as.matrix(studies.info[these.studies,c("title")]))
	addtable2plot("topmiddle",table=as.matrix(gsub('(.{1,50})(\\s|$)', '\\1\n', s[1:5])), cex=.7, display.colnames=F,display.rownames=F, ypad=.01,xpad=.01)
	title(paste0(pmid,"'s ", number.of.neighbors," nearest semantic neighbors"), outer=T)
		
	return(studies.info[these.studies,])
		
}
