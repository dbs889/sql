SQL 응용 : DML (SELECT, UPDATE,INSERT,MERGE)

1. Multiple Insert 
한번의 INSERT 구문을 통해 여러 테이블에 데이터를 입력
RDBMS : 데이터 중복을 최소화
실 사용예 : 1. 실제 사용할 테이블과 별개로 보조 테이블에도 동일한 데이터 쌓기
            2. 데이터의 수평분할(*)
            주문 테이블
            2020년 데이터 ==> TB_ORDER_2020
            2021년 데이터 ==> TB_ORDER_2021
            ==> 오라클  PARTITION 을 통해 더 효과적으로 관리 가능(정식버전에만 존재)
            하나의 테이블안에 데이터 값에 따라 저장하는 물리 공간이 나눠져 있음
             : 개발자 입장에서는 데이터를 입력하면 데이터 값에 따라 물리적인 공간을 오라클이 알아서 나눠서 저장
Multiple Insert 종류
1. unconditional insert 조건과 관계없이 하나의 데이터를 여러 테이블에 입력
2. conditional all insert : 조건을 만족하는 모든 테이블에 입력
3. conditional first insert : 조건을 만족하는 첫번째 테이블에 입력

1. emp_test,emp_test 2 DROP
2. emp테이블의 empno 컬럼이랑 ename 컬럼만 갖고 emp_test,emp_test2를 생성 단, 데이터를 복사하지 않음

1. DROP TABLE emp_test;
    DROP TABLE emp_test2;


2. CREATE TABLE emp_test AS 
    SELECT empno, ename
    FROM emp
    WHERE 1!=1;
    
    2. CREATE TABLE emp_test2 AS 
    SELECT empno, ename
    FROM emp
    WHERE 1!=1;
    
unconditional insert
아래 두개의 행을 emp_test, emp_test2에 동시 입력 하나의 insert 구문 사용
SELECT 9999 empno, 'browm' ename 
FROM dual
UNION ALL 
SELECT 9998 empno, 'sally' ename FROM dual;


INSERT ALL
    INTO emp_test(컬럼) VALUES (empno,ename)
    INTO emp_test2(empno) VALUES (empno) --empno 데이터를 입력할 테이블의 컬럼 명 /empno
SELECT 9999 empno, 'browm' ename 
FROM dual
UNION ALL 
SELECT 9998 empno, 'sally' ename FROM dual;

rollback;
조건 분기 문법 : case when then end
조건 분기 함수 decode
INSERT ALL
    WHEN empno >= 9999 THEN
    INTO emp_test VALUES (empno,ename)
    WHEN empno >= 9998 THEN
    INTO emp_test2 VALUES (empno,ename) --empno 데이터를 입력할 테이블의 컬럼 명 /empno
    ELSE
     INTO emp_test2(empno) VALUES (empno)
SELECT 9999 empno, 'browm' ename FROM dual
UNION ALL 
SELECT 9998 empno, 'sally' ename FROM dual;

3. CONDITIONAL FIRST INSERT
ROLLBACK;
ALL=> 3건이 조회   FIRST일때 몇건이 조회되는지
INSERT FIRST -- 조건이 만족하는 첫번째 행만 INSERT
    WHEN empno >= 9999 THEN
    INTO emp_test VALUES (empno,ename)
    WHEN empno >= 9998 THEN
    INTO emp_test2 VALUES (empno,ename) --empno 데이터를 입력할 테이블의 컬럼 명 /empno
    ELSE
     INTO emp_test2(empno) VALUES (empno)
SELECT 9999 empno, 'browm' ename FROM dual
UNION ALL 
SELECT 9998 empno, 'sally' ename FROM dual;

SELECT *
FROM emp_test;
SELECT *
FROM emp_test2;

<merge> *****중요
사용자로 부터 받은 값을 갖고 테이블에 저장 or 수정
입력 받은 값이 테이블에 존재하면 수정을 하고 싶고
입력받은 값이 테이블에 존재하지 않으면 신규 입력을 하고 싶을 때

ex)empno 9999,ename 'brown'
emp테이블에 동일한 empno가 있으면 ename을 업데이트
emp테이블에 동일한 empno가 없으면 신규입력

2. 테이블의 데이터를 이용하여 다른 테이블의 데이터를 업데이트 or insert 하고 싶을 때
일반 update 구문에서는 비효율이 존재
ALLEN의 JOB과 DEPTNO를 SMITH사원과 동일한 업데이트를 하시오
. UPDATE emp SET job = (SELECT job FROM EMP WHERE ENAME = 'SMITH'),
                deptno = (SELECT deptno FROM EMP WHERE ENAME = 'SMITH'),
    WHERE ename = 'ALLEN'; 

머지구문을 사용하지 않는다면
1. 해당 데이터가 존재하는지 확인하는 SELECT 구문을 실행
2. 1번 쿼리가 조회 결과 있으면 
    2.1 UPDATE
3. 1번 쿼리가 조회결과가 없으면
    3.1 INSERT

1.     
SELECT *
FROM emp
WHERE empno = 9999

2. UPDATE emp SET ename = 'brown'
    WHERE empno = 9999;

3. INSERT INTO emp(empno,ename) VALUES (9999,'brown');

문법
MERGE INTO 테이블명(덮어 쓰거나, 신규로 입력할 테이블) alias
USING (테이블명 | VIEW | inline-view) alias
    ON (두 테이블간의 데이터 존재 여부를 확인할 조건)
WHEN MATCHED THEN
    UPDATE SET 컬럼1 = 값1,
                컬럼2 = 값2
WHEN NOT MATCHED THEN
        INSERT(컬럼1,컬럼2....) VALUES (값1,값2)
        
ROLLBACK;      
SELECT *


1.7369사원의 데이터를 emp_test로 복사 (empno,ename)
INSERT INTO emp_test
SELECT empno,ename FROM emp WHERE empno = 7369

SELECT *
FROM emp;

emp : 14, emp_test : 1(7369-emp테이블에도 존재)
emp 테이블을 이용하여 emp_test에 
동일한empno 값이 있으면 emp_test.ename 업데이트
동일한empno 값이 없으면 emp테이블의 데이터를 신규 입력

DELETE emp
WHERE empno >= 9990;

SELECT *
FROM em_test a, emp b
WHERE a.empno = b.empno;


MERGE INTO emp_test a
USING emp b 
    ON (a. empno = b.empno)
WHEN MATCHED THEN
    UPDATE SET a.ename = b.ename ||'_m' --m: modify 의 약자
WHEN NOT MATCHED THEN
        INSERT(empno,ename) VALUES (b.empno,b.ename);
        
emp_test 테이블에는
7369사원의 이름이 SMITH_m으로 업데이트
7369를 제외한 13명의 사원이 insert

SELECT *
FROM emp_test;

**merge에서 많이 사용하는 형태
사용자로 부터 받은 데이터를 emp_test 테이블에 
동일한 데이터 존재 유무에 따른 merge
시나리오 : 사용자 입력 empno= 9999, ename =brown

MERGE INTO emp_test
USING dual
    ON (emp_test.empno = :empno) --행 하나를 조회해 연결 조건을 확인한다
WHEN MATCHED THEN ---조던이 맞으면 
    UPDATE SET ename = :ename
WHEN NOT MATCHED THEN --조건이 틀리면 
    INSERT VALUES(:empno,:ename);
    
SELECT *
FROM emp_test;    

SELECT *
FROM dept_test2;  

실습 dept_test3 테이블을 dept테이블과 동일하게 생성 
    단 10,20번 부서만 복제
    dept 테이블을 이용하여 dept_test3테이블에 데이터를 merge 조건 : 부서번호가 같은 데이터
                    동일한 부서가 있을 때 기존 loc 컬럼의 값 +_m로 업데이트
                    동일한 부서가 없을 때 신규데이터 입력

1.dept_test3 테이블을 dept테이블과 동일하게 생성 
    단 10,20번 부서만 복제
    
    CREATE TABLE dept_test3 AS 
    SELECT deptno,LOC
    FROM dept
    WHERE deptno IN(10,20);
    
DROP TABLE  dept_test3;   

2. 테이블 조회 해보기
SELECT*
FROM dept_test3;

3. merge 조건
MERGE INTO dept_test3
USING dept
    ON (dept_test3.deptno = dept.deptno) --행 하나를 조회해 연결 조건을 확인한다
WHEN MATCHED THEN ---조건이 맞으면 
    UPDATE SET dept_test3.loc = dept.loc || ' _m'
WHEN NOT MATCHED THEN --조건이 틀리면 
    INSERT VALUES( dept.deptno, dept.loc);
    
    
실습2 사용자 입력 받은 값을 이용한 merge
사용자 입력  : deptno : 999, dname 'ddit' loc 'daejeon'
dept_test3 테이블에 사용자가 입력한 deptno 값과 
동일한데이터가 있을 경우 : 사용자가 입력한 dname, loc 값으로 두개 컬럼 업데이트
동일한 데이터가 없을 경우  : 사용자가 입력한 deptno,dname, loc값으로 인서트

DROP TABLE  dept_test3;   

1.테이블 생성
  CREATE TABLE dept_test3 AS 
    SELECT *
    FROM dept
    WHERE deptno IN(10,20);


2.
MERGE INTO dept_test3
USING dual
    ON (dept_test3.deptno = :deptno) --행 하나를 조회해 연결 조건을 확인한다
WHEN MATCHED THEN ---조건이 맞으면 
    UPDATE SET dept_test3.dname = :dname, dept_test3.loc = :loc
WHEN NOT MATCHED THEN --조건이 틀리면 
    INSERT VALUES(:deptno,:dname,:loc);
    
3.
SELECT *
FROM dept_test3;
    
    
실습 1 <GROUP FUNCTION 응용,확장>
SELECT deptno,sum(sal)
FROM emp
GROUP BY deptno
UNION ----기억하자!! 컬럼의 확장은 JOIN, 행의 확장은 집합연산
SELECT NULL,SUM(sal)
FROM emp
ORDER BY deptno nulls last ;

emp 테이블을 한번만 읽고서 처리 하기
단, 14건의 데이터를 다 읽지 않는다면 가능

SELECT DECODE(rn,1,deptno,2,null)deptno,SUM(sum_sal)
FROM
(SELECT *
FROM
(SELECT deptno,SUM(sal)sum_sal
FROM emp 
GROUP BY deptno)a,
(SELECT ROWNUM rn
FROM dept ---아무 값을 조회하는 거 ㅅ
WHERE ROWNUM <= 2)b )

/*SELECT ROWNUM rn
FROM DUAL ---아무 값을 조회하는 거 ㅅ
CONNECT BY LEVEL <= 2)b )*/

GROUP BY DECODE(rn,1,deptno,2,null)
ORDER BY deptno;

,(SELECT NULL, SUM(sal) FROM emp) a ;

SELECT deptno,e.SUM(sal)
FROM emp ;

<ROLLUP> -
1.GROUP BY의 확장 구문
2. 정해진 규칙으로 서브 그룹을 생성하고 생성된 서브 그룹을 하나의 집합으로 반환
3. GROUP BY ROLLUP(col1,col2...)
4. ROLLUP 절에 기술된 컬럼을 오른쪽에서 부터 하나 씩 제거해 가며 서브그룹을 생성

GROUP BY ROLLUP(job,deptno)
GROUP BY ROLLUP,deptno,job,)
ROLLUP 의 셩우 방향성이 있기 때문에 컬럼 기술 순서가 다르면 다른 결과가 나온다

예시  GROUP BY ROLLUP(deptno)
1. GROUP BY deptno --->부서번호별 총계
2. GROUP BY '' ==>전체 총계

예시  GROUP BY ROLLUP(job,deptno)
1. GROUP BY job, deptno ==>담당업무, 부서번호별 총계
2.  GROUP BY job 담당업무별 총계
3.  GROUP BY '' ==>전체 총계

ROLLUP 절에 n개의 컬럼을 기술 했을 때 subgroup의 개수는 : n+1개의 서브그룹이 생성



SELECT deptno,SUM(sal)
FROM emp
GROUP BY ROLLUP(deptno); ---원하는 결과를 테이블을 한번만 읽고 전체 합산을 계산 해줌

SELECT job, deptno,SUM(sal +NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job,deptno);

SELECT job, deptno,GROUPING(job),GROUPING(deptno),SUM(sal +NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job,deptno);

실습AD2
SELECT NVL(job,'총계') ,deptno,SUM(sal +NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job,deptno);
-------------------

SELECT NVL(job,'총계') ,deptno,SUM(sal +NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job,deptno);

실습AD2-1
SELECT NVL(job,'종') ,NVL(deptno,'소계'),SUM(sal +NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job,deptno);




    


