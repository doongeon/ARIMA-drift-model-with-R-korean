# ARIMA-drift-model-with-R-korean
## 드리프트가 있는 ARIMA 모델 
![image](https://user-images.githubusercontent.com/87890694/223041830-62179b7f-ac4a-4080-bd27-374b467cfa2c.png)

donggeon
2022-12-08

참고한 자료
 - https://www.youtube.com/watch?v=JITO5-bYxu8 ( arima with drift )

분석내용은 코드에 더 자세히 설명되어 있습니다.
 
### 분석

- 자료 확인

![image](https://user-images.githubusercontent.com/87890694/223037491-38020e78-110f-4f43-bff2-60613a51b901.png)



- ACF, PACF 확인

![image](https://user-images.githubusercontent.com/87890694/223037534-63cb9172-73cf-4592-8643-1ea12e25dc46.png)

ACF가 천천히 감소하는 모습을 보인다. 확률 보행의 양상을 보임

단위근이 있다고 판단하여 ADF-test를 진행하여 적절한 모델을 찾기로 함



- ADF-test


![image](https://user-images.githubusercontent.com/87890694/223038091-90348560-8f90-49fa-ba5d-c9f2af46d536.png)

adf test 결과 모든 타입에서 H0를 기각하지 못하였고,

자료가 지수적으로 증가하고 있는 모습으로 보임

 - 가능한 모형
    - no drift, no trend
    - with drigt, no trend
    - with drift and trend
    
지수적으로 증가한다고 판단하여, 3번 모델로 적합하기로 함

모형 : $Φ(B) * (1-B)^d * (Y_t - mu) = d + θ(B) * W_t$


AIC를 기준으로 $p, q$를 선정

![image](https://user-images.githubusercontent.com/87890694/223039713-cce446aa-ce83-451d-950c-7c8641abb29a.png)


AIC가 가장 낮은 (1, 0, 7) 선택 (p,d,q)

![image](https://user-images.githubusercontent.com/87890694/223040010-2fa059e3-60bb-464e-b064-da627b067a5d.png)

추정치가 유의하지 않아 $p, q$를 다시 조정

$p=1, q=6$ 일때 추정치가 모두 유의하고 AIC가 가장 낮음. 잠정모델로 결정

![image](https://user-images.githubusercontent.com/87890694/223040186-2298b357-9a74-4b1b-ba39-e306b3d54321.png)


### 잔차분석

- 잔차그림

![image](https://user-images.githubusercontent.com/87890694/223041104-e71f57fa-6bb3-4cfe-80f4-8f64e81bb783.png)

- 잔차의 ACF, PACF

![image](https://user-images.githubusercontent.com/87890694/223041140-83a9388f-b257-43fc-ace2-97fd88e608f3.png)

그림 확인 결과 잔차가 W.N.라고 판단해도 괜찮아 보인다

SACF, SPACF도 W.N.의 모습을 보인다.

- Ljung–Box test
 
![image](https://user-images.githubusercontent.com/87890694/223041454-46b6799f-dc8b-465e-ba53-8312f0fcedbd.png)

박스 테스트 결과 $H_0$를 기각하지 못함. ($H_0$ : The data are independently distributed)

최종 모델로 결정

최종모델의 추정치

![image](https://user-images.githubusercontent.com/87890694/223041775-320715be-e4ea-47ba-9ed4-3ddcf497eddd.png)







