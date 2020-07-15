오라클 객체 (object)
table -데이터 저장 공간
: ddl 생성, 수정, 삭제
view = SQL 이다 논리적인 데이터 정의, 실체가 없다
        VIEW 구성하는 데이터가 변경되면 VIEW 결과도 달라지더라
SEQUENCE 중복되지 않는ㄴ 정수값을 반환해주는 객체
    유일한 값이 필요할 때 사용할 수 있는 객체
        nextval, currval
INDEX - 테이블의 일부 컬럼을 기준으로 미리 정렬해 놓은 데이터
    ==> 테이블 없이 단독적으로 생성 불가, 특정테이블에 종속
        TABLE 삭제를 하면 관련 인덱스도 같이 삭제
        
DB 구조에서 중요한 전제 조건
1. DB에서 I/O 기준은 행단위가 아니라 BLOOK 단위
한 건의 데이터를 조회하더라도, 해당 행이 존재하는 BLOOK 전체를 읽는다
2. extend, 공간할당 기준

데이터 접근 방식
1. table full access
multi block io ==> 읽어야 할 블럭을 여러개를 한번에 읽어 들이는 방식
                    (일반적으로 8~16 block)
    사용자가 원하는 데이터의 결과가 table의 모든 데이터를 다 일겅야 처리가 가능한경우
    ==> 인덱스 보다 여럽 블럭을 한번에 많이 조회하는 table full access 방식이 유리 할 수 있다
    ex) 
    mgr,sal,comm 정보를 table에서만 획득이 가능할 때
    SELECT COUNT(mgr),SUM(sal),SUM(comm),AVG(sal)
    FROM emp;
    
2. index 접근 index 접근 후 table access
 SINGLE BLOCK IO ==>읽어야할 행이 있는 데이터 block 만 읽어서 처리하는 방식
 소수의 몇건 데이터를 사용자가 조회할 경우, 그리고 조건에 맞는 인덱스가 존재할 경우
 빠르게 응답을 받을 수 있다
 하지만 single block io가 빈번하게 일어나면 multi block io보다 느리다
 
 
 
현재 상태 
인덱스 : IDX_NU_emp_01 (empno)

emp테이블의 job컬럼을 기준으로 2번쨰 non-unique 인덱스 생성
1. 인덱스 생성
CREATE INDEX idx_nu_emp_02 ON emp(job);

현재상태
인덱스 : IDX_NU_emp_01 (empno),idx_nu_emp_02 emp(job);

2. 이 쿼리를 실행계획 보기
EXPLAIN PLAN FOR 
SELECT *
FROM emp
WHERE job = 'MANAGER' ---JOB컬럼만 인덱스와 관련이 있다
    AND ename LIKE 'C%';

SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 3525611128
 
---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    36 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_02 |     3 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 2->1->0
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("ENAME" LIKE 'C%')
   2 - access("JOB"='MANAGER') --JOB"='MANAGER'빠르게 접근했다 INDEX로 이미 정렬이 되어 있기 때문에
       --  MANAGER 가 나온 다음 PRESIDENT 까지 확인한 후 중복이 없으면 다음 조건을 찾아간다

idx_nu_emp_02 emp(job);의 구성 형태   
SELECT job,rowid
FROM emp
ORDER BY job; ---job컬럼 값에 null이 있다 ==> 인덱스는 null 값일 때 저장을 못한다  


3. 3번쨰 인덱스 추가 생성
emp테이블의 job,ename 컬럼으로 복합 non-unique index 생성
idx_nu_emp_03

CREATE INDEX idx_nu_emp_03 ON emp(job,ename);

현재 상태
인덱스 : IDX_NU_emp_01 (empno),idx_nu_emp_02(job),idx_nu_emp_03(jab,ename)
EXPLAIN PLAN FOR 
SELECT *
FROM emp
WHERE job = 'MANAGER'
    AND ename LIKE 'C%';
    
SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 1746703018
 
---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    36 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_03 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("JOB"='MANAGER' AND "ENAME" LIKE 'C%') ---job과 ename이 정렬이 되어 있다
       filter("ENAME" LIKE 'C%')
       
       
3번째 인덱스의 형태    
SELECT job,ename,ROWID
FROM emp
ORDER BY job,ename ---ename 값이 null이 아니므오 job에  null이 있어도 저장된다

--인덱스가 많아 질수록 느려진다

응용) 위의 쿼리와 변경 된 부분 ENAME에 변경을 줘본다
EXPLAIN PLAN FOR 
SELECT *
FROM emp
WHERE job = 'MANAGER'
    AND ename LIKE '%C';---LIKE 'C%' -> LIKE '%C'
    
SELECT *
FROM TABLE(dbms_xplan.display);

 Plan hash value: 1746703018
 
---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    36 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_03 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("JOB"='MANAGER') 
       filter("ENAME" LIKE '%C' AND "ENAME" IS NOT NULL)
             --조건에 만족하는 결과가 없어 테이블에 접근 하지 않았다 ENAME" LIKE '%C' 사람이 없다
             
인덱스 추가
emp 테이블에 ename,job 컬럼을 기준으로 non-unique 4번째 인덱스 생성
CREATE INDEX idx_nu_emp_04 ON emp(ename,job);

현재 상태 인덱스 : 
IDX_NU_emp_01 (empno),
idx_nu_emp_02(job),
idx_nu_emp_03(job,ename),
idx_nu_emp_04(ename,job) : 복합 컬럼의 인덱스의 컬럼 순서가 미치는 영향(컬럼의 순서를 변경 했다)
            --4번째 job,ename ->ename,job
다음 결과와 동일하다 
SELECT ename,job
FROM emp
ORDER BY ename,job;

EXPLAIN PLAN FOR 
SELECT *
FROM emp
WHERE job = 'MANAGER'
    AND ename LIKE 'C%';
    
SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 1746703018
 
---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    36 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_03 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("JOB"='MANAGER' AND "ENAME" LIKE 'C%')
       filter("ENAME" LIKE 'C%')
       
idx_nu_emp_03(job,ename),    삭제
DROP INDEX idx_nu_emp_03;

다시 조회
EXPLAIN PLAN FOR 
SELECT *
FROM emp
WHERE job = 'MANAGER'
    AND ename LIKE 'C%';
    
SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 2258096460
 
---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     1 |    36 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     1 |    36 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NU_EMP_04 |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("ENAME" LIKE 'C%' AND "JOB"='MANAGER') --C로 시작하는 것 먼저 찾고 그 다음이 C로 시작하지않으면 테이블로 넘어간다
       filter("JOB"='MANAGER' AND "ENAME" LIKE 'C%')
       
       ==> JOB에  = 이 오는 게 더 낫다 ==> 인덱스 3
       
지금까지!! ==> 인덱스를4 개 만들어 실행계획이 어떻게 바뀌는지 확인하며 사용자에게 몇번의 데이터가 전달 되있는지 확인하였다

조인에서 인덱스가 어떻게 활용되는지 알아보자
emp : pk_emp, fk_emp_dept
ALTER TABLE emp ADD CONSTRAINT pk_emp PRIMARY KEY (empno);
ALTER TABLE emp ADD CONSTRAINT fk_emp_dept FOREIGN KEY (deptno) REFERENCES dept (deptno);
emp : pk_emp (empno), idx
dept : pk _dept(deptno)
접근 방식 : emp 1. table full access, 2. 인덱스 *4 : 방법 5가지 존재
        dept 1. table full access, 2. 인덱스 * 1 : 방법 2가지 존재
        가능한 경우의 수 10가지
        방향성 emp, dept를 먼저 할지 생각 ==> 20가지
        
EXPLAIN PLAN FOR 
SELECT *
FROM emp,dept
WHERE emp.deptno = dept.deptno
    AND emp.empno = 7788;
    
SELECT *
FROM TABLE(dbms_xplan.display)

Plan hash value: 321019030
 
--------------------------------------------------------------------------------------------
| Id  | Operation                     | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |            |     1 |    54 |     2   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                 |            |       |       |            |          |--반복 : NESTED LOOPS 
|   2 |   NESTED LOOPS                |            |     1 |    54 |     2   (0)| 00:00:01 |
|*  3 |    TABLE ACCESS BY INDEX ROWID| EMP        |     1 |    36 |     1   (0)| 00:00:01 |--20번 부서를 받음
|*  4 |     INDEX RANGE SCAN          | IDX_NU_EMP |     1 |       |     0   (0)| 00:00:01 |
|*  5 |    INDEX UNIQUE SCAN          | PK_DEPT    |     1 |       |     0   (0)| 00:00:01 |
|   6 |   TABLE ACCESS BY INDEX ROWID | DEPT       |     8 |   144 |     1   (0)| 00:00:01 |--20번 값을 받고 dept 인덱스를 한다음에 row 
                                                                                            --dept 테이블에서id를 얻어내고 select 절을 조회한다
--------------------------------------------------------------------------------------------
 4 -> 3 -> 5 -> 2 -> 6 -> 1 ->0
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - filter("EMP"."DEPTNO" IS NOT NULL)
   4 - access("EMP"."EMPNO"=7788)
   5 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")
                --EMP"."DEPTNO 값이 상수로 변경 되었다 (20번)
                
상수조건을 부여하지 않고 조인 데이터를 다 실행 했을 때의 데이터를 확인해보자               
EXPLAIN PLAN FOR 
SELECT *
FROM emp,dept
WHERE emp.deptno = dept.deptno;

SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 844388907
 
----------------------------------------------------------------------------------------
| Id  | Operation                    | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |         |    13 |   702 |     6  (17)| 00:00:01 |
|   1 |  MERGE JOIN                  |         |    13 |   702 |     6  (17)| 00:00:01 | -- MERGE JOIN 
|   2 |   TABLE ACCESS BY INDEX ROWID| DEPT    |     8 |   144 |     2   (0)| 00:00:01 |
|   3 |    INDEX FULL SCAN           | PK_DEPT |     8 |       |     1   (0)| 00:00:01 |
|*  4 |   SORT JOIN                  |         |    14 |   504 |     4  (25)| 00:00:01 |
|*  5 |    TABLE ACCESS FULL         | EMP     |    14 |   504 |     3   (0)| 00:00:01 | --emp쪽은 인덱스를 읽지 않는다
----------------------------------------------------------------------------------------
 -- 3-> 2 -> 5 -> 4-> 1 -> 0
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")
       filter("EMP"."DEPTNO"="DEPT"."DEPTNO")
   5 - filter("EMP"."DEPTNO" IS NOT NULL)
   
   i/o의 기준이 다르다 알아두기 pt 참고

실습 idx 1)
CREATE TABLE dept_test2 AS 
SELECT *
FROM dept
WHERE 1 = 1;

CREATE INDEX idx_u_dept_test2_01 ON dept_test2(deptno);
CREATE INDEX idx_nu_dept_test2_02 ON dept_test2(dname);
CREATE INDEX idx_nu_dept_test2_03 ON dept_test2(deptno,dname);

실습 idx 2)
DROP INDEX idx_u_dept_test2_01;
DROP INDEX idx_nu_dept_test2_02;
DROP INDEX idx_nu_dept_test2_03;

실습 idx 3)

1.empno(=)

2. ename(=)

3.deptno(=) empno(like) ---선행은 = 인게 좋다 그래 서deptno 먼저 설정한다

4.deptno(=),sal(between)

5. deptno(=) 
    empno(=)
6. deptno,hiredate 컬럼으로 구성된 인덱스가 있을경우 table 접근이 필요 없음


--------인덱스 생성
1.empno(=)
2. ename(=)
3.deptno(=) empno(like)
4. deptno(=),sal(between)
5. deptno,hiredate

1.empno(=)
2. ename(=)
3.deptno,empno(like)),sal(between),hiredate

emp 테이블에 데이터가 5천만건 이고, 10,20,30 데이터는 각각 50건씩만 존재 ==> 인덱스가 유리
40번 데이터 4850만건 ==> 인덱스로 할 경우 느림 -> table full access 사용


0SELECT *
FROM emp,dept
WHERE emp.deptno = dept.deptno
AND emp.deptno = :deptno
AND emp.deptno LIKE :empno || '%';

과제 실습4
1. empno(=)
2. deptno(=)
3. deptno(=) empno(like)
4. deptno(=),sal(between)
5. deptno(=) loc(=)

1. empno
2. deptno ,sal,loc

ㄴ
SYNONYM : 오라클 객체체 별칭을 생성
une.v_emp => v_emp로 생성
생성방법 
CREATE [PUBLIC]SYNONYM 시노님이름 FOR 원본 객체이름;
PUBLIC : 을 사용하면 모든 사용자가 사용할 수 있는 시노님이 된다
        단, 권한이 있어야 생성가능
PRIVATE [DEFAULT] : 해당 사용자만 사용할 수 있는 시노님 --DEFAULT가 없다 하더라도 당연히 생성된다
DROP SYNONYM 시노님이름;












