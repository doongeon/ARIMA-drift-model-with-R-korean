# Annual average global temperature analysis

## global_temp

donggeon
2022-12-08

참고한 자료
 - https://www.youtube.com/watch?v=JITO5-bYxu8 ( arima with drift )
 

자료 확인
![image](https://user-images.githubusercontent.com/87890694/223037491-38020e78-110f-4f43-bff2-60613a51b901.png)

ACF, PACF 확인
![image](https://user-images.githubusercontent.com/87890694/223037534-63cb9172-73cf-4592-8643-1ea12e25dc46.png)
ACF가 천천히 감소하는 모습을 보인다. 확률 보행의 양상을 보임
단위근이 있다고 판단하여 ADF-test를 진행하여 적절한 모델을 찾기로 함

ADF-test
![image](https://user-images.githubusercontent.com/87890694/223038091-90348560-8f90-49fa-ba5d-c9f2af46d536.png)

adf test 결과 모든 타입에서 H0를 기각하지 못하였고
자료가 지수적으로 증가하고 있는 모습으로 보임
 - 가능한 모형
    - no drift, no trend
    - with drigt, no trend
    - with drift and trend
지수적으로 증가한다고 판단하여, 3번 모델로 적합하기로 함
모형 : $pi(B) * (1-B)^d * (Y.t - mu) = d + theta(B) * W.t$
