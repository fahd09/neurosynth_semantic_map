## simple recommender engine function.

require(ExPosition)
require(data.table)

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


NeuroRecommend <- function(number.of.neighbors=25,pmid=NA){
	
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
		print("No PMID selected. We'll choose on for you!")
		pmid <- sample(rownames(studies.coords),1,1)
	}
	this.pmid <- which( rownames(studies.coords)==pmid )
	euc.dists <- apply(studies.coords[-this.pmid,], 1, function(x){ sum( (x-studies.coords[this.pmid,])^2 ) } )
	
	these.studies <- names(sort(euc.dists))[1:number.of.neighbors]
	#studies.info[ names(sort(euc.dists))[1:number.of.neighbors],]


		## functionalize and pass in axes.
	dev.new()
	plot(studies.coords,axes=F,type="n")
	abline(h=0,lty=2,col="grey80")
	abline(v=0,lty=2,col="grey80")	
	points(studies.coords,col=add.alpha(studies.colors,.2),pch=20,cex=.75)
	points(studies.coords[these.studies,],bg= add.alpha(studies.colors[these.studies],.6),pch=21,cex=.75)
	points(studies.coords[pmid,1],studies.coords[pmid,2],bg="red",pch=21,cex=1)
	

	return(studies.info[these.studies,])
	
		
}
