# https://www.youtube.com/watch?v=JITO5-bYxu8 참고한 자료
#  - arima with drift
#  - X.t = m*t + (W.1 + W.2 + ... + W.t) 

library(aTSA)
library(forecast)

# 파일 불러오기
gt <- read.csv('globalTemp.csv')
head(gt)

# 2번째 칼럼
X <- gt$Lowess.5.


# 사용자 함수
my_layout <- function(){
  layout(matrix(c(1,1,2,3), nrow=2, byrow = T))
}

my_plot <- function(X){
  my_layout()
  ts.plot(X)
  acf(X, lag.max = 48)
  pacf(X, lag.max = 48)
}


# 자료 확인
my_plot(X)

# 단위근 검정
adf.test(X)

# adf test 결과 type3 에서 H0를 기각하지 못함
# 시계열 자료의 그림이 이차곡선생각됨
# -> 가능한 모형
#   with drift and trend 
# 자료의 시계열 그림을 보니 3번 모형이 가장 적합해 보임
# 모형 : pi(B) * (1-B)^d * (Y.t - mu) = d + theta(B) * W.t

aic <- 1000
aic.temp <- aic
for(p in 0:2) for(q in 0:7)
{
  model_aic <- AIC(Arima(X, order = c(p,0,q), xreg = 1:length(X)))
  if (aic.temp > model_aic) {
    aic.temp <- model_aic
    cat('p =', p, 'q =', q, ' AIC = ', aic.temp, '\n')
  }
}

# AIC가 가장 낮은 (1,0,7) 선택
fit <- Arima(X, order = c(1,0,7), xreg = 1:length(X))
fit

# 추정치가 유의하지 않음

# p=1, q=6 일때 추정치가 모두 유의하고 AIC가 가장 낮음
fit <- Arima(X, order = c(1,0,6), xreg = 1:length(X))
fit

# 잔차분석
res <- fitl$res

my_plot(res)
# 그림 확인 결과 잔차가 W.N.라고 판단해도 괜찮아 보임
# SACF, SPACF확인결과 W.N. 라고 해도 괜찮아 보임

Box.test(res, lag = 12, type = 'Ljung')
# 테스트 결과 h0를 기각하지 못함.
# 최종 모델로 결정

hat<-fit$fitted # 적합값(추정된 모형에 의해서 계산된 값)
layout(1)
ts.plot(X, xlim=c(0,180), ylim=c(-0.5,1.2))
lines(hat, col="red", lty=2) # 적합값 그래프

# 예측
fcast <- forecast(fit, xreg = length(X)+1:60)
plot(fcast)
lines(hat, col="red", lty=2) # 적합값 그래프


#######################################
#######################################
# 적당한 drift로 연간 평균 co2 자료를 사용
# co2에 회귀 한다는 가정
gt <- read.csv('globalTemp.csv')
co2 <- read.csv('co2.csv', header = T)

head(co2)

filtered_gt <- gt[gt$Year>=1958,] # co2 데이터가 1958년 부터 존재
filtered_gt <- filtered_gt$Lowess.5.

my_plot(filtered_gt)

co2[,3]
co2 <- co2[,3] # 년간 평균 co2만 가져옴

co2 <- co2[-length(co2)] # 평균기온은 2021년 자료가 없어서 co2에서 2021년 자료 삭제
co2

C <- ts(co2, start=1958, freq=1) # 시계열 자료로 처리
filtered_X <- ts(filtered_gt, start=1958, freq=1) # 시계열 자료로 처리

length(C) == length(filtered_X) # 크기가 같은지 확인

scaled_C = (C - min(C))/(max(C)-min(C)) # co2 자료 minMax scale을 통해 gt자료와 비교
layout(1)
ts.plot(filtered_X)
points(scaled_C-0.07, col=2) # minMax scaled co2 값

# 모델 적합
aic <- 1000
aic.temp <- aic
for(p in 0:4) for(q in 0:7)
{
  model_aic <- AIC(Arima(filtered_X, order = c(p,0,q), xreg = scaled_C))
  if (aic.temp > model_aic) {
    aic.temp <- model_aic
    cat('p =', p, 'q =', q, ' AIC = ', aic.temp, '\n')
  }
}

# AIC가 가장 낮은 (2,0,4) 선택
model_co2 <- Arima(filtered_X, order = c(2,0,4), xreg = scaled_C)
model_co2

# 추정치가 유의하지 않음

# p=0, q=6에서 모든 추정치가 유의하고 AIC가 가장 낮음
# 잠정모델로 결정
model_co2 <- Arima(filtered_X, order = c(0,0,6), xreg = scaled_C)
model_co2

# 잔차분석
model_co2_res <- model_co2$res

my_plot(model_co2_res)
# 그림 확인 결과 잔차가 W.N.라고 판단해도 괜찮아 보임
# SACF, SPACF확인결과 W.N. 라고 해도 괜찮아 보임

Box.test(model_co2_res, lag = 12, type = 'Ljung')
# 테스트 결과 h0를 기각하지 못함.
# 최종 모델로 결정

hat<-model_co2$fitted # 적합값(추정된 모형에 의해서 계산된 값)
layout(1)
ts.plot(filtered_X)
lines(hat, col="red", lty=2) # 적합값 그래프

# 연 평균 co2자료로 지구기온을 설명할 수 있다고 보여짐.






#######################################################
layout(1)
ts.plot(X)

# 차분
dX <- diff(X)
my_plot(dX)

# 3번 모형을 잠정 모형으로 예상했기 때문에 차분한 자료는 평균이 0이 아닌
# 정상 시계열이 기대됨
# 정상 시계열로 보임. 테스트가 필요해 보임
# SACF가 지수적으로 감소하고 PACF확인 결과 상관관계도 적어보임
# 평균이 0인 정상 시계열로 예상됨

# 평균이 0이 아닌 정상시계열로 적합
# drift가 있는 데이터의 경우 차분했을때 평균이 0이 아닌 정상시계열을 가짐

aic <- 1000
aic.temp <- aic
for(p in 0:5) for(q in 0:5)
{
  model_aic <- AIC(Arima(dX, order=c(p,0,q), include.mean = TRUE))
  if (aic.temp > model_aic) {
    aic.temp <- model_aic
    cat('p =', p, 'q =', q, ' AIC = ', aic.temp, '\n')
  }
}

# AIC 기준으로 ARIMA(2,0,5)를 선택
model <- Arima(dX, order=c(2,0,5), include.mean = TRUE)
model

# 평균이 유의한 값을 가지지 못함

# p,q 조정
aic <- 1000
aic.temp <- aic
for(p in 0:5) for(q in 0:7)
{
  model_aic <- AIC(Arima(dX, order=c(p,0,q), include.mean = TRUE))
  if (aic.temp > model_aic) {
    aic.temp <- model_aic
    cat('p =', p, 'q =', q, ' AIC = ', aic.temp, '\n')
  }
}

# AIC 기준으로 ARIMA(0,0,7)를 선택
model <- Arima(dX, order=c(0,0,7), include.mean = TRUE)
model

# 값이 유의하지 않음

# p,q 조정
model <- Arima(dX, order=c(0,0,4), include.mean = TRUE)
model

# p=0, q=3 일떄 모든 값이 유의함
# drift를 0.0071로 점추정


# 자료 적합
# drift와 trend를 포함하여 적합

model <- Arima(X, order = c(0,0,4), xreg=1:len(X)) 
model


# 모든 추정치가 유의함
# 위 모델을 잠정모델로 결정

# 잔차분석
res <- model$res

my_plot(res)
# 그림 확인 결과 잔차가 W.N.인지 잘 모르겠음
# SACF, SPACF확인결과 W.N. 라고 해도 괜찮아 보임

Box.test(res, lag = 10, type = 'Ljung')
# 테스트 결과 h0를 기각.

# 잔차가 W.N.로 판단되지 않아 AIC기준으로 원래 데이터에서 p, q 추정
aic <- 1000
aic.temp <- aic
for(p in 0:5) for(q in 0:7)
{
  model_aic <- AIC(Arima(X, order = c(p,0,q), xreg = 1:length(X)))
  if (aic.temp > model_aic) {
    aic.temp <- model_aic
    cat('p =', p, 'q =', q, ' AIC = ', aic.temp, '\n')
  }
}

# p=1, q=7 으로 확인됨

# 모델 적합
model <- Arima(X, order = c(1,0,7), xreg = 1:length(X)) 
model

# 값이 유의하지 않음
# 다시 적합
model <- Arima(X, order = c(1,0,6), xreg = 1:length(X)) 
model

# p=1, q=6에서 모든 값이 유의함
# 잠정모델로 결정

# 잔차분석
res <- model$res

my_plot(res)
# 그림 확인 결과 잔차가 W.N.라고 판단해도 괜찮아 보임
# SACF, SPACF확인결과 W.N. 라고 해도 괜찮아 보임

Box.test(res, lag = 12, type = 'Ljung')
# 테스트 결과 h0를 기각하지 못함.
# 최종 모델로 결정

hat<-model$fitted # 적합값(추정된 모형에 의해서 계산된 값)
layout(1)
ts.plot(X, xlim=c(0,180), ylim=c(-0.5,1.2))
lines(hat, col="red", lty=2) # 적합값 그래프

# 예측
fcast <- forecast(model, h=70, xreg=length(X)+1:70)
plot(fcast)
lines(hat, col="red", lty=2) # 적합값 그래프

######################
######################
# 적당한 drift로 연간 평균 co2 자료를 사용
# co2에 회귀 한다는 가정
gt <- read.csv('globalTemp.csv')
co2 <- read.csv('co2.csv', header = T)
head(co2)

filtered_gt <- gt[gt$Year>=1958,] # co2 데이터가 1958년 부터 존재
filtered_gt <- filtered_gt$Lowess.5.

length(filtered_gt)

my_plot(filtered_gt)


co2[,3]
co2 <- co2[,3] # 년간 평균 co2만 가져옴


length(co2)
length(filtered_gt)

co2 <- co2[-length(co2)]

co2

length(co2)
length(filtered_gt)

C <- ts(co2, start=1958, freq=1)
filtered_X <- ts(filtered_gt, start=1958, freq=1)

length(C) == length(filtered_X) # 크기가 같은지 확인

scaled_C = (C - min(C))/(max(C)-min(C))

layout(1)
ts.plot(filtered_X)
points(scaled_C-0.07, col=2) # minMax scaled co2 값

# 모델 적합
aic <- 1000
aic.temp <- aic
for(p in 0:5) for(q in 0:7)
{
  model_aic <- AIC(Arima(filtered_X, order = c(p,0,q), xreg = C))
  if (aic.temp > model_aic) {
    aic.temp <- model_aic
    cat('p =', p, 'q =', q, ' AIC = ', aic.temp, '\n')
  }
}

model2 <- Arima(filtered_X, order = c(0,0,6), xreg = C) 
model2

hat<-model2$fitted # 적합값(추정된 모형에 의해서 계산된 값)
layout(1)
ts.plot(filtered_X)
lines(hat, col="red", lty=2) # 적합값 그래프


model
model2
# 원래 모델이 더 좋아보임

# 최종 모델
model
fcast <- forecast(model, h=70, xreg=length(X)+1:70)
plot(fcast)
