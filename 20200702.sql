GROUP 함수의 특징
1. NULL은 그룹함수 연산에서 제외가 된다

Q) 부서번호별 사원의 sal,comm 컬럼의 총 합을 구하기
SELECT deptno, SUM(sal + comm), SUM(sal + NVL(comm,0)), SUM(sal) + SUM(comm) --SUM(sal + comm) SIM(sal) + SUM(comm)두개의 컬럼의 값이 다르다               
                                                         --SUM(sal + comm) sal + comm부터 계산하여 null값 제외
FROM emp
GROUP BY deptno;

NULL처리의 효율 --SUM(comm)에서 null 값을 0으로 바꾸고 싶을 때 
SELECT deptno, SUM(sal) + NVL(SUM(comm),0)  --커미션을 다 더하고 맨 마지막에 나온 결과에 대해 NVL한다
                SUM(sal) + SUM(NVL(comm),0) --두 컬럼의 결과는 같다
FROM emp
GROUP BY deptno;

GROUP BY 절에 작성된 컬럼 이외의 컬럼이 SELECT 절에 올 수 없다(엑셀적용하여 분석)

칠거지악 -DECODE 또는 CASE 사용시에는 새끼를 증손자 이상 낳지 마라 (3중첩 이상 중첩을 많이 하지 말아라)

Q) 실습 1
SELECT MAX(sal) max_sal, MIN(sal) min_sal, 
        ROUND(AVG(sal),2) avg_sal, SUM(sal) sum_sal, 
        COUNT(sal) count_sal, COUNT(mgr) count_mgr, COUNT(*) count_all
FROM emp;

Q) 실습 2
SELECT deptno, MAX(sal) max_sal, MIN(sal) min_sal, 
        ROUND(AVG(sal),2) avg_sal, SUM(sal) sum_sal, 
        COUNT(sal) count_sal, COUNT(mgr) count_mgr, COUNT(*) count_all
FROM emp
GROUP BY deptno;

Q) 실습 3
SELECT DECODE(deptno,
              30, 'SALES',
              20, 'RESEARCH',
              10,'ACCOUNTING') dename, 
              MAX(sal) max_sal, MIN(sal) min_sal, 
                ROUND(AVG(sal),2) avg_sal, SUM(sal) sum_sal, 
                COUNT(sal) count_sal, COUNT(mgr) count_mgr, COUNT(*) count_all
FROM emp
GROUP BY deptno;

응용 
SELECT DECODE(deptno,
              30, 'SALES',
              20, 'RESEARCH',
              10,'ACCOUNTING') dename, 
              MAX(sal) max_sal, MIN(sal) min_sal, 
                ROUND(AVG(sal),2) avg_sal, SUM(sal) sum_sal, 
                COUNT(sal) count_sal, COUNT(mgr) count_mgr, COUNT(*) count_all
FROM emp
GROUP BY DECODE(deptno,
              30, 'SALES',
              20, 'RESEARCH',
              10,'ACCOUNTING'); --GROUP BY절에 decode 사용 할 수 있다


Q) 실습 4 : 입사 년월을 기준으로 그룹핑을하여 몇명의 직원이 입사 했는지 조회하라
SELECT TO_CHAR(hiredate,'YYYYMM')hire_yyyymm, COUNT(*) cnt
FROM emp
GROUP BY TO_CHAR(hiredate,'YYYYMM');

Q) 실습 5 : 직원의 입사 년별로 몇명의 직원이 입사했는지 조회하라

SELECT TO_CHAR(hiredate,'YYYY')hire_yyyy, COUNT(*) cnt
FROM emp
GROUP BY TO_CHAR(hiredate,'YYYY');

Q) 실습 6 : 회사에 존재하는 부서의 개수는 몇개인지 조회하는 쿼리를 작성하시오
SELECT COUNT(*) cnt
FROM dept;

Q) 실습 7: 직원이 속한 부서의 개수를 조회하는 쿼리를 작성하시오
SELECT COUNT(*)
FROM 
    (SELECT deptno
    FROM emp
    GROUP BY deptno);
    
응용   
SELECT COUNT(COUNT(deptno)) --COUNT의 중첩도 가능하다
 FROM emp
GROUP BY deptno;

칠거지악 : 진정한 IN-LINE VIEW인지 확인하여라(남발하지마라)

SELECT *
FROM emp;


<JOIN>
: 컬럼을 확장하는 방법(데이터를 연결)
    다른 테이블의 컬럼을 가져온다
RDBS가 중복을 최소화하는 구조이기 떄문에
하나의테이블에 데이터를 전부 담지 않고, 목적에 맞게 설계한 테이블에 데이터가 분산이 된다
하지만 데이터를 조회 할때 다른 테이블의 데이터를 연결하여 컬럼을 가져올 수 있다 


SELECT
FROM

ANSI-SQL :American National Standard Institute -SQL
ORACLE SQL 문법
JOIN :ANSI-SQL 
        ORACLE SQL 문법의 차이가 다소 발생
ANSI-SQL join
NATURAL JOIN : 조인하고자 하는 테이블간 컬럼명이 동일할 경우 해당 컬럼으로 행을 연결
            컬럼 이름 뿐만 아니라 데이터 타입도 동일해야함.
사용법            
SELECT 컬럼
FROM  테이블1 ,  NATURAL JOIN 테이블2    

emp, dept 두 테이블의 공통된 이름을 갖는 컬럼 :deptno

SELECT emp.empno, emp.ename, deptno, dept.dname
FROM emp   NATURAL JOIN dept; -- NATURAL JOIN하면 조인된 컬럼은 하나만 명시된다

두 테이블에 동일한 컬럼이 있을 때 어느쪽 컬럼에서 오는 건지 조회 할때는 한정자를 사용한다(테이블명/별칭.)
deptno 와 같이 결합된 컬럼은 테이블 한정자를 사용 할 수 없다
조인 조건으로 사용된 컬럼은 테이블 한정자를 붙이면 에러(ANSI-SQL )

위의 쿼리르 ORACLE 버전으로 수정
오라클에서는 조인조건을 WHERE 절에 기술
행을 제한하는 조건, 조인 조선 ==> WHERE 절에 기술

SELECT *
FROM emp,dept 
WHERE deptno = deptno; --컬럼을 명시하지 않음
---==> column ambiguously defined 컬럼의 오류 발생 ANSI-SQL과 다른점 : 한정자를 안 붙이면 오류이다

SELECT *
FROM emp,dept -- ,를 통해 조인할 테이블을 나열한다
WHERE emp.deptno = dept.deptno; --한정자를 붙여 조회한다
--==> 중복된 컬럼도 같이 표기한다 ANSI-SQL과 다른점

--ANSI-SQL와 다른점 : 한정자 사용, 테이블에 중복컬럼 명시

SELECT emp.*, emp.deptno, dname
FROM emp, dept 
WHERE emp.deptno = dept.deptno; 

응용 emp와dept의 deptno를 다르다라는 조건을 줬을 때 10번 부서는 20,30,40과 조인한다 20번 30,10,40번과 조회 ----총 42개
SELECT emp.*, emp.deptno, dname
FROM emp, dept 
WHERE emp.deptno != dept.deptno; 

ANSI-SQL : JOIN WITH USING
조인 테이블간 동일한 이름의 컬럼이 복수개 인데 이름이 같은 컬럼 중 일부로만 조인하고 싶을 떄 사용

SELECT *
FROM emp JOIN dept USING (deptno);

위의 쿼리를 ORACLE 조언으로 변경하면 -- ORACLE where 절을 사용한다
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;

ANSI-SQL : JOIN WITH ON
위에서 배운 NATURAL JOIN, JOIN WITH USING의 경우 조인 테이블의 조인 컬럼이 이름이 같아야 한다는 제약이 있음
설계상 테이블의 컬럼이름이 다를 수도 있기 때문에 
컬럼 이름이 다를 경우 개발자가 직접 조인 조선을 기술 할 수 있도록 제공해주는 문법

SELECT *
FROM emp JOIN dept ON (emp.deptno = dept.deptno);

ORACLE에서 사용
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;

SELF-JOIN ; 동일한 테이블끼리 조인 할 때 지칭하는 명칭
            (별도의 키워드가 아니다)

Q)사원번호, 사원이름, 사원의 상사 사원번호, 사원의 상사 이름을 가지고 싶을 때         
SELECT *
FROM emp;

SELECT e.empno, e.ename, e.mgr, m.ename
FROM emp e JOIN emp m ON(e.mgr = m.empno); --테이블 별칭을 사용한다
--king은 사원이 없기 때문에 조인에 실패 ==>총 행의수는 13건이 조회된다

Q) 사원중 사원의 번호가 7369~7698인 사원만 대상으로 해당 사원의
사원번호, 사원이름, 사원의 상사 사원번호, 사원의 상사 이름
SELECT e.empno, e.ename, e.mgr, m.ename
FROM emp e JOIN emp m ON(e.mgr = m.empno)
WHERE e.empno BETWEEN 7369 AND 7698;

응용- 오라클 문법(in-line view)
SELECT a.*, emp.ename
FROM
    (SELECT empno, ename, mgr
    FROM emp 
    WHERE empno BETWEEN 7369 AND 7698) a, emp
WHERE a.mgr = emp.empno;

응용- ANSI-SQL
SELECT a.*, emp.ename
FROM
    (SELECT empno, ename, mgr
    FROM emp 
    WHERE empno BETWEEN 7369 AND 7698) a JOIN emp ON (a.mgr = emp.empno);

--오라클은 FROM절에 조인할 테이블 명시 WHERE절에 조건 제시

NON-EQUI-JOIN : 조인 조건이 =이 아닌 조인
!= 값이 다를 때 연결

SELECT *
FROM salgrade; --hisal 의 값이 다음 losal의 +1 --각 행들의 중복되는 값이 없는지 확인
                --선분이력
Q)급여 등급을 알고 싶을 때
SELECT empno, ename, sal , 급여등급
FROM emp;

Q)급여 등급을 알고 싶을 때
SELECT empno, ename, sal, grade
FROM emp, salgrade
WHERE sal BETWEEN losal AND hisal;

Q)실습
SELECT empno, ename, dept.deptno, dept.dname
FROM emp,dept
WHERE emp.deptno = dept.deptno;

SELECT empno, ename, emp.deptno, dept.dname
FROM emp   NATURAL JOIN dept; 

Q)실습
SELECT emp.empno, emp.ename, deptno, dept.dname
FROM emp  NATURAL JOIN dept
WHERE deptno IN(30,10);


SELECT empno, ename, dept.deptno, dept.dname
FROM emp,dept
WHERE emp.deptno = dept.deptno
        AND dept.deptno IN(30,10);

과제 0_2~0-4
동영상 노마드코더 -누구나 코딩을 할수있다 팩폭드림, 자꾸만 에러가 나오는데 왜 그럴까

SELECT empno, ename, sal, dept.deptno, dept.dname
FROM emp,dept
WHERE emp.deptno = dept.deptno
        AND sal > 2500;
        
SELECT empno, ename, sal, dept.deptno, dept.dname
FROM emp,dept
WHERE emp.deptno = dept.deptno
        AND sal > 2500
        AND empno >7600;
        
SELECT empno, ename, sal, dept.deptno, dept.dname
FROM emp,dept
WHERE emp.deptno = dept.deptno
        AND sal > 2500
        AND empno >7600
        AND dname IN('RESEARCH');        


