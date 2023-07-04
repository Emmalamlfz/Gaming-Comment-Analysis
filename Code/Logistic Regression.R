# wuyangyi
pacman::p_load(tidyverse, caret, corrplot, caTools,car, ROCR, e1071)
pacman::p_load(mice, DMwR, naniar, caTools)
#library(mice)
library(openxlsx)
library(tidyverse)
library(pROC)
library(ggplot2)

review=read.xlsx("数据1014前.xlsx") 
train= read.csv("train_set.csv",header=TRUE) 
test=read.csv("test_set.csv",header=TRUE) 

attach(train)
colMeans(is.na(train))

y <- usefulness
x1 <- score
x2 <- Subjectivity
x3 <- Polarity
x4 <- length
x5 <- ABS
x6 <- Days.of.comments

review$usefulness=as.factor(review$usefulness)

#preliminary regression
m1 <- glm(y~x1+x2+x3+x4+x5+x6,family=binomial(),data=review)
summary(m1)
#check model validity
par(mfrow=c(3,3))
mmp(m1,x1)
mmp(m1,x2)
mmp(m1,x3)
mmp(m1,x4)
mmp(m1,x5)
mmp(m1,x6)
mmp(m1,m1$fitted.values,xlab="Fitted Values")

#x4(length), x6(Days.of.comments) do not fit well.

#incorporating variables
par(mfrow=c(1,2))
##density plots and box plots - check skewness
plot(density(x4[y==0],bw="SJ",kern="gaussian"),type="l",
     main="Gaussian kernel density estimate",xlab="x4")
rug(x4[y==0])
lines(density(x4[y==1],bw="SJ",kern="gaussian"),lty=2)
rug(x4[y==1])

install.packages('psych')
library(psych)
describe.by(x4) #skew is -0.23
describe.by(x6) #5.41

#x6(Days.of.comments) is right-skewed. meaning that the log odds may depend on both x and log(x). So we add log(x6) into the model. x6 don’t have value <= 0

### add log(x6)
m2 <- glm(y~x1+x2+x3+x4+x5+x6+log(x6),family=binomial(),data=review)
summary(m2)

##diagnosis
par(mfrow=c(3,3))
mmp(m2,x1)
mmp(m2,x2)
mmp(m2,x3)
mmp(m2,x4)
mmp(m2,x5)
mmp(m2,x6)
mmp(m2,log(x6))
mmp(m2,m2$fitted.values,xlab="Fitted Values")

#better. log(x6) good fit.

###plots between x4,x6 - check if adding interactions or ^2 terms
x4_1<-x4[y==1]
x4_0<-x4[y==0]
x6_1<-x6[y==1]
x6_0<-x6[y==0]

plot(x4_1,x6_1, xlab="x4", ylab="x6",col="grey") 
points(x4_0,x6_0,col="pink",pch=6)
abline(lsfit(x4_1,x6_1),col="blue")
abline(lsfit(x4_0,x6_0),col="red")

m3 <- glm(y~x1+x2+x3+x4+x5+x6+log(x6)+I(x4^2),family=binomial(),data=review)
summary(m3)

##diagnosis
par(mfrow=c(3,3))
mmp(m3,x1)
mmp(m3,x2)
mmp(m3,x3)
mmp(m3,x4)
mmp(m3,x5)
mmp(m3,x6)
mmp(m3,log(x6))
mmp(m3,m3$fitted.values,xlab="Fitted Values")

#Seemingly doesn’t improve.

##drop insignificant variables 
#drop x1,x2,x3
m4 = step(m3)
summary(m4)
vif(m4)

par(mfrow=c(3,3))
mmp(m4,x1)
mmp(m4,x2)
mmp(m4,x3)
mmp(m4,x4)
mmp(m4,x5)
mmp(m4,x6)
mmp(m4,log(x6))
mmp(m4,m4$fitted.values,xlab="Fitted Values")

detach(train)

attach(train)
y <- usefulness
x1 <- score
x2 <- Subjectivity
x3 <- Polarity
x4 <- length
x5 <- ABS
x6 <- Days.of.comments

#AUC-training
pred_tr = predict(m4, newdata = train,type='response')
roc=roc(train$usefulness, pred_tr)

plot(roc,print.auc=T,plot=TRUE,print.thres=TRUE)

#threshold=0.378

pred_train = predict(m4, newdata = train, type = 'response')
p_class = ifelse(pred_train > 0.378, 1,0)
matrix_table = table(train$usefulness, p_class)
matrix_table
confusionMatrix(table(p_class,train$usefulness), positive='1')
detach(train)

#AUC-test
attach(test)
y <- usefulness
x1 <- score
x2 <- Subjectivity
x3 <- Polarity
x4 <- length
x5 <- ABS
x6 <- Days.of.comments

pre1 = predict(m1, 
               type = 'response')
pre2 = predict(m2,  
               type = 'response')
pre3 = predict(m3,  
               type = 'response')
pre4 = predict(m4, 
               type = 'response')
roc1=roc(train$usefulness, pre1)
roc2=roc(train$usefulness, pre2)
roc3=roc(train$usefulness, pre3)
roc4=roc(train$usefulness, pre4)

plot(roc1, print.auc=TRUE,print.auc.x=0.4,print.auc.y=0.4, auc.polygon=TRUE,auc.polygon.col="gray", grid=c(0.5, 0.2),smooth=T,grid.col=c("black", "black"), max.auc.polygon=TRUE)
plot.roc(roc2,add=T,col="red", print.auc=TRUE,print.auc.x=0.3,print.auc.y=0.3)
plot.roc(roc3,add=T,col="blue",print.auc=TRUE,print.auc.x=0.5,print.auc.y=0.5)
plot.roc(roc4,add=T,col="yellow",print.auc=TRUE,print.auc.x=0.6,print.auc.y=0.6)

pred_test = predict(m4, newdata = test, type = 'response')
p_class = ifelse(pred_test > 0.378, 1,0)
matrix_table = table(test$usefulness, p_class)
matrix_table 
confusionMatrix(table(p_class,test$usefulness), positive='1')

detach(test)

#AUC-test
attach(test)
y <- usefulness
x1 <- score
x2 <- Subjectivity
x3 <- Polarity
x4 <- length
x5 <- ABS
x6 <- Days.of.comments

pre1 = predict(m1, newdata = test, 
               type = 'response')
pre2 = predict(m2, newdata = test, 
               type = 'response')
pre3 = predict(m3, newdata = test, 
               type = 'response')
pre4 = predict(m4, newdata = test, 
               type = 'response')

roc1=roc(test$usefulness, pre1)
roc2=roc(test$usefulness, pre2)
roc3=roc(test$usefulness, pre3)
roc4=roc(test$usefulness, pre4)

plot(roc1, print.auc=TRUE,print.auc.x=0.4,print.auc.y=0.4, auc.polygon=TRUE,auc.polygon.col="gray", grid=c(0.5, 0.2),smooth=T,grid.col=c("black", "black"), max.auc.polygon=TRUE)
plot.roc(roc2,add=T,col="red", print.auc=TRUE,print.auc.x=0.3,print.auc.y=0.3)
plot.roc(roc3,add=T,col="blue",print.auc=TRUE,print.auc.x=0.5,print.auc.y=0.5)
plot.roc(roc4,add=T,col="yellow",print.auc=TRUE,print.auc.x=0.6,print.auc.y=0.6)

detach(test)

#deployment predict
deployment=read.csv("deployment.csv",header=TRUE) 
attach(deployment)
y <- usefulness
x1 <- score
x2 <- Subjectivity
x3 <- Polarity
x4 <- length
x5 <- ABS
x6 <- Days.of.comments

pre = predict (m4,newdata=deployment,type='response')
predict = ifelse(pre > 0.378, 1,0)
table=deployment
table$pre=pre
table$predict=predict
write.xlsx(table,'m5deploymentpredict.xlsx',rowNames=T,colNames=T) 

