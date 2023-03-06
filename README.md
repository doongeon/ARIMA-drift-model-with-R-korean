# yearly-average-global-temperature-analysis

global_temp
donggeon
2022-12-08
https://www.youtube.com/watch?v=JITO5-bYxu8 참고한 자료
 - arima with drift
 
data
  Year No_Smoothing Lowess.5.
1 1880        -0.17     -0.10 \n
2 1881        -0.09     -0.13
3 1882        -0.11     -0.17
4 1883        -0.18     -0.20
5 1884        -0.28     -0.24
6 1885        -0.33     -0.26


visualization
![image](https://user-images.githubusercontent.com/87890694/223017666-6deb74e7-aa4d-46cc-888b-39179151bd26.png)



check ACF, PACF
![image](https://user-images.githubusercontent.com/87890694/223017814-8036de75-e68f-41a9-84e1-43c033055f0a.png)


단위근 검정
adf.test(X)
 Augmented Dickey-Fuller Test 
 alternative: stationary 
  
 Type 1: no drift no trend 
      lag   ADF p.value
 [1,]   0 4.722   0.990
 [2,]   1 0.226   0.708
 [3,]   2 0.858   0.889
 [4,]   3 1.497   0.965
 [5,]   4 1.229   0.942
 Type 2: with drift no trend 
      lag   ADF p.value
 [1,]   0 4.373   0.990
 [2,]   1 0.227   0.973
 [3,]   2 0.914   0.990
 [4,]   3 1.649   0.990
 [5,]   4 1.499   0.990
 Type 3: with drift and trend 
      lag    ADF p.value
 [1,]   0 -1.167   0.909
 [2,]   1 -2.114   0.525
 [3,]   2 -1.401   0.825
 [4,]   3 -1.050   0.927
 [5,]   4 -0.786   0.961
 ---- 
 Note: in fact, p.value = 0.01 means p.value <= 0.01
adf test 결과 모든 타입에서 H0를 기각하지 못함
시계열 자료의 그림이 이차곡선으로 생각된다
3가지 타입의 모형이 모두 가능하지만, 지수적으로 증가한다고 판단
  -> 잠정 모형
    with drift and trend 
    
모형 : pi(B) * (1-B)^d * (Y.t - mu) = d + theta(B) * W.t


aic 기준으로 p,q 선정
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
 p = 0 q = 0  AIC =  -121.656 
 p = 0 q = 1  AIC =  -297.6549 
 p = 0 q = 2  AIC =  -458.9174 
 p = 0 q = 3  AIC =  -561.3216 
 p = 0 q = 4  AIC =  -665.525 
 p = 0 q = 5  AIC =  -691.9151 
 p = 0 q = 6  AIC =  -748.1238 
 p = 0 q = 7  AIC =  -786.9604 
 p = 1 q = 2  AIC =  -841.8223 
 p = 1 q = 3  AIC =  -849.1681 
 p = 1 q = 4  AIC =  -852.0681 
 p = 1 q = 5  AIC =  -864.0042 
 p = 1 q = 6  AIC =  -872.6625 
 p = 1 q = 7  AIC =  -879.3751
AIC가 가장 낮은 (1,0,7) 선택

추정치가 유의하지 않음
fit <- Arima(X, order = c(1,0,7), xreg = 1:length(X))
fit
## Series: X 
## Regression with ARIMA(1,0,7) errors 
## 
## Coefficients:
##          ar1     ma1     ma2     ma3     ma4     ma5     ma6      ma7
##       0.9770  0.9433  1.0485  0.8675  0.9506  0.5279  0.0323  -0.2991
## s.e.  0.0202  0.0901  0.1259  0.1645  0.1766  0.1644  0.1345   0.0937
##       intercept    xreg
##         -0.2976  0.0071
## s.e.     0.2264  0.0022
## 
## sigma^2 = 9.906e-05:  log likelihood = 450.69
## AIC=-879.38   AICc=-877.34   BIC=-846.86
p=1, q=6 일때 추정치가 모두 유의하고 AIC가 가장 낮음
잠정모델로 결정


fit <- Arima(X, order = c(1,0,6), xreg = 1:length(X))
fit
## Series: X 
## Regression with ARIMA(1,0,6) errors 
## 
## Coefficients:
##          ar1     ma1     ma2     ma3     ma4     ma5     ma6  intercept    xreg
##       0.9375  1.0977  1.3177  1.2226  1.2871  0.9214  0.3933    -0.3845  0.0073
## s.e.  0.0353  0.1025  0.1401  0.1726  0.1789  0.1454  0.1080     0.1559  0.0017
## 
## sigma^2 = 0.0001076:  log likelihood = 446.33
## AIC=-872.66   AICc=-870.98   BIC=-843.1


잔차분석
res <- fit$res

layout(1)
ts.plot(res)


layout(t(1:2))
acf(res)
pacf(res)


그림 확인 결과 잔차가 W.N.라고 판단해도 괜찮아 보임
SACF, SPACF확인결과 W.N. 라고 해도 괜찮아 보임
Box.test(res, lag = 12, type = 'Ljung')
## 
##  Box-Ljung test
## 
## data:  res
## X-squared = 8.862, df = 12, p-value = 0.7147
테스트 결과 h0를 기각하지 못함.
최종 모델로 결정
hat<-fit$fitted # 적합값(추정된 모형에 의해서 계산된 값)
layout(1)
ts.plot(X)
lines(hat, col="red", lty=2) # 적합값 그래프


예측
fcast <- forecast(fit, xreg = length(X)+1:60)
plot(fcast)
lines(hat, col="red", lty=2) # 적합값 그래프


co2에 회귀 한다는 가정
적당한 drift로 연간 평균 co2 자료를 사용
gt <- read.csv('globalTemp.csv')
co2 <- read.csv('co2.csv', header = T)
head(co2)
##   X year average
## 1 0 1958  315.23
## 2 1 1959  315.98
## 3 2 1960  316.91
## 4 3 1961  317.64
## 5 4 1962  318.45
## 6 5 1963  318.99
filtered_gt <- gt[gt$Year>=1958,] # co2 데이터가 1958년 부터 존재
filtered_gt <- filtered_gt$Lowess.5.
자료 확인
layout(1)
ts.plot(co2[,3])


co2 <- co2[,3] # 년간 평균 co2만 가져옴
co2 <- co2[-length(co2)] # 평균기온은 2021년 자료가 없어서 co2에서 2021년 자료 삭제

C <- ts(co2, start=1958, freq=1) # 시계열 자료로 처리
filtered_X <- ts(filtered_gt, start=1958, freq=1) # 시계열 자료로 처리
length(C) == length(filtered_X) # 크기가 같은지 확인
## [1] TRUE
# co2 자료 minMax scale을 통해 gt자료와 비교

scaled_C = (C - min(C))/(max(C)-min(C)) 
비슷하게 움직인다고 생각됨
layout(1)
ts.plot(filtered_X)
points(scaled_C-0.07, col=3, pch=3) # minMax scaled co2 값


모델 적합
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
## p = 0 q = 0  AIC =  -238.5852 
## p = 0 q = 1  AIC =  -300.179 
## p = 0 q = 2  AIC =  -350.8487 
## p = 0 q = 3  AIC =  -363.4132 
## p = 0 q = 4  AIC =  -370.1516 
## p = 0 q = 5  AIC =  -384.956 
## p = 0 q = 6  AIC =  -390.3506 
## p = 2 q = 4  AIC =  -390.4643
AIC가 가장 낮은 (2,0,4) 선택
추정치가 유의하지 않음
model_co2 <- Arima(filtered_X, order = c(2,0,4), xreg = scaled_C)
model_co2
## Series: filtered_X 
## Regression with ARIMA(2,0,4) errors 
## 
## Coefficients:
##          ar1      ar2     ma1     ma2     ma3     ma4  intercept    xreg
##       1.1818  -0.5213  0.2485  0.5356  0.5301  0.7084    -0.0723  1.0182
## s.e.  0.1365   0.1363  0.1451  0.1017  0.1443  0.1558     0.0169  0.0330
## 
## sigma^2 = 9.837e-05:  log likelihood = 204.23
## AIC=-390.46   AICc=-387.13   BIC=-371.03
p=0, q=6에서 모든 추정치가 유의하고 AIC가 가장 낮음
잠정모델로 결정
model_co2 <- Arima(filtered_X, order = c(0,0,6), xreg = scaled_C)
model_co2
## Series: filtered_X 
## Regression with ARIMA(0,0,6) errors 
## 
## Coefficients:
##          ma1     ma2     ma3     ma4     ma5     ma6  intercept    xreg
##       1.4345  1.6877  1.6460  1.7496  1.3315  0.7163    -0.0688  1.0125
## s.e.  0.1115  0.1883  0.1928  0.2126  0.2040  0.1788     0.0175  0.0332
## 
## sigma^2 = 9.818e-05:  log likelihood = 204.18
## AIC=-390.35   AICc=-387.02   BIC=-370.92
잔차분석
model_co2_res <- model_co2$res

layout(1)
ts.plot(model_co2_res)


layout(t(1:2))
acf(model_co2_res)
pacf(model_co2_res)


그림 확인 결과 잔차가 W.N.라고 판단해도 괜찮아 보임
SACF, SPACF확인결과 W.N. 라고 해도 괜찮아 보임
Box.test(model_co2_res, lag = 12, type = 'Ljung')
## 
##  Box-Ljung test
## 
## data:  model_co2_res
## X-squared = 3.7013, df = 12, p-value = 0.9882
테스트 결과 h0를 기각하지 못함.
최종 모델로 결정
hat<-model_co2$fitted # 적합값(추정된 모형에 의해서 계산된 값)
layout(1)
ts.plot(filtered_X)
lines(hat, col="red", lty=2) # 적합값 그래프


연 평균 co2자료로 지구기온을 설명할 수 있다고 보여짐.
