실습 2
SELECT NVL(job,'총계') ,deptno,SUM(sal +NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job,deptno);

실습AD2-1
SELECT NVL(job,'종') ,NVL(deptno,'소계'),SUM(sal +NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job,deptno);

--선생님
GROUPING (column) : 0,1de
0 : 컬럼이 소계 계산에 사용 되지 않았다(GROUP BY 컬럼으로 사용됨)
1 : 컬럼이 소계 계산에 사용 되었다
JOB 컬럼이 소계계산으로 사용되어 NULL값이 나온 것인지
정말 컬럼의 값이 null 인 행들만 GROUP BY 된 것인지 알려면 
GROUPING 함수를 사용해야 정확한 값을 알 수 있다

실습 2
GROUPING(job) 값이 1이면 '총계', 0이면 job

SELECT DECODE(GROUPING(job),1,'총계',0,job) job ,
        deptno,SUM(sal +NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job,deptno);

SELECT NVL(job,'총계') ,deptno,SUM(sal +NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(job,deptno);



NVL 함수를 사용하지 않고 GROUPING 함수를 사용해야하는 이유
GROUP by job,mgr
GROUP by job
GROUP by 전체

SELECT job,mgr,GROUPING(job),GROUPING(mgr), SUM(sal)
FROM emp
GROUP BY ROLLUP(job,mgr);
--조회결과에 PRESIDENT가 두개인 이유 ==> nvl을 쓰면 구분할 수 없다

SELECT job,mgr,GROUPING(job),GROUPING(mgr), SUM(sal)
FROM emp
GROUP BY ROLLUP(job,mgr);

grouping 
 

실습 2-1
GROUPING(job) + GROUPING(deptno) 값이 2이면 '총', 아니면 job
GROUPING(job) + GROUPING(deptno) 값이 2이면 '계', 1이면 '소계', 0이면 deptno

SELECT DECODE(GROUPING(job),1,'총',job) job , 
        DECODE(GROUPING(job) +  GROUPING(deptno),2,'계',1,'소계',0,deptno) deptno,
        GROUPING(job) , GROUPING(deptno),SUM(sal + NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP (job,deptno);

선생님-------------------------------------------------------------------------------------
SELECT CASE
        WHEN GROUPING(job)= 1 THEN '총'
        WHEN GROUPING(job)= 0 THEN job
        END job,
        CASE
           WHEN GROUPING(job)= 1 AND GROUPING(deptno)= 1 THEN '계'
            WHEN GROUPING(job)= 0 AND GROUPING(deptno)= 1 THEN '소계'
            WHEN GROUPING(job)= 0 AND  GROUPING(deptno)= 0 THEN TO_CHAR(deptno)
              END deptno, GROUPING(job) , GROUPING(deptno),SUM(sal) sal
FROM emp
GROUP BY ROLLUP (job,deptno);


실습3
SELECT deptno,job,SUM(sal + NVL(comm,0))sal
FROM emp
GROUP BY ROLLUP (deptno,job);
    
실습 4
SELECT dname,job,SUM(e.sal + NVL(e.comm,0))sal
FROM emp e ,dept d
WHERE e.deptno = d.deptno
GROUP BY ROLLUP (dname, e.job)
ORDER BY dname,job DESC;

----선생님(in-line view)
SELECT dept.dname,a.job,a.sal
FROM
(SELECT deptno,job,SUM(sal + NVL(comm,0))sal
FROM emp
GROUP BY ROLLUP (deptno,job)) a,dept
WHERE a.deptno = dept.deptno(+);

실습 5
SELECT DECODE(GROUPING(dname),1,'총합',0,dname) dname,
    job,SUM(e.sal + NVL(e.comm,0))sal,GROUPING(dname)
FROM emp e ,dept d
WHERE e.deptno = d.deptno
GROUP BY ROLLUP (dname, e.job)
ORDER BY dname,job DESC;

응용


*********중요
확장된 GROUP BY (시험출제는 좋지만 실무로는 2번이 많이 쓰인다)
1.ROLLUP - 컬럼기술에 방향성이 존재
        GROUP BY (job,deptno) != GROUP BY (deptno,job) 
         GROUP BY job,deptno        GROUP BY (deptno,job) 
         GROUP BY job               GROUP BY deptno
         GROUP BY ''                GROUP BY ''
         
         단점 : 개발자가 필요가 없는 서브 그룹을 임의로 제거 할 수 없다
         
2.GROUPING SETS -필요한 서브그룹을 임의로 지정하는 형태
==> 복수의 GROUP BY를 하나로 합쳐서 결과를 돌려주는 형태
 GROUP BY GROUPING SETS(col1,col2)
 GROUP BY col1
 UNION ALL
  GROUP BY col2
  
 GROUP BY GROUPING SETS(col2,col1)
 GROUP BY col2
 UNION ALL
  GROUP BY col1
  --데이터 행의 순서는 다를 수 있지만 결과는 같다
  
  GROUPING SET의 경우 ROLLUP과는 다르게 컬럼 나열순서가 데이터 자체에 영향을 미치지 않음
  
복수컬럼으로 GROUP BY  
   GROUP BY col1,col2
     UNION ALL
        GROUP BY col1
        ==> GROUPING SET((col1,col2),col1)
        
실습 
SELECT job, deptno, SUM(sal+NVL(comm,0)) sal_sum
FROM emp
GROUP BY  GROUPING SETS(job,deptno);

위 쿼리를 UNION ALL
SELECT job, null, SUM(sal+NVL(comm,0)) sal_sum
FROM emp
GROUP BY job
UNION ALL
SELECT NULL, deptno, SUM(sal+NVL(comm,0)) sal_sum
FROM emp
GROUP BY deptno;

GROUP BY  GROUPING SETS(job,deptno,mgr); --서브쿼리3개
GROUP BY  GROUPING SETS((job,deptno),mgr); --서브쿼리2개

SELECT job,deptno, mgr, SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY GROUPING SETS((job,deptno),mgr);

3.CUBE --실무에서 많이 쓰이지 않는다

GROUP BY를 확장한 구문
CUBE 절에 나열한 모든 가능한 조합으로 서브그룹을 생성한다
GROUP BY CUBE(job,deptno); ==>4가지를 볼 수 있다

    풀어서 표현하자면 
    GROUP BY job, deptno
    GROUP BY job
    GROUP BY       deptno
    GROUP BY
    
SELECT job,deptno,SUM(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY CUBE(job,deptno);


GROUP BY CUBE(job,deptno,mgr) => 8가지
GROUP BY CUBE(job,deptno,mgr,ename) =>16가지

cube의 경우 기술한 컬럼으로 모든 가능한 조합으로 서브그룹을 생성한다
가능한 서브그룹은 2^기술한 컬럼 개수
기술한 컬럼이 3개만 넘어도 생성되는 서브그룹의 개수가 8개가 넘기 떄문에
실제 필요하지 않은 서브그룹이 포함될 가능성이 높다
==> ROLLUP,GROUPING SETS 보다 활용성이 떨어진다

중요한 내용 아님
SELECT job,deptno,mgr,SUM(sal +NVL(comm,0)) sal_sum
FROM emp
GROUP BY job,ROLLUP(deptno),CUBE(mgr);

==>내가 필욜로 하는 서브그웁을 GROUPING SETS 를 통해 정의하면 간단하게 작성 가능

가능한 조합 분석
ROLLUP(deptno): GROUP BY deptno
                GROUP BY ''
CUBE(mgr)  : GROUP BY mgr
            GROUP BY ''     
아래와 동일하다            
GROUP BY CUBE job,deptno,mgr
GROUP BY CUBE job,deptno
GROUP BY CUBE job,mgr
GROUP BY CUBE job


SELECT job,deptno, mgr, SUM(sal + NVL(comm,0)) sal
FROM emp
GROUP BY job, ROLLUP(job,deptno), cube(mgr);

1. 서브그룹을 나열하기
GROUP BY job --1가지

rollup  --3가지
GROUP BY job,deptno
GROUP BY job --생략
GROUP BY ''

cube --2가지
GROUP BY mgr
GROUP BY '' 

GROUP BY job,deptno,mgr
GROUP BY job,deptno
GROUP BY job,mgr
GROUP BY job



ADVANCED 

SELECT *
FROM emp_test;

1. emp_test 테이블 삭제
DROP TABLE emp_test;

2. emp 테이블을 이용하여 emp_test 테이블 생성(모든행, 모든컬럼)
CREATE TABLE emp_test AS SELECT * FROM emp; 

3. emp_test 테이블에 dname 컴럼 추가 VARCHAR2(14)
ALTER TABLE emp_test ADD( DNAME VARCHAR2(14));

4.서브쿼리를 이용해 EMP_TEST 테이블의DNAME을 DEPT 테이블의 DNAME 값으로 UPDATE
SELECT empno,ename,deptno,(SELECT dname FROM dept WHERE dept.deptno = emp_test.deptno)
FROM emp_test;

WHERE 절이 존재하지 않음 ==> 모든 행에 대해서 업데이트를 실행
UPDATE emp_test SET dname = (SELECT dname FROM dept WHERE dept.deptno = emp_test.deptno);

DESC DEPT;
실습 1. 
1. 테이블 삭제
DROP TABLE dept_test;

2. dept 테이블을 이용하여 dept_test 생성(모든행, 모든 컬럼)
CREATE TABLE dept_test AS SELECT * FROM dept ;

3. dept_test 테이블에 empcnt(number) 컬럼을 추가
ALTER TABLE dept_test ADD (EMPCNT NUMBER);

4. 서브쿼리를 이용해 DEPT_TEST 테이블의 empcnt컬럼을 해당 부서원수로 UPDATE
emp 테이블에서 해당 부서원수가 어디에 속했는지

UPDATE dept_test SET empcnt = (SELECT count(*) FROM emp WHERE dept_test.deptno = emp.deptno);

SELECT deptno,dname,
    (SELECT count(*) FROM emp WHERE dept_test.deptno = emp.deptno)
FROM dept_test;

