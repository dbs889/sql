
과제 1)
SELECT iw,MIN(DECODE(d,1,dt)) sun,  MIN(DECODE(d,2,dt)) mon,  MIN(DECODE(d,3,dt)) tue,
        MIN( DECODE(d,4,dt) )wed,  MIN(DECODE(d,5,dt)) thu,  MIN(DECODE(d,6,dt)) fri,  MIN(DECODE(d,7,dt)) sat
FROM
(SELECT TO_DATE(:YYYYMM,'YYYYMM')+(level-1) dt,
        TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM')+(level-1),'D') d,
         TO_DATE(:YYYYMM,'YYYYMM')+(level-1)-( TO_CHAR(TO_DATE(:YYYYMM,'YYYYMM')+(level-1),'D'))s
FROM dual
CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM,'YYYYMM')),'dd'))
GROUP BY iw
ORDER BY iw;


WITH dt AS (
        SELECT TO_DATE('2019/12/01','YYYY/MM/DD') dt FROM dual UNION ALL
        SELECT TO_DATE('2019/12/02','YYYY/MM/DD') dt FROM dual UNION ALL
        SELECT TO_DATE('2019/12/03','YYYY/MM/DD') dt FROM dual UNION ALL
        SELECT TO_DATE('2019/12/04','YYYY/MM/DD') dt FROM dual UNION ALL
        SELECT TO_DATE('2019/12/05','YYYY/MM/DD') dt FROM dual UNION ALL
        SELECT TO_DATE('2019/12/06','YYYY/MM/DD') dt FROM dual UNION ALL
        SELECT TO_DATE('2019/12/07','YYYY/MM/DD') dt FROM dual UNION ALL
        SELECT TO_DATE('2019/12/08','YYYY/MM/DD') dt FROM dual UNION ALL
        SELECT TO_DATE('2019/12/09','YYYY/MM/DD') dt FROM dual UNION ALL
        SELECT TO_DATE('2019/12/10','YYYY/MM/DD') dt FROM dual)
SELECT dt,dt-(TO_CHAR(dt,'d')-1)
FROM dt;

MY BAYIS
SELECT :결과가 1건이냐, 복수건이냐
    1건 : sqlSession.selectOne ("네임스페이스.sqlid",[인자]) ==> overloading
            리턴 타입 : resultType
    복수 건 :sqlSession.selectList("네임스페이스.sqlid",[인자]) ==> overloading
            리턴 타입 : List<resultType>

오라클 계층 쿼리 : 하나의 테이블(혹은 인라인 뷰)에서 특정 행을 기준으로 다른 행을 찾아가는 문법
조인 : 테이블-테이블
계층 쿼리 : 행 -행

1. 시작점(행)을 설정
2. 시작점(행)과 다른행을 연결시킬 조건을 기술

1. 시작점 : mgr 정보가 없는 KING
2. 연결 조건 : KING을 mgr컬럼으로 하는 사원

-------------------------------------------------------------
SELECT emp. *,level
FROM emp
START WITH /*empno = 7839,ename = 'KING',*/ mgr IS NULL
CONNECT BY prior empno= mgr; -- prior먼저 읽은 행의 

SELECT LPAD('기준문자열',15,'*')
FROM dual;
-----------------------------------------------------------------
LEVEL =1 :0칸
LEVEL =2 :4칸
LEVEL =3 :8칸

SELECT LPAD(' ',(LEVEL-1)*4) || ename,level
FROM emp
START WITH mgr IS NULL
CONNECT BY prior empno= mgr;
-----------------------------------------------------------
SELECT LPAD(' ',(LEVEL-1)*4) || ename,level
FROM emp
START WITH ename = 'BLAKE' ----위의 쿼리와 시작점 변경
CONNECT BY prior empno= mgr;

최하단 노드에서 상위 노드로 연결하는 상향식 연결방법

시작점 : SMITH
연결
SELECT LPAD(' ',(LEVEL-1)*4) || ename
FROM emp
START WITH ename ='SMITH'
CONNECT BY PRIOR mgr = empno;--CONNECT BY empno = PRIOR mgr 결과와 동일

***prior 키워드는 connect by 키워드와 떨어져서 사용해도 무관
***prior 키워드는 현재 읽고 있는 행을 지칭하는 키워드

-------------------부서번호가 20번인 사원들만 연결 하겠다
SELECT LPAD(' ',(LEVEL-1)*4) || ename,deptno
FROM emp
START WITH ename ='SMITH'
CONNECT BY PRIOR mgr = empno AND deptno =20;

-----------------------------------prior는 여러개 올 수 있다
SELECT LPAD(' ',(LEVEL-1)*4) || ename,emp.*
FROM emp
START WITH ename ='SMITH'
CONNECT BY  empno = PRIOR mgr AND PRIOR hiredate < hiredate;

실습 h_1
하향식으로 계층쿼리를 작성, 부서이름과 level 컬럼을 이용하여 들여쓰기 표현 

시작점  :XX회사
연결점 deptcd를 상위 부서코드랑 같은 p_deptcd

SELECT *
FROM dept_h;

SELECT LPAD(' ',(LEVEL-1)*3) || deptnm,level
FROM dept_h
START WITH deptnm = 'XX회사'
CONNECT BY prior deptcd = p_deptcd;

실습 h_2
SELECT LPAD(' ',(LEVEL-1)*3) || deptnm,level
FROM dept_h
START WITH deptnm = '정보시스템부'
CONNECT BY prior deptcd = p_deptcd;

실습 h_3
SELECT deptcd,LPAD(' ',(LEVEL-1)*3) || deptnm,p_deptcd,level
FROM dept_h
START WITH deptnm = '디자인팀'
CONNECT BY prior p_deptcd = deptcd;

실습 h_4

SELECT*
FROM .sql;

SELECT LPAD('HELLO, WORLD', 15,'*')
FROM dual;