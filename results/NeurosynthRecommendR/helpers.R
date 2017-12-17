## Neurosynth RecommendR HelpRs (could I be any lameR? [clearly yes])

add.alpha <- function(col, alpha=0.65){
  apply(
    sapply(col, col2rgb)/255, 
    2, 
    function(x){
      rgb(x[1], x[2], x[3], alpha=alpha)
    }
  ) 
}


nr.base.studies.plot <- function(studies,col="grey80"){
 
    ## I need a real base plot for each...
  par(mfrow=c(2,2))
  
  xlims <- ylims <- c(-max(abs(studies[,paste0("component_",1:5)])),max(abs(studies[,paste0("component_",1:5)])))
  
  plot(studies[,c("component_1","component_2")],xlab="Component 1",ylab="Component 2",col=add.alpha(col),pch=20,axes=F,xlim=xlims,ylim=ylims)
  abline(h=0,lty=2,col="grey80")
  abline(v=0,lty=2,col="grey80")
  
  plot(studies[,c("component_1","component_3")],xlab="Component 1",ylab="Component 3",col=add.alpha(col),pch=20,axes=F,xlim=xlims,ylim=ylims)
  abline(h=0,lty=2,col="grey80")
  abline(v=0,lty=2,col="grey80")
  
  plot(studies[,c("component_4","component_5")],xlab="Component 4",ylab="Component 5",col=add.alpha(col),pch=20,axes=F,xlim=xlims,ylim=ylims)
  abline(h=0,lty=2,col="grey80")
  abline(v=0,lty=2,col="grey80")
  
}  
  