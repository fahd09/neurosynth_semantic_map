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

studies.plot.panel <- function(studies.dat,color.selector=2,pmid="19789183",similar.set.size=10,alpha=.5){
 
  if(color.selector==1){
    col <- studies.dat$color
  }else{
    col <- "grey80"
  }
  
    ## I need a real base plot for each...
  par(mfrow=c(2,2),oma=c(0,0,0,0))
  nr.base.plot(studies.dat[,c("component_1","component_2")],xlab="Component 1",ylab="Component 2",col=add.alpha(col,alpha=alpha),pch=20,axes=F)
  nr.base.plot(studies.dat[,c("component_1","component_3")],xlab="Component 1",ylab="Component 3",col=add.alpha(col,alpha=alpha),pch=20,axes=F)
  nr.base.plot(studies.dat[,c("component_4","component_5")],xlab="Component 4",ylab="Component 5",col=add.alpha(col,alpha=alpha),pch=20,axes=F)

  
}

stems.plot.panel <- function(stems.dat,color.selector=2,stem="truth",similar.set.size=10,alpha=.5){
  
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
  
