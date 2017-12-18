## Neurosynth RecommendR HelpRs (could I be any lameR? [clearly yes])

  ## This function is stolen from here: http://lamages.blogspot.com/2013/04/how-to-change-alpha-value-of-colours-in.html
  ## With some slight modifcations.
add.alpha <- function(col, alpha=0.65){
  apply(
    sapply(col, col2rgb)/255, 
    2, 
    function(x){
      rgb(x[1], x[2], x[3], alpha=alpha)
    }
  ) 
}

nr.base.plot <- function(dat,...){
  
  xy.lims <- apply(dat,2,range) * 1.1
  plot(dat,xlim=xy.lims[,1],ylim=xy.lims[,2],asp=1,...,cex=.5)
  abline(h=0,lty=2,col="grey80")
  abline(v=0,lty=2,col="grey80")  
  
}

entry.and.neighbors <- function(dat,entry=NA,number.of.neighbors=10){
  #warning(entry)
  
  if( !(entry %in% dat[,1] ) | is.na(entry)){
    warning("PMID or Stem does not exist in this list. We'll choose one for you!")
    entry <- sample(dat[,1],1)
  }
  this.entry <- which( as.character(dat[,1])==as.character(entry) )
  euc.dists <- apply(dat[,paste0("component_",1:5)], 1, function(x){ sum( (x-dat[this.entry,paste0("component_",1:5)])^2 ) } )
  return(order(euc.dists)[1:(number.of.neighbors+1)]) #should be the full set. top is the entry.
}

studies.plot.panel <- function(studies.dat,color.selector=2,pmid="19789183",number.of.neighbors=10,alpha=.5){
 
  if(color.selector==1){
    col <- studies.dat$color
  }else{
    col <- "grey80"
  }
  
  friends <- entry.and.neighbors(studies.dat,pmid,number.of.neighbors)
  #warning(dim(friends))
  
    ## I need a real base plot for each...
  par(mfrow=c(2,2),oma=c(0,0,0,0))
  nr.base.plot(studies.dat[,c("component_1","component_2")],xlab="Component 1",ylab="Component 2",col=add.alpha(col,alpha=alpha),pch=20,axes=F)
    points(studies.dat[friends[-1],"component_1"],studies.dat[friends[-1],"component_2"],col="black",pch=20,cex=.6)  
    points(studies.dat[friends[1],"component_1"],studies.dat[friends[1],"component_2"],bg="white",pch=21,cex=.85)
    
    
  nr.base.plot(studies.dat[,c("component_1","component_3")],xlab="Component 1",ylab="Component 3",col=add.alpha(col,alpha=alpha),pch=20,axes=F)
    points(studies.dat[friends[-1],"component_1"],studies.dat[friends[-1],"component_3"],col="black",pch=20,cex=.6)  
    points(studies.dat[friends[1],"component_1"],studies.dat[friends[1],"component_3"],bg="white",pch=21,cex=.85)
  
  nr.base.plot(studies.dat[,c("component_4","component_5")],xlab="Component 4",ylab="Component 5",col=add.alpha(col,alpha=alpha),pch=20,axes=F)
    points(studies.dat[friends[-1],"component_4"],studies.dat[friends[-1],"component_5"],col="black",pch=20,cex=.6)  
    points(studies.dat[friends[1],"component_4"],studies.dat[friends[1],"component_5"],bg="white",pch=21,cex=.85)
  
}

stems.plot.panel <- function(stems.dat,color.selector=2,stem="truth",number.of.neighbors=10,alpha=.5){
  
  if(color.selector==1){
    col <- stems.dat$color
  }else{
    col <- "grey80"
  }
  
  ## I need a real base plot for each...
  par(mfrow=c(2,2),oma=c(0,0,0,0))
  nr.base.plot(stems.dat[,c("component_1","component_2")],xlab="Component 1",ylab="Component 2",col=add.alpha(col,alpha=alpha),pch=20,axes=F)
  nr.base.plot(stems.dat[,c("component_1","component_3")],xlab="Component 1",ylab="Component 3",col=add.alpha(col,alpha=alpha),pch=20,axes=F)
  nr.base.plot(stems.dat[,c("component_4","component_5")],xlab="Component 4",ylab="Component 5",col=add.alpha(col,alpha=alpha),pch=20,axes=F)
  
  
}
  
