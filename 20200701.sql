DECODE : 조건에 따라 반호한 값이 달라지는 함수
 ==> 비교 ,JAVA (if) , SQL - case와 비슷
 단 비교연산이(=)만 가능
 CASE의 WHEN절에 기술 할 수 있는 코드는 참 거짓 판단할 수있는 코드면 가능
 ex : sal > 1000
 이것과 다르게 DECODE 함수에서는 sal = 100, sal = 2000
 DECODE는 가변인자(인자의 갯수가 정해지지 않음, 상황에 따라 늘어 날 수도 있다)를 갖는 함수
 문법 : DECODE(기준값[col|expression] , 
                비교값1, 반환값1,
                비교값2, 반환값2,
                ......
              
                
  옵션[기준값이 비교값 중에 일치하는 값이 없을 때 기본적으로 반환할 때]                
--java식 표현
if(기준값 == 비교값1)
반환값 1을 반환해준다
 else if (기준값 == 비교값2)
반환값 2을 반환해준다
else if (기준값 == 비교값3)
반환값 3을 반환해준다
else 
마지막 인자가 있을경우 마지막 인자를 반환하고
마지막 인자가 없을 경우 null을 반환

CASE보다는 DECODE 가독성이 더 낫다

어제 작성한 위의 SQL을 DECODE
SELECT empno, ename,deptno,
        DECODE (deptno, '10', 'ACCOUNTING',
                '20', 'RESEARCH',
                '30','SALES',
                '40', 'OPERATIONS',
                'DDIT') dename
FROM  emp;

SELECT ename,job, sal,
        DECODE (job, 'SALESMAN', sal * 1.05,
                'MANAGER', sal * 1.10,
                'PRESIDENT',sal * 1.20,
                sal * 1) bonus
FROM  emp;

Q) 위의 문제처럼 job에 따라 sal를 인상을 한다
단 추가조건으로 job이 MANAGER이면서 소속부서(deptno)가 30(SALES)이면 sal * 1.5
SELECT ename, job, sal, deptno,
        CASE
         WHEN job = 'SALESMAN' THEN sal * 1.05
          WHEN job = 'MANAGER' AND  deptno = 30 THEN sal * 1.5
         WHEN job = 'MANAGER' THEN sal * 1.10
         WHEN job = 'PRESIDENT' THEN sal * 1.20
         ELSE sal * 1
        END dname
FROM emp; 

응용(CASE의 중첩)
SELECT ename, job, sal, deptno,
        CASE
         WHEN job = 'SALESMAN' THEN sal * 1.05
         WHEN job = 'MANAGER' THEN 
                                    CASE
                                        WHEN deptno = 30  THEN sal * 1.5
                                        ELSE sal * 1.1
                                    END
         WHEN job = 'PRESIDENT' THEN sal * 1.20
         ELSE sal * 1
        END dname
FROM emp; 
Q)DECODE를 이용해서 풀기
SELECT ename, job, sal, deptno,
     DECODE(job, 
                'SALESMAN', sal * 1.05, 
                'MANAGER',  DECODE(deptno, 30, sal * 1.5, sal * 1.01),
                'PRESIDENT',sal * 1.20,
                sal * 1) dename
FROM emp;

Q)실습 emp테이블의 입사일자를 가지고 건강검진 대상자인지 조회한다
1. 해당사원이 홀수 입산지 짝수 입산지

==> 짝수 2로 나눴을 때 나머지가 항상 0
==> 홀수 2로 나눴을 때 나머지가 항상 1
==> 함수 MOD 이용
어떤수 X로 나눈 나머지는 항상 0~X-1
 TO_CHAR(hiredate, 'YYYY') = 홀수
  TO_CHAR(hiredate, 'YYYY') 짝수
 
SELECT empno, ename, hiredate,
     DECODE(MOD(TO_CHAR(hiredate, 'YYYY'), 2), 
            MOD(TO_CHAR(sysdate, 'YYYY'), 2), '건강검진 대상자',
            '건강검진 비대상자') CONTACT_TO_DOCTOR
FROM emp;
Q)실습 cond3
SELECT userid, usernm, alias, reg_dt,
        DECODE(MOD(TO_CHAR(reg_dt, 'YYYY'), 2), 
            MOD(TO_CHAR(sysdate, 'YYYY'), 2), '건강검진 대상자',
            '건강검진 비대상자') CONTACT_TO_DOCTOR
FROM users;

--DECODE 해석 :첫번쨰 인자가 두번째 인자와 같으면 세번째 인자를 반환하고 그렇지 않으면 네번째 인자를 반환한다

---새로 만든 행 삭제하는법---
DELETE emp
WHERE empno =9999;
COMMIT;


<그룹함수>
:여러개의 행을 입력으로 받아서 하나의 행으로 결과를 리턴하는 함수
SUM : 합계
COUNT :행의수
AVG : 평균
MAX :그룹에서 가장 큰 값
MIN :그룹에서 가장 작은 값

사용방법 :

SELECT 행들을 묶은기준1, 행들을 묶을 기준2, 그룹함수
FROM 테이블
[WHERE]
GROUP BY : 행들을 묶은기준1, 행들을 묶을 기준2

으용1
부서번호별 sal 컬럼의 값
==> 부서번호가 같은 행들을 하나의 행으로 만든다
SELECT deptno, SUM(sal)
FROM emp
GROUP BY deptno;

응용2
부서번호별 가장 큰 급여를 받는사람 급여 액수
SELECT deptno, SUM(sal), MAX(sal)
FROM emp
GROUP BY deptno;

응용3
부서번호별 가장 작은 급여를 받는사람 급여 액수
SELECT deptno, SUM(sal), MAX(sal), MIN(sal)
FROM emp
GROUP BY deptno;

응용4
부서번호별 급여 평균액수
SELECT deptno, SUM(sal), MAX(sal), MIN(sal),ROUND(AVG(sal),2)
FROM emp
GROUP BY deptno;

응용5
부서번호별 급여가 존재하는 사람의 수(sal 컬럼의 값이 null이 아닌 행의 수)
    * : 그 그룹의 행수 
SELECT deptno, SUM(sal), MAX(sal), ROUND(AVG(sal),2), COUNT(sal),COUNT(*),
FROM emp
GROUP BY deptno;

응용6
SELECT deptno, SUM(sal), MAX(sal), ROUND(AVG(sal),2),
        COUNT(sal),COUNT(comm),COUNT(*)
        --sal과 comm값이 다른것을 볼수 있다(NULL값때문에)
FROM emp
GROUP BY deptno;

그룹함수의 특징 1 : NULL값을 무시
30번 부서의 사원 6명 중 2명은 comm 값이 NULL
SELECT deptno, SUM(comm)
FROM emp
GROUP BY deptno;

그룹함수의 특징 2 : GROUP BY를 적용 여러행을 하나의 행으로 묶게 되면은
                SELECT 절에 기술 할 수 있는 컬럼이 제한됨
               ==> SELECT절에 기술되는 일반 컬럼들은 (그룹 함수를 적용하지 않은)
               반드시 GROUP BY절에 기술 되어야 한다
               ==>그룹함수 이해하기 힘들다 ==>엑셀에 데이터를 그려보자
               단 그룹필에 영향을 주지 않는 고정된 상수, 함수는 기술 가능하다
               
SELECT deptno, SUM(sal)
FROM emp
GROUP BY deptno;

SELECT deptno, ename, SUM(sal)
FROM emp
GROUP BY deptno;
--조회 하면 GROUP BY의 표현이 아니라는 에러가 나온다

SELECT deptno,MAX( ename), SUM(sal)
FROM emp
GROUP BY deptno;
--enam이 알파벳순으로 가장 큰 값 조회

SELECT deptno, ename , SUM(sal)
FROM emp
GROUP BY deptno, ename;
--실질적으로 모든 값이 적용된다

컬럼 값에 상수, 함수를 를 줬을때 ==> 그룹핑에 영향을 주지 않는다
SELECT deptno, 10 , SYSDATE, SUM(sal)
FROM emp
GROUP BY deptno;

그룹함수의 특징 3 : 일반 함수를 WHERE절에서 사용하는게 가능
                    WHERE UPPER('smith') = 'SMITH'
                    그룹함수의 경우 WHERE 절에 기술하여 동일한 결과를 나타낼 수 있다
                    하지만 HAVING 절에 기술하여 동일한 결과를 나타낼 수 있다
응용
SUM(sal)값이 9000보다 큰 행들만 조회

SELECT deptno, SUM(sal)
FROM emp
WHERE SUM(sal)>9000
GROUP BY deptno;      
---조회되지 않는다

SELECT deptno, SUM(sal)
FROM emp
GROUP BY deptno
HAVING SUM(sal)>9000;

위의 쿼리를 HAVING절 없이 SQL작성
SELECT *
FROM(SELECT deptno, SUM(sal) sum_sal
    FROM emp
    GROUP BY deptno)
WHERE sum_sal >9000;

<SELECT 쿼리 문법 총정리>
SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY

GROUP BY 절에 행을 그룹핑할 기준을 작성
EX ; 부서번호별 그룹을 만들경우
    GROUP BY deptno
    
전체행을 기준으로 그룹핑을 하려면 GROUP BY 절에 어떤 컬럼을 기술할까?
emp테이블에 등록된 14명의 사원 전체의 급여 합계를 구하려면? ==>결과는 하나의 행
==> GROUP BY 절을 기술하지 않는다
SELECT SUM(sal)
FROM emp;

==>GROUP BY 절에 기술한 컬럼을 SELECT 절에 기술을 안하면?? ==> 결과는 조회된다 
SELECT SUM(sal)
FROM emp
GROUP BY deptno;

그룹함수의 제한사항
부서번호별 가장 높은 급여를 받는 사람의 급여액
그래서 높은 급여를 받는 사람이 누구냐??--GROUP BY에서 구할 수 없다 ==> 서브쿼리, 분석함수에서 구할 수 있다
SELECT deptno, MAX(sal) 
FROM emp
GROUP BY deptno;








