1. GROUP BY (여러개의 행을 하나의 행으로 묶는 행위)
2. JOIN
3. 서브쿼리 !!!중요!!!
    1. 사용위치
    2. 반환하는 행, 컬럼의 개수
    3. 상호연관/비상호 연관
    
SUB 실습2
SELECT *
FROM emp
WHERE sal > (SELECT AVG(sal)
            FROM emp); --비 상호 연관 서브쿼리

Q) 사원이 속한 부서의 급여 평균보다 높은 급여를 받는 사원정보 조회
-----------------------------선생님 답
전체사원의 정보를 조회, 조인 없이 해당사원이 속한 부서의 부서이름 가져오기

참고) 직원이 속한 부서의 부서이름 가져오기
SELECT empno,ename,deptno,
    (SELECT dname FROM dept WHERE deptno = emp.deptno) dname --상호연관 서브쿼리(서브쿼리 단독실행 불가)
FROM emp;

1)부서평균구하기
SELECT AVG(sal)
FROM emp
WHERE deptno = emp.deptno;

2)
SELECT *
FROM emp e
WHERE sal >(SELECT AVG(sal)
            FROM emp s
            WHERE s.deptno = e.deptno);

3 SELECT 
1 FROM 
2 WHERE
GROUP BY
4 ORDER BY

실습 SUB3
------------------유네 풀이
SELECT *
FROM emp 
WHERE deptno IN (SELECT deptno
            FROM emp 
            WHERE ename IN ('SMITH','WARD'));
            
----------------선생님 풀이
SMITH와 WARD사원이 속한 부서의 모든 사원정보를 조회
SELECT *
FROM emp 
WHERE deptno IN(SELECT deptno
            FROM emp 
            WHERE ename IN ('SMITH','WARD'))  ----20,30인 것 보다 유지보수성에 용이하다 

단일 값 비교는 =
복수행(단일컬럼) 비교는 IN

***출제가능***
IN 과 NOT IN이용시  NULL값의 존재 유무에 따라 원하지 않는 결과가 나올 수 도 있다
NULL과 IN ,NULL과 NOT IN
IN ==>OR
NOT IN ==> AND

SELECT *
FROM emp
WHERE  mgr IN(7902,NULL)
==> mgr  = 7902 or mgr =NULL
==> mgr 값이 7902이거나 mgr 값이 null인 데이터

SELECT *
FROM emp
WHERE  mgr NOT IN(7902,NULL); ---데이터가 조회되지 않는다 --mgr != NULL가 거짓이므로
==> NOT(mgr  = 7902 OR mgr =NULL)
==> ==> mgr  != 7902 AND mgr != NULL

SELECT *
FROM emp
WHERE  mgr IS NOT null
        OR  mgr NOT IN(7902);

<pairwise,non-pairwise>
한행의 컬럼 값을 하나씩 비교하는 것 : non-pairwise
한행의 복수 컬럼을 비교하는 것 :pairwise 

SELECT *
FROM emp
WHERE (mgr, deptno) IN(SELECT mgr, deptno
                        FROM emp
                        WHERE empno IN(7499,7782)); --한 행의  두개 컬럼을 만족하는것 --특정경우의 수만 제한 할때
                        
SELECT *
FROM emp
WHERE mgr IN (SELECT mgr
              FROM emp
             WHERE empno IN(7499,7782))
        AND 
        deptno IN (SELECT deptno
              FROM emp
             WHERE empno IN(7499,7782)); ---한행의 컬럼값을 하나씩 비교하는 것
SELECT *
FROM emp
WHERE mgr IN (SELECT mgr FROM emp WHERE empno IN(7499,7782))
    AND 
    deptno  IN(SELECT deptno FROM emp WHERE empno IN(7499,7782));
             
             
             
             --총 4개의 경우의 수가 조회 된다

---두 쿼리의 차이 : non-pairwise경우의 수가 더 많아 진다
pairwise
7698,   30
7839,   10
non-pairwise
7698,   30
7698,   10
7839,   10
7839,   10


스칼라 서브쿼리 : SELECT절에서 사용 행이하나 컬럼도 하나

상호 연관 서브쿼리는 쿼리 실행 순서가 정해져 있다 메인->서브

SELECT *
FROM emp
WHERE sal > (SELECT AVG(sal) FROM emp);
sub4}
INSERT INTO dept VALUES (99,'ddit','daejeon');

실습 sub4

SELECT *
FROM dept;
WHERE deptno != 10 AND deptno != 20 AND deptno != 30 
-----유네풀이
SELECT *
FROM dept
WHERE deptno IN (SELECT deptno
            FROM dept
            WHERE dname IN ('ddit','OPERATIONS'));
-----선생님 풀이            
SELECT *
FROM dept 
WHERE deptno NOT IN (SELECT deptno
                        FROM emp);          
                        GROUP BY deptno);   -- GROUP BY절 생략가능하다
SELECT deptno
FROM emp            
GROUP BY deptno ;    ---중복을 제거

실습 sub5     
1. cid 가 1인 데이터 조회
SELECT *
FROM cycle
WHERE cid =1;

SELECT *
FROM product;

SELECT pid,pnm
FROM  product
WHERE pid NOT IN (SELECT pid
        FROM cycle
        WHERE cid =1);  
        
실습 sub6     
SELECT *
FROM cycle
WHERE  cid =1 AND  cid =2

SELECT *
FROM cycle
WHERE cid =1  AND pid IN (SELECT pid
                    FROM cycle
                    WHERE cid =2);
저기 추가가 되면 돼

SELECT *
FROM emp
WHERE hiredate BETWEEN TO_CHAR('19800101','YYYYMMDD') AND TO_CHAR('19821231','YYYYMMDD');

SELECT deptno,dname,loc
FROM dept
WHERE deptno NOT IN (SELECT deptno FROM emp GROUP BY deptno);

SELECT pid,pnm
FROM product
WHERE pid NOT IN (SELECT pid FROM cycle WHERE cid =1);

SELECT *
FROM cycle
WHERE cid =1 AND pid IN (SELECT pid FROM cycle WHERE cid =2);

SELECT c.cid,cu.cnm,c.pid,p.pnm,c.day,c.cnt
FROM product p,customer cu,
    (SELECT * FROM cycle WHERE cid =1 AND pid IN (SELECT pid FROM cycle WHERE cid =2)) c
WHERE p.pid = c.pid AND c.cid =cu.cid;

