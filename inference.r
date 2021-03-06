##WLDF 510 R script - comparison of "NHST", ML, and Bayesian approaches to inference

##required library - a new one for use, probably - metafor
require(metafor)
require(MCMCglmm)

setwd("C:\\Users\\sd1249\\Documents\\Sharon\\Spring2016\\MetaAnalysis_WLDF510\\Practice_Scripts\\lepidoptera_test")

##read in lepidoptera.csv
dat      <- read.csv("lepidoptera.csv",sep=",",header=TRUE)
##some data-schwonking to remove missing values, and variable named "family" is problematic in MCMCglmm
dat      <- dat[complete.cases(dat),-3]

#recall the fatally flawed model with no random effects...

fe.model <- rma(hedge.d ~1, var.d, data=dat, method = "FE")

#now add fixed effects... so *all* variance among studies in effect sizes is explained by moderators

fe.model <- rma(hedge.d ~ percent.polyandry + subord, var.d, data=dat, method = "FE")

##back to problem at hand... comparing alternative approaches to inference

##three different approches to statistical inference, all with "random-effects" design

##method of moments
he.model <- rma(hedge.d ~ percent.polyandry + subord, var.d, data=dat, method = "HE") #method of moments
##think about p-values *and what they mean in this context* use summary() to look at parameter esimates


##maximum likelihood (also, I-T model selection)
ml.model.reduced <- rma(hedge.d ~ subord, var.d, data=dat, method = "REML") #maximum-likelihood
ml.model.full    <- rma(hedge.d ~ percent.polyandry + subord, var.d, data=dat, method = "REML") 
##you'll need to compare models to use I-T selection, right? use summary() to compare AIC


##Bayesian inference (not to be confused with empirical Bayes option in rma, not same thing)

##define priors (these are "minimally informative" priors for the covariances, see MCMCglmm man pages for help)
##the only one of interest here is the "R" covariance, which ends of "translating" to a prior for the among-study
##variance in effect sizes
prior = list(R = list(V = 1, nu=0), G = list(list ( V = 1, n = 1, fix=1)))

##we're using MCMCglmm() to approximate the posterior probability distributions of the parameters of the model
##that we're interested in... easier than WinBUGS or JAGS, less flexible
bayes.model<-MCMCglmm(hedge.d~percent.polyandry + subord, mev=dat$var.d, data=dat, nitt=15000, thin=10, burnin=5000, prior=prior)

##plots MCMC chains and posterior approximations
plot(bayes.model)
##posterior probability distributions... use summary()

##graphing in case you want it...

##a histogram of each study's effect size
##hist(dat$hedge.d, breaks=15, xlab="hedge's d", col=2)
##abline(v=0,col=4,lty=3,lwd=5)
##make a simple forest plot
##forest(dat$hedge.d,dat$var.d,slab=dat$species,pch=19)
