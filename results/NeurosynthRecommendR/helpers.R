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
  plot(dat,xlim=xy.lims[,1],ylim=xy.lims[,2],asp=1,...)
  abline(h=0,lty=2,col="grey80")
  abline(v=0,lty=2,col="grey80")  
  
}

  ## this can stay, but only as a helper that is never used by the App.
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


studies.plot.panel <- function(studies.dat, studies.friends,color.selector=2,pmid="19789183",number.of.neighbors=10,alpha=.5,x.axis=1,y.axis=2,cex=.75){
 
  if(color.selector==1){
    col <- studies.dat$color
  }else{
    col <- "grey80"
  }
  
  if( !(pmid %in% studies.dat[,'pubmed']) ){
    nr.base.plot(studies.dat[,c(paste0("component_",x.axis),paste0("component_",y.axis))],xlab=paste0("Component ",x.axis),ylab=paste0("Component ",y.axis),col=add.alpha(col,alpha=alpha),pch=20,axes=F,cex=cex)
    return(list(message="invalid",results=NULL))
  }else{
    friends <- studies.friends[pmid,1:(number.of.neighbors+1)]
    
    nr.base.plot(studies.dat[,c(paste0("component_",x.axis),paste0("component_",y.axis))],xlab=paste0("Component ",x.axis),ylab=paste0("Component ",y.axis),col=add.alpha(col,alpha=alpha),pch=20,axes=F,cex=cex)
    points(studies.dat[friends[-1],paste0("component_",x.axis)],studies.dat[friends[-1],paste0("component_",y.axis)],col="black",bg="grey80",pch=21,cex=cex*1.25)  
    points(studies.dat[friends[1],paste0("component_",x.axis)],studies.dat[friends[1],paste0("component_",y.axis)],bg="red",pch=21,cex=1.5)
    
    return(list(message="valid",results=studies.dat[friends,]))
  }
}

stems.plot.panel <- function(stems.dat, stems.friends,color.selector=2,stem="truth",number.of.neighbors=10,alpha=.5,x.axis=1,y.axis=2,cex=cex){
  
  if(color.selector==1){
    col <- stems.dat$color
  }else{
    col <- "grey80"
  }
  
  if( !(stem %in% stems.dat[,'word']) ){
    nr.base.plot(stems.dat[,c(paste0("component_",x.axis),paste0("component_",y.axis))],xlab=paste0("Component ",x.axis),ylab=paste0("Component ",y.axis),col=add.alpha(col,alpha=alpha),pch=20,axes=F,cex=cex)
    return(list(message="invalid",results=NULL))
  }else{
    friends <- stems.friends[stem,1:(number.of.neighbors+1)]
  
    nr.base.plot(stems.dat[,c(paste0("component_",x.axis),paste0("component_",y.axis))],xlab=paste0("Component ",x.axis),ylab=paste0("Component ",y.axis),col=add.alpha(col,alpha=alpha),pch=20,axes=F,cex=cex)
    points(stems.dat[friends[-1],paste0("component_",x.axis)],stems.dat[friends[-1],paste0("component_",y.axis)],col="black",bg="grey80",pch=21,cex=cex*1.25)  
    points(stems.dat[friends[1],paste0("component_",x.axis)],stems.dat[friends[1],paste0("component_",y.axis)],bg="red",pch=21,cex=1.5)
    return(list(message="valid",results=stems.dat[friends,]))
  }
}


years.plot.panel <- function(studies.dat, which.year="1997",alpha=.5,x.axis=1,y.axis=2,cex=cex){
  
  col <- "grey80"

  these.studies <- which(studies.dat$year==which.year)
  
  #par(mfrow=c(2,2),oma=c(0,0,0,0))
  nr.base.plot(studies.dat[,c(paste0("component_",x.axis),paste0("component_",y.axis))],xlab=paste0("Component ",x.axis),ylab=paste0("Component ",y.axis),col=add.alpha(col,alpha=alpha),pch=20,axes=F,cex=cex)
  points(studies.dat[these.studies,paste0("component_",x.axis)],studies.dat[these.studies,paste0("component_",y.axis)],col="black",bg="grey80",pch=21,cex=cex*1.25) 
  

}
 

journal.plot.panel <- function(studies.dat, which.journal="Neuron",alpha=.5,x.axis=1,y.axis=2,cex=cex){
  
  col <- "grey80"
  
  these.studies <- which(studies.dat$journal==which.journal)
  
  #par(mfrow=c(2,2),oma=c(0,0,0,0))
  nr.base.plot(studies.dat[,c(paste0("component_",x.axis),paste0("component_",y.axis))],xlab=paste0("Component ",x.axis),ylab=paste0("Component ",y.axis),col=add.alpha(col,alpha=alpha),pch=20,axes=F,cex=cex)
  points(studies.dat[these.studies,paste0("component_",x.axis)],studies.dat[these.studies,paste0("component_",y.axis)],col="black",bg="grey80",pch=21,cex=cex*1.25) 
  
  
} 
