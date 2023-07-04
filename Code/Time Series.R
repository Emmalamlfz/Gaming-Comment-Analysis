#Load the required packages
pacman::p_load(magrittr,dplyr,forecast,tseries,fUnitRoots,tidyverse, lmtest,fastDummies)

install.packages("readxl")
library("readxl")

# Read Dataset
Othervariables <- read_excel("Othervariables(1).xlsx")
head(Othervariables)

# Correlation matrix
Othervariables_cor = subset(Othervariables, select = -c(Month,Monthly_Gain) )
head(Othervariables_cor)
colnames(Othervariables_cor)

# correlation matrix Plot
library(psych)
pairs.panels(Othervariables_cor, 
             method = "pearson", # correlation method
             hist.col = "#9999FF",
             density = TRUE,  # show density plots
             ellipses = TRUE, # show correlation ellipses
             main="Correlation Matrix"
)


######################################### Google Impact Dataset

globaltrend <-read.csv("multiTimeline (1)(1).csv",header=TRUE)
head(globaltrend)

# lag plots
pacman::p_load(magrittr,dplyr,forecast,tseries,fUnitRoots,tidyverse, lmtest,fastDummies)
gglagplot(globaltrend$google_impact,set.lags = 1:24,do.lines = FALSE)

# change Week as a date variable
globaltrend$week <- as.Date(globaltrend$week)
str(globaltrend)
head(globaltrend)


# check whether the data type is a ts object
is.ts(globaltrend$google_impact)

#convert datasets into Time Series data format for processing 
##  frequency = 48 是因为按照周算 1/4*48 = 12
genshin_SG = ts(globaltrend$google_impact, frequency = 48, start = c(2020, 9)) 
genshin_SG
is.ts(genshin_SG)

globaltrend$genshin_SG = genshin_SG
ggplot(globaltrend, aes(x=week, y=genshin_SG, group = 1)) +
  geom_line(color = "#9999FF") +
  ggtitle("Genshin Google Trend time series") + 
  xlab("Time") + 
  ylab("Genshin Google Impact")+
  theme(axis.text.x=element_text(angle=50, hjust=1)) +
  theme_bw()

# Using the decomposition function in R 
genshin_SG = ts(globaltrend$google_impact,start = c(2020, 36), end = c(2022,43), frequency = 48) 
decompTrainD = decompose(genshin_SG,type = c("additive"))
plot(decompTrainD, lwd=2, col="#9999FF")


#### 比例 30% VS 70%
#总共是112个数据，70%是差不多78个
# first 78 values 
training = subset(genshin_SG, end=length(genshin_SG)-34)
# start from 79 value till end of series 
test = subset(genshin_SG, start=length(genshin_SG)-33) #test为34 points

#perform first order normal differencing
training %>% ggtsdisplay()

# take an seasonal difference
training %>% diff(lag = 48)%>% ggtsdisplay()


######################### Models
model_train_sea = Arima(training, order = c(1,0,1))
summary(model_train_sea)
coeftest(model_train_sea)

checkresiduals(model_train_sea)
pacf(model_train_sea$residuals, lag = 48)

# use this model on the test set
model_train_sea %>% forecast(h = 80) %>% autoplot() + autolayer(test) #test is the actual test data

pred_test_sea = Arima(test, model = model_train_sea)
accuracy(pred_test_sea)

#########################
model_train_sea_1 = Arima(training, order = c(2,0,1))
summary(model_train_sea_1)
coeftest(model_train_sea_1)

checkresiduals(model_train_sea_1)
pacf(model_train_sea_1$residuals, lag = 48)


# use this model on the test set
model_train_sea_1 %>% forecast(h = 80) %>% autoplot() + autolayer(test) #test is the actual test data
pred_test_sea_1 = Arima(test, model = model_train_sea_1)
accuracy(pred_test_sea_1)

#########################
model_train_sea_2 = Arima(training, order = c(2,0,0))
summary(model_train_sea_2)
coeftest(model_train_sea_2)

checkresiduals(model_train_sea_2)
pacf(model_train_sea_2$residuals, lag = 48)

# use this model on the test set
model_train_sea_2 %>% forecast(h = 80) %>% autoplot() + autolayer(test) #test is the actual test data

pred_test_sea_2 = Arima(test, model = model_train_sea_2)
accuracy(pred_test_sea_2)

######################### (Fail)
model_train_sea_3 = Arima(training, order = c(1,0,1), seasonal=c(0,1,0))
summary(model_train_sea_3)
coeftest(model_train_sea_3)

checkresiduals(model_train_sea_3)
pacf(model_train_sea_3$residuals, lag = 48)

# use this model on the test set
model_train_sea_3 %>% forecast(h = 80) %>% autoplot() + autolayer(test) #test is the actual test data

pred_test_sea_3 = Arima(test, model = model_train_sea_3)
accuracy(pred_test_sea_3)

#########################



model_train_sea_4 = Arima(training, order = c(1,0,1), seasonal=c(1,0,0))
summary(model_train_sea_4)
coeftest(model_train_sea_4)

checkresiduals(model_train_sea_4)
pacf(model_train_sea_4$residuals, lag = 48)


# use this model on the test set
model_train_sea_4 %>% forecast(h = 34) %>% autoplot() + autolayer(test) #test is the actual test data

pred_test_sea_4 = Arima(test, model = model_train_sea_4)
accuracy(pred_test_sea_4)


#########################
model_train_sea_5 = Arima(training, order = c(1,0,0), seasonal=c(1,0,0))

summary(model_train_sea_5)
coeftest(model_train_sea_5)

checkresiduals(model_train_sea_5)
pacf(model_train_sea_5$residuals, lag = 52, main="PACF of residuals") #  The PACF plot is a plot of the partial correlation coefficients between the series and lags of itself.

# use this model on the test set
model_train_sea_5 %>% forecast(h = 80) %>% autoplot() + autolayer(test) #test is the actual test data

pred_test_sea_5 = Arima(test, model = model_train_sea_5)
accuracy(pred_test_sea_5)

#########################
model_train_sea_6 = Arima(training, order = c(1,0,0), seasonal=c(0,0,0))
summary(model_train_sea_6)
coeftest(model_train_sea_6)

checkresiduals(model_train_sea_6)
pacf(model_train_sea_6$residuals, lag = 48)

# use this model on the test set
model_train_sea_6 %>% forecast(h = 80) %>% autoplot() + autolayer(test) #test is the actual test data

pred_test_sea_6 = Arima(test, model = model_train_sea_6)
accuracy(pred_test_sea_6)

#########################
model_train_sea_7 = Arima(training, order = c(0,0,1), seasonal=c(0,0,0))
summary(model_train_sea_7)
coeftest(model_train_sea_7)

checkresiduals(model_train_sea_7)
pacf(model_train_sea_7$residuals, lag = 48)

# use this model on the test set
model_train_sea_7 %>% forecast(h = 80) %>% autoplot() + autolayer(test) #test is the actual test data

pred_test_sea_7 = Arima(test, model = model_train_sea_7)
accuracy(pred_test_sea_7)

#########################
model_train_sea_8 = Arima(training, order = c(0,0,1), seasonal=c(1,0,0))
summary(model_train_sea_8)
coeftest(model_train_sea_8)

checkresiduals(model_train_sea_8)
pacf(model_train_sea_8$residuals, lag = 48)

# use this model on the test set
model_train_sea_8 %>% forecast(h = 80) %>% autoplot() + autolayer(test) #test is the actual test data

pred_test_sea_8 = Arima(test, model = model_train_sea_8)
accuracy(pred_test_sea_8)








