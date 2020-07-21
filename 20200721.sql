확장된 group by
==> 서브 그룹을 자동으로 생성
만약 이런 구문이 없다면 개발자가 직접 SELECT 쿼리를 여러개 작성해서 
UNION ALL을 시행 ==> 동일한 테이블을 여러번 조회 ==> 성능 저하

1. ROLLUP
    1-1. ROLLUP 절에 기술한 컬럼을 오른쪽에서 부터 지워나가며 서브그룹을 생성
    1-2. 생성되는 서브 그룹 : ROLLUP 절에 기술한 컬럼 개수 +1
    1-3. ROLLUP절에 기술한 컬럼의 순서가 결과에 영향을 미친다
    
2. GROUPING SETS
    2-1. 사용자가 원하는 서브그룹을 직접 지정하는 형태
    2-2. 컬럼 기술의 순서는 결과 집합에 영향을 미치지 않음 (집합)
    
3. CUBE
    3-1. CUBE 절에 기술한 컬럼의 가능한 모든 조합으로 서브그룹을 생성
    3-2. 서브그룹이 너무 많아 잘 쓰지 않는다
        2^CUBE절에 기술한 컬럼 개수

SUB_A2}
SELECT *
FROM dept_test;

1. dept_tesst테이블의 empcnt컬럼 삭제
ALTER TABLE dept_test DROP (empcnt);

2. 2개의 신규 데이터 입력
INSERT INTO dept_test VALUES (99,'ddit1','deejoen');
INSERT INTO dept_test VALUES (99,'ddit2','deejoen');

2. 부서(depr_test)중에 직원이 속하지 않은 부서를 삭제
40,98,99가 삭제 대상
    요구사항에 맞게 조회 
    SELECT *
    FROM dept_test
    WHERE deptno IN(SELECT deptno FROM emp 
1. 비 상호 연관
    DELETE dept_test
    WHERE deptno NOT IN(SELECT deptno FROM emp GROUP BY deptno);
    -----------------------------------------------------------
    DELETE dept_test
    WHERE deptno NOT IN(SELECT deptno FROM emp);
    
2. 상호 연관
    DELETE dept_test
    WHERE NOT EXISTS (SELECT 'X' FROM emp WHERE emp.deptno = dept_test.deptno);
2-1. 상호 연관을 NOT IN으로 풀어보기
    DELETE dept_test
    WHERE deptno NOT IN (SELECT deptno FROM emp WHERE emp.deptno = dept_test.deptno);
    
실습 3
UPDATE emp_test a SET sal = sal+200
WHERE sal < (SELECT AVG(sal) FROM emp_test b WHERE b.deptno = a.deptno);

SELECT *
FROM emp_test
WHERE sal < (SELECT AVG(sal) FROM emp_test b WHERE b.deptno = a.deptno);

SELECT *
FROM emp_test;

SELECT DISTINCT deptno ----DISTINCT 중복을제거 하는 것
FROM emp_test;


WITH : 쿼리 블럭을 생성하고 
같이 실행되는 SQL에서 해달 쿼리 블럭을 반복적으로 사용할 때 성능 향상 효과를 기대할 수 있다
WITH절에 기술된 쿼리 블럭은 메모리에 한번만 올리기 때문에
쿼리에서 반복적으로 사용하더라도 실제 데이터을 가져오는 작업은 한번만 실행

하지만 하나의 쿼리에서 동일한 서브쿼리가 반복적으로 사용된다는 것은 쿼리를 잘못 작성할 가능성이 높다는 뜻이므로, 
WITH절로 해결하기 보다는 뭐리를 다른 방식으로 작성할 수 없는ㄴ지 먼저 고려 해볼 것을 추천
회사의 DB를 다른 외부인에게 오픈 할 수 없기 때문에, 외부인에게 도움을 구하고자 할 때
테이블을 대신할 목적으로 많이 사용
사용방법 : 쿼리 블럭은 콤마를 통해 여러개를 동시에 선언하는 것도 가능

WITH 쿼리블럭 이름 AS( SELECT 쿼리 ) SELECT * FROM 쿼리 블럭 이름;


달력만들기 쿼리
학습목표 - 데이터의 행을 열로 바꾸는방법
        - 레포트 쿼리에서 활용 할 수 있는 예제 연습
        
    예제 시나리오 
    -주어진 상황: '201905'
    -하고싶은것 해당 년월의 일자를 달려 형태로 출력

'202007'월 달력을 만들어 보자

1. 2020년 7월의 일수 구하기

SELECT *
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE('202007','YYYYMM')),'dd');

SELECT /*TO_DATE('202007'||'01','YYYYMMDD'), level--행의 번호*/
        TO_DATE('202007','YYYYMM')+ (LEVEL-1)--행의 번호
        ---자동으로 들어간다
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE('202007','YYYYMM')),'dd') ;


/*월요일이면 날짜 출력 (첫번째 컬럼)
        요일이 월요일이면 일자출력 월요일이 아니면 NULL*/
SELECT TO_DATE('202007','YYYYMM')+ (LEVEL-1) date,
        TO_CHAR(TO_DATE('202007','YYYYMM')+ (LEVEL-1),'D') day,
        DECODE(day,1,date)sun, DECODE(day,2,date)mon, DECODE(day,3,date)the,
        DECODE(day,4,date)wed, DECODE(day,5,date)thu, DECODE(day,6,date)fri,
         DECODE(day,7,datel)sat
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE('202007','YYYYMM')),'dd') ;
---------------------------------------------------------------------------------선생님
SELECT TO_DATE('202007','YYYYMM')+ (LEVEL-1) dt,
        TO_CHAR(TO_DATE('202007','YYYYMM')+ (LEVEL-1),'D') d,
        TO_CHAR(TO_DATE('202007','YYYYMM')+ (LEVEL-1),'iw') iw --iw:주차
       
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE('202007','YYYYMM')),'dd') ;
-------------------------------------------------------------------------
SELECT DECODE(d,1,iw+1,iw),MAX(DECODE(d,1,dt)) sun,MAX(DECODE(d,2,dt))mon,MAX(DECODE(d,3,dt))tue,
                MAX(DECODE(d,4,dt))wed,MAX(DECODE(d,5,dt))thu,MAX(DECODE(d,6,dt))fri,MAX(DECODE(d,7,dt))sat
FROM
(SELECT TO_DATE('202007','YYYYMM')+ (LEVEL-1) dt,
        TO_CHAR(TO_DATE('202007','YYYYMM')+ (LEVEL-1),'D') d,
        TO_CHAR(TO_DATE('202007','YYYYMM')+ (LEVEL-1),'iw') iw --iw:주차
       
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE('202007','YYYYMM')),'dd'))
GROUP BY DECODE(d,1,iw+1,iw)
ORDER BY DECODE(d,1,iw+1,iw); --iw는 월요일을 주의 시작으로 함 ==> 그래서 일요일 iw에다 +1씩 더해줌 

----------------------------------------------------------------------------------------달력 만들기
SELECT MAX(DECODE(d,1,dt)) sun,MAX(DECODE(d,2,dt))mon,MAX(DECODE(d,3,dt))tue,
                MAX(DECODE(d,4,dt))wed,MAX(DECODE(d,5,dt))thu,MAX(DECODE(d,6,dt))fri,MAX(DECODE(d,7,dt))sat
FROM
(SELECT TO_DATE(:YYYYMM,'YYYYMM')+ (LEVEL-1) dt,
        TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM')+ (LEVEL-1),'D') d,
        TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM')+ (LEVEL-1),'iw') iw --iw:주차
       
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM,'YYYYMM')),'dd'))
GROUP BY DECODE(d,1,iw+1,iw)
ORDER BY DECODE(d,1,iw+1,iw); 


실습1

create table sales as 
select to_date('2019-01-03', 'yyyy-MM-dd') dt, 500 sales from dual union all
select to_date('2019-01-15', 'yyyy-MM-dd') dt, 700 sales from dual union all
select to_date('2019-02-17', 'yyyy-MM-dd') dt, 300 sales from dual union all
select to_date('2019-02-28', 'yyyy-MM-dd') dt, 1000 sales from dual union all
select to_date('2019-04-05', 'yyyy-MM-dd') dt, 300 sales from dual union all
select to_date('2019-04-20', 'yyyy-MM-dd') dt, 900 sales from dual union all
select to_date('2019-05-11', 'yyyy-MM-dd') dt, 150 sales from dual union all
select to_date('2019-05-30', 'yyyy-MM-dd') dt, 100 sales from dual union all
select to_date('2019-06-22', 'yyyy-MM-dd') dt, 1400 sales from dual union all
select to_date('2019-06-27', 'yyyy-MM-dd') dt, 1300 sales from dual;


SELECT *
FROM sales;

SELECT TO_CHAR(dt,'MM'),SUM(sales)
FROM sales
group by TO_CHAR(dt,'MM');

1.DT컬럼을 이용하여 월 정보를 추출

SELECT TO_CHAR(dt,'MM'),sales
FROM sales;

2. 1번에서 추출된 월정보가 같은 컬럼끼리 컬럼의 합을 계산

SELECT TO_CHAR(dt,'MM'),SUM(sales) sales
FROM sales
group by TO_CHAR(dt,'MM');

3. 2번까지 계산된 결과를 인라인 뷰로 생성
SELECT 
FROM
(SELECT TO_CHAR(dt,'MM') m,SUM(sales) sales
FROM sales
group by TO_CHAR(dt,'MM'))

4. 3번에서 생성한 인라인 뷰를 이용,월별 컬럼을 6개 생성
MAX.MIN,SUM 상관없지만 ==>MIN  동일한 함수를 적용했을때 더 빠르다

SELECT NVL(MIN(DECODE(m,'01',sales)),0),NVL(MIN(DECODE(m,'02',sales)),0),NVL(MIN(DECODE(m,'03',sales)),0),
        NVL(MIN(DECODE(m,'04',sales)),0),NVL(MIN(DECODE(m,'05',sales)),0),NVL(MIN(DECODE(m,'06',sales)),0)
FROM
(SELECT TO_CHAR(dt,'MM') m ,SUM(sales) sales
FROM sales
group by TO_CHAR(dt,'MM'));



SELECT NVL(SUM(DECODE(TO_CHAR(dt,'MM') ,'01', sales)),0) jan,
    NVL(SUM(DECODE(TO_CHAR(dt,'MM') ,'02', sales)),0) feb,
    NVL(SUM(DECODE(TO_CHAR(dt,'MM') ,'03', sales)),0)mar,
    NVL(SUM(DECODE(TO_CHAR(dt,'MM') ,'04', sales)),0)apr,
    NVL(SUM(DECODE(TO_CHAR(dt,'MM') ,'05', sales)),0)may,
    NVL(SUM(DECODE(TO_CHAR(dt,'MM') ,'06', sales)),0)jun
FROM sales;

-------------------------------------------------------------------------------------유네 풀이
SELECT NVL(MAX(DECODE( TO_CHAR(dt,'MM'),01,SUM(sales))),0) jan,NVL(MAX(DECODE(TO_CHAR(dt,'MM'),02,SUM(sales))),0)feb,
        NVL(MAX(DECODE( TO_CHAR(dt,'MM'),03,SUM(sales))),0)mar ,NVL(MAX(DECODE( TO_CHAR(dt,'MM'),04,SUM(sales))) ,0)apr,
       NVL( MAX(DECODE( TO_CHAR(dt,'MM'),05,SUM(sales))),0)may,NVL(MAX(DECODE( TO_CHAR(dt,'MM'),06,SUM(sales))),0) jun
FROM sales
GROUP BY TO_CHAR(dt,'MM');


미리 정의된 포트
HTTP: 80
https : 443
ftp : 21
기본 포트
ORACLE : 1521
TOMCAT : 8080
MYSQL : 3306


웆

