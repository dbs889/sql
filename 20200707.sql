시도, 시군구별, 햄버거 도시발전지수 ==> (KFC+버거킹+멕도날드)/롯데리아
한행에 다음과 같이 컬럼이 구성되면 공식을 쉽게 적용 할 수 있다
시도, 시군구, KFC개수 ,버거킹개수, 맥도날드 개수, 롯데리아 개수
주어진 것: 점포 하나 하나의 주소

1. 시도, 시군구 ,프렌차이즈 별로 GROUP BY * 4

    1.1시도, 시군구, KFC개수
    1.2 시도, 시군구, 버거킹개수
    1.3 시도, 시군구, 맥도날드개수
    1.4 시도, 시군구, 롯데리아개수

1.1~1.4 4개의 데이터셋을 이용해서 컬럼 확장이 가능 ==> JOIN
시도, 시군구 같은 데이터끼리 조인

2. 시도, 시군구 ,프렌차이즈 별로 GROUP BY * 2
    2.1 시도, 시군구, 분자 프렌차이즈 합 개수
    2.2  시도, 시군구, 분자 프렌차이즈(롯데리아) 합 개수

2.1~2.2 2개의 데이터셋을 이용해서 컬럼 확장이 가능 ==> JOIN
시도, 시군구 같은 데이터끼리 조인

3.모든 프렌차이즈를 한번만 읽고서 처리하는 방법 -----실무에서 많이 쓰이는 패턴이다
    3.1 fastfood 테이블의 한 행은 하나의 프렌차이즈에 속함
    3.2 가상의 컬럼을 4개를 생성
       3.2.1 해당 row가 kfc 면 1
       3.2.2 해당 row가 맥도날드 면 1
       3.2.3 해당 row가 버거킹 면 1
       3.2.3 해당 row가 롯데리아 면 1
       
       3.2 과정에서 생성된 컬럼 4개 중에 값이 존재하는 컬럼은 하나만 존재함
            (하나의 행은 하나의 프랜차이즈의 주소를 나타내는 정보)
            
        3.3 시도, 시군구 별로 3.2과정에서 생성한 컬럼을 더하면 우리가 구하고자 하는 
            프렌차이즈별 건수가 된다
        
--맘스터치 일 경우 NULL로 조회된다          
SELECT sido,sigungu,gb, 
       SUM(DECODE(gb, 'KFC', 1)), SUM(DECODE(gb, '버거킹', 1)), 
        SUM(DECODE(gb, '맥도날드', 1)), SUM(DECODE(gb, '롯데리아', 1))
FROM fastfood
WHERE gb IN('KFC','버거킹','맥도날드','롯데리아')
GROUP BY sido, sigungu;

SELECT *
FROM burgerstore;

SELECT sido,sigungu,
       ROUND((NVL(SUM(DECODE(storecategory, 'KFC', 1)),0)+
       NVL(SUM(DECODE(storecategory, 'BURGER KING', 1)),0) +
       NVL(SUM(DECODE(storecategory, 'MACDONALD', 1)),0)) /
       NVL(SUM(DECODE(storecategory, 'LOTTERIA', 1)),1) ,2)score
FROM  burgerstore
WHERE storecategory IN('KFC','BURGER KING','MACDONALD','LOTTERIA')
GROUP BY sido, sigungu
ORDER BY score DESC;


SELECT storecategory
FROM burgerstore
GROUP BY storecategory;


SELECT *
FROM tax;

도시발전순위, 햄버거 발전지수 시도 ,햄버거 발전지수 시군구, 햄버거 발전지수,
근로소득순위, 근로 소득 시도, 근로소득 시군구, 1인당 근로 소득액
같은 순위끼리 하나의 행에 데이터가 보여지도록
1. 서울 강남수 6.4 1. 울산 동구 80

SELECT ROWNUM rn,sido,sigungu,score
FROM
(SELECT sido,sigungu,
       ROUND((NVL(SUM(DECODE(storecategory, 'KFC', 1)),0)+
       NVL(SUM(DECODE(storecategory, 'BURGER KING', 1)),0) +
       NVL(SUM(DECODE(storecategory, 'MACDONALD', 1)),0)) /
       NVL(SUM(DECODE(storecategory, 'LOTTERIA', 1)),1) ,2)score
FROM  burgerstore
WHERE storecategory IN('KFC','BURGER KING','MACDONALD','LOTTERIA')
GROUP BY sido, sigungu
ORDER BY score DESC);

--RPWNUM하기전에 ORDER BY를 정렬하고  
SELECT ROWNUM rn,sido,sigungu,psal
FROM
(SELECT sido,sigungu,ROUND(sal/people,2) psal
FROM tax
ORDER BY psal DESC);


선생님답
SELECT buger.*,tax.*
FROM
(SELECT ROWNUM rn,sido,sigungu,score
FROM
(SELECT sido,sigungu,
       ROUND((NVL(SUM(DECODE(storecategory, 'KFC', 1)),0)+
       NVL(SUM(DECODE(storecategory, 'BURGER KING', 1)),0) +
       NVL(SUM(DECODE(storecategory, 'MACDONALD', 1)),0)) /
       NVL(SUM(DECODE(storecategory, 'LOTTERIA', 1)),1) ,2)score
FROM  burgerstore
WHERE storecategory IN('KFC','BURGER KING','MACDONALD','LOTTERIA')
GROUP BY sido, sigungu
ORDER BY score DESC) )buger,
(SELECT ROWNUM rn,sido,sigungu,psal
FROM
(SELECT sido,sigungu,ROUND(sal/people,2) psal
FROM tax
ORDER BY psal DESC))tax
WHERE buger.rn(+) = tax.rn
ORDER BY tax.rn;


유네답
SELECT bu.sido,bu.sigungu, bu.score,ta.sido,ta.sigungu, ta.psal
FROM
(SELECT sido,sigungu,ROUND(avg(sal/people),2)psal
FROM tax
GROUP BY sido, sigungu)ta,

(SELECT sido,sigungu,
       ROUND((NVL(SUM(DECODE(storecategory, 'KFC', 1)),0)+
       NVL(SUM(DECODE(storecategory, 'BURGER KING', 1)),0) +
       NVL(SUM(DECODE(storecategory, 'MACDONALD', 1)),0)) /
       NVL(SUM(DECODE(storecategory, 'LOTTERIA', 1)),1) ,2)score
FROM  burgerstore
WHERE storecategory IN('KFC','BURGER KING','MACDONALD','LOTTERIA')
GROUP BY sido, sigungu) bu

WHERE ta.sigungu = bu.sigungu;


<CROSS JOIN> --묻지마 조인
: 테이블간 조인 조건을 기술하지 않는 형태로 두 테이블의 행간 모든 가능한 조합으로 조인이 되는 형태
    - 크로스 조인의 조회 결과를 필요로 하는 메뉴는 거의 없음
    but *SQL의 중간 단계(테이블 복제를 위해 사용)에서 필요한 경우는 존재
emp : 14
dept : 4
결과 ; 56 (emp테이블 *dept테이블)
원래 하려던 것  : emp에 있는 부서번호를 이용하여 dept 쪽에 있는 dname, loc컬럼을 가져오는 것

SELECT e.empno, e.ename, e.deptno, d.dname, d.loc
FROM emp e,dept d;
--WHERE e.deptno, d.deptno;

ANSI-SQL CROSS JOIN
SELECT e.empno, e.ename, e.deptno, d.dname, d.loc
FROM emp e CROSS JOIN dept d;

SELECT e.empno, e.ename, e.deptno, d.dname, d.loc
FROM emp e JOIN dept d ON (1=1);

ORACLE-SQL CROSS JOIN
SELECT e.empno, e.ename, e.deptno, d.dname, d.loc
FROM emp e,dept d;

실습 1 ---없는정보가 존재하는 정보와 결합하여 모든 조인이 조회된다 / 조건절 기술이 필요 없다

유네답
SELECT c.cid, c.cnm, p.pid, p.pnm
FROM customer c,product p;

선생님답
SELECT *
FROM customer c,product p;

<서브쿼리>
:SQL 내부에서 사용된 SQL(MAIN 쿼리에서 사용된 쿼리)

-사용위치에 따른 분류
1. SELECT 절에서 사용 : scalar(단일의) subquery
2.FEOM 절에서 사용 : INLINE-VIEW
3. WHERE절에서 사용  : subquery

- 반환하는 행, 컬럼수에 따라 분류
1. 단일행, 단일 컬럼
2. 단일행, 복수 컬럼
3. 다중행, 단일 컬럼
4. 다중행, 복수 컬럼

-서브쿼리에서 메인쿼리의 컬럼을 사용유무에 따른 분류
1. 서브쿼리에서 메인쿼리의 컬럼 사용 : correlated subquery ==>상호 연관 서브쿼리
                ==>서브쿼리 단독으로 실행하는 것이 불가능
2. 서브쿼리에서 메인쿼리의 컬럼 미사용 :non correlated subquery ==>비상호 연관 서브 쿼리
                ==> 서브쿼리 단독으로 실행하는 것이 가능
                
                
Q) SMISTH 사원이 속한 부서에 속하는 사원은 누가 있을까?

2개의 쿼리가 필요
1. smith가 속한 부서의 번호를 확인하는 쿼리
2. 1번에서 확인한 부서번호로 해당 부서에 속하는 사원들을 조회하는 쿼리

1.
SELECT deptno
FROM emp
WHERE ename ='SMITH';
2.
SELECT *
FROM emp
WHERE deptno ='20';

SMITH가 현재 상황에서 속한 부서는20번인데
나중에 30번 부서로 부서 전배가 이뤄지면
2번에서 작성한 쿼리가 수정이 되야한다
WHERE deptno ='20'; ==> WHERE deptno ='30';

우리가 원하는 것은 고정된 부서번호로 사원 정보를 조회하는 것이 아니라
SMITH가 속한 부서를 통해 데이터를 조회 ==> SMITH가 속한 부서가 바뀌더라도 쿼리를 수정하지 않도록 하는 것


위에서 작성한 쿼리를 하나로 합친다
==> SMITH의 부서번호가 변경되더라도 우리가 원하는 데이터 셋을
    쿼리 수정 없이 조회할 수 있다 ==> 코드 변경이 필요 없다 ==> 유지보수가 편하다
SELECT * ---MAIN QUERY
FROM emp
WHERE deptno =(SELECT deptno
                FROM emp
                WHERE ename ='SMITH'); --비상호서브쿼리
                --()의 결과 값은 '20'과 같다
                --SMITH가 부서이동 할 수 있다는 전제하에   
                --서브쿼리는 WHERE절에 쓰인다
                
                
1. 스칼라 서브쿼리 : SELECT 절에서 사용된 서브 쿼리
*제약사항 : 반드시 서브쿼리가 하나의 행, 하나의 컬럼을 반환 해야한다

스칼라 서브쿼리가 다중행 복수컬럼을 리턴하는 경우(x)
SELECT empno,ename,(SELECT deptno, dname FROM dept WHERE deptno =10)
FROM emp;

스칼라 서브쿼리가 단일행 복수컬럼을 리턴하는 경우(x)
SELECT empno,ename,(SELECT deptno, dname FROM dept WHERE deptno =10)
FROM emp;

스칼라 서브쿼리가 단일행 단일컬럼을 리턴하는 경우(o)
SELECT empno,ename,
    (SELECT deptno FROM dept WHERE deptno =10) deptno, --비상호 서브쿼리
    (SELECT dname FROM dept WHERE deptno =10) dename 
FROM emp;

메인쿼리의 컬럼을 사용하는 스칼라 서븤쿼리
SELECT empno,ename,deptno,
        (SELECT deptno FROM dept WHERE deptno = emp.deptno) dename --상호 서브쿼리
FROM emp;

SELECT dename
FROM dept
WHERE deptno = 10;

IN-LINE VIEW 그동안 많이 사용

SUBQUERY :WHERE 절에서 사용된 것
SMITH가 속한 부서에 속하는 사원들 조회
WHERE 절에서 서브쿼리 사용시 주의점
연산자와, 서브쿼리의 반환 행수 주의
= 연산자를 사용시 서브쿼리에서 여러개 행(값)을 리턴하면 논리적으로 맞지가 않는다
IN 연산자를 사용시 서브쿼리에서 리턴하는 여러개 행(값)을 비교가 가능 

SELECT *
FROM emp
WHERE deptno =(SELECT deptno
                FROM emp
                WHERE ename IN ('SMITH','ALLEN'));
---에러가 나온다
SELECT *
FROM emp
WHERE deptno IN (SELECT deptno
                FROM emp
                WHERE ename IN ('SMITH','ALLEN'));
--실행이 된다


실습 1
1. 평균 급여 구하기
SELECT AVG(sal)
FROM emp;

SELECT COUNT(*)
FROM emp
WHERE sal >2073.21;

SELECT COUNT(*)
FROM emp
WHERE sal >(SELECT AVG(sal)
            FROM emp);
실습2
SELECT *
FROM emp
WHERE sal >(SELECT AVG(sal)
            FROM emp);
