SELECT *
FROM emp;

SELECT *
FROM dept;


<DELETE : 행 자체를 삭제하는 것>

DELETE emp
WHERE empno > 9000; 

commit;

UPDATE : 상수값으로 업데이트 ==> 서브쿼리 사용 가능
INSERT INTO emp(empno,ename,job) VALUES (9999,'brown','RANGER');

방금입력한 9999번 사원번호를 갖는 사원의 deptno와 job의 값을 SMITH사원의 deptno와 job으로 업데이트

UPDATE emp SET deptno = (SELECT deptno FROM emp WHERE ename = 'SMITH'),  ----결과행도 하나 
                job = (SELECT job FROM emp WHERE ename = 'SMITH')
WHERE empno = 9999;

==> UPDATE 쿼리1 실행 할 때 안쪽 SELECT 쿼리가 2개가 포함됨 --권장되는 형태가 아님
고정된 값을 업데이트 하는게 아니라 다른 테이블에 있는 값을 통해서 업데이트 할 때
비효율이 존재
==> MERGE 구문을 통해 보다 효율적으로 업데이트가 가능

DELETE : 테이블의 행을 삭제 할 때 사용하는 SQL
         특정 컬럼만 삭제하는 거는 UPDATE
         DELETE 구문은 행 자체를 삭제
            1. 어떤 테이블에서 삭제할지
            2. 테이블의 어떤 행을 삭제 할지
문법 
DELETE [FROM] 테이블명
WHERE 삭제할 행을 선택하는 조건;

UPDATE 쿼리를 실습시 9999번 사원을 등록 함, 해당 사원을 삭제하는 쿼리를 작성

DELETE emp
WHERE empno =9999;

DELETE 쿼리도 select 쿼리 작성시 사용한 WHERE 절과 동일
서브쿼리 사용 가능

사원중에 mgr가 7698인 사원들만 삭제

DELETE emp
WHERE mgr =7698;

응용) 위의 쿼리와 같은 결과 값
DELETE emp
WHERE empno IN (SELECT empno FROM emp WHERE mgr =7698);

ROLLBACK;

DBMS의 경우 데이터의 복구를 위해서
DML 구문을 실행할 때마다 로그를 생성

대량의 데이터를 지울 때는 로그 기록도 부하가 되기 때문에 
개발환경에서는 테이블의 모든 데이터를 지우는 경우에 한해서
TRUNCATE TABLE 테이블명; 명령을 통해

로그를 남기지 않고 빠르게 삭제가 가능하다
단, 로그가 없기 떄문에 복구가 불가능하다

emp테이블을 이용해서 새로운 테이블을 생성
CREATE TABLE emp_copy AS
SELECT *
FROM emp;

SELECT *
FROM emp_copy;

<테이블 삭제하는 법>
TRUNCATE TABLE emp_copy;
ROLLBACK;

<트랜잭션>TRANSACTION

SELECT *
FROM dept;

COMMIT,ROLLBACK 을 하지 않은 상태에서는 다른사람의 트랜잭션에 반영되지 않는다
INSERT INTO dept VALUES
(99,'ddit','daejeon');

다른사람의 트랜잭션에 반영된다
INSERT INTO dept VALUES
(99,'ddit','daejeon');

COMMIT;

읽기 일관성을 4단계로 구분한다
레벨은 DBMS마다 다르다
LV 0 : DIRTY READ : 커밋되지 않아도 다른 트랜잭션에서 읽을 수 있다 (ORACLE은 지원하지 않음)

LV 1 : 대부분의 DBMS기본 설정 : 커밋되지 않은 데이터는 다른 트랜잭션에서 볼 수 없다

LEVERL 1 : repeatable read;
선행 트랜잭션에서 읽은 데이터를 후행 트랜잭션에서 수정하지 못하게끔 막아, 선행 트랜잭션안에서 항상 동일한 데이터가 조회 되도록 보장하는 레벨

예제
--트랜잭션 시작
SELECT *
FROM dept
WHERE deptno =99;

후행 트랜잭션에서 업데이트하고 커밋했음 
--> 내 트랜잭션이 수정 됨 이걸 방지 하기 위한게 lv2

----트랜잭션 종료

LV 2 : 다른 트랜잭션에서 데이터를 수정,삭제하지 못한다
99번 부서의 부서명, loc정보를 유지하고 싶음, 다른 트랜잭션에서 수정하지 못하도록 막고 싶음
    단, 후행 트랜잭션에서 신규 데이터를 입력할때는 제어하지 못한다 ==>Phantom read : 전에 없던 데이터가 새로 조회되는 현상

--트랜잭션 시작
SELECT *
FROM dept
WHERE deptno =99
FOR UPDATE;
-----트랜잭션 종료
ROLLBACK; ---후행 트랜잭션의 작업이 실행된다

PHANTOM READ : 
LV 2에서는 테이블에 존재하는 데이터에 대해 후행 트랜잭션에서 작업하지 못하도록 막을 수는 있지만 후행 트랜잭션에서 신규로 입력하는 데이터는 막을 수 없다
즉 선행 트랜잭션에서 처음 읽은 데이터와 후행 트랜잭션에서 신규입력 후 커밋한 이후에 조회된 데이터가
불일치 할 수 있다(없던 데이터가 갑자기 생성되는 현상)

5개의 데이터가 조회됨
SELECT *
FROM dept
ROLLBACK;

후행 트랜잭션 신규 입력 후 데이터가 6개 조회됨
LV 3

SERIALIZABLE READ
후행 트랜잭션이 데이터를 입력, 수정 , 삭제하더라도 선행트랜잭션에서는 트랜잭션 시작 시점의 데이터가 보이도록 보장

SET TRANSACTION ISOLATION LEVEL
SERIALIZABLE;
--SERIALIZABLE : 직렬화

98,99 포함 6개의 데이터가 존재
SELECT *
FROM dept

후행 트랜잭션에서 dwpt테이블에 데이터 입력 후 commit;
---팬텀 리드 현상이 사람짐

ROLLBACK;

DML (data manipulation Language) : 데이터를 다루는 SQL
SELECT INSERT UPDATE DELETE


DDL (Data Definition Laguage) : 데이터를 정의하는 SQL
DDL은 자동 커밋, ROLLBACK이 불가
ex) 테이블을 생성하는 DDL 실행 ==> 롤백 불가
    ==> 테이블 삭제 DDL을 실행 
    
데이터가 들어갈 공간(table) 생성, 삭제
컬럼 추가
각종 객체 생성, 수정, 삭제;

<테이블 삭제 >
문법
DROP 객체종류 객체이름;
DROP TABLE emp_copy;
삭제한 테이블과 관련된 데이터는 삭제
    [나중에 배울 내용 제약 조건] 이런 것들도 다 같이 삭제
==> 테이블과 관련된 내용은 삭제;

SELECT *
FROM emp_copy; ----테이블을 삭제하여 테이블이 존재하지 않는다

DML문과 DDL문을 혼합해서 사용할 경우 발생할 수 있는 문제점
==>의도와 다르게 DML문에 대해서 COMMIT이 될 수 있다

SELECT *
FROM emp;
-----------트랜잭션 시작
INSERT INTO emp (empno,ename)VALUES (9999,'brown'); 

SELECT COUNT(*) ---추가하여 15건이 조회
FROM emp;

DROP TABLE batch;

ROLLBACK; ---DDL은 자동 커밋되어 롤백이 불가

SELECT COUNT(*)
FROM emp;
-------------트랜잭션 종류

<테이블생성>
문법
CREATE TABLE 테이블명(
    컬럼명1 컬럼1타입,
    컬럼명2 컬럼2타입,
    컬럼명3 컬럼3타입 DEFAULT 기본값
);

실습 ranger라는 이름의 테이블 생성
CREATE TABLE ranger (
    ranger_no NUMBER,
    ranger_nm VARCHAR2(50),
    reg_dt DATE DEFAULT SYSDATE
);

SELECT *
FROM ranger;

INSERT INTO ranger (ranger_no,ranger_nm) VALUES (100,'brown'); 
                    ---날짜를 조회하지 않았지만 위의 테이블 생성 할 때  DEFAULT 문장을 넣어 sysdate가 조회된다

    
<컬럼의 데이터 타입>
문자 관련 데이터 타입
VARCHAR2()
CHAR() ---문제가 될 소지가 많아 VARCHAR2()를 많이 애용한다


<데이터 무결성>
데이터 무결성 : 잘못된 데이터가 들어가는 것을 방지하는 성격
ex) 1. 사원 테이블에 중복된 사원번호사 등록되는 것을 방지
    2. 반드시 입력이 되어야 되는 컬럼의 값을 확인
    ==> 파일시스템이 갖을 수 없는 성격 
    
오라클에서 제공하는 데이터 무결성을 지키기 위해 제공하는
제약 조건 5가지(4가지)

1. NOT NULL  ---CHECK제약조건이지만 많이 이용해서 별도의 키워드로 나타낸다
    해당 컬럼에 값이 NULL값이 들어오는 것을 제약 , 방지
    (ex.emp 테이블의 empno 컬럼)
    
2. UNIQUE
    전체 행중에 해당 컬럼의 값이 중복이 되면 안된다
    (ex.emp 테이블의 empno 컬럼이 중복이 되면 안된다)
    단 NULL에 대한 중복은 허용한다
    
3. PRIMARY KEY = UNIQUE + NOT NULL

4. FOREIGN KEY ---내가 참조하려는 테이블과도 관련이 있다
    연관된 테이블에 해당 데이터가 존재해야만 입력 가능
    emp테이블과 dept테이블은 deptno 컬럼으로연결이 되어있음
    emp테이블에 데이터를 입력 할 떄 dept 테이블에 존재하지 않는
    deptno 값을 입력하는 것을 방지
    
5. CHECK 제약조건
    컬럼에 들어오는 값을 정해진 로직에 따라 제어
     (ex 어떤 테이블의 성별 컬럼이 존재하면
        남성 = M, 여성 = F
        M,F 두가지 값만 저장 될수 있도록 제어
        
        C 성별을 입력하면? 시스템 요구사항을 정의 할 때
        정의 하지 않은 값이기 때문에 문제가 될 수 있다)
        
제약조건의 생성
제약조건 생성 방법
1. 테이블 생성시 , 컬럼 옆에 기술하는 경우
    * 상대적으로 세세하게 제어 불가

2. 테이블 생성시, 모든 컬럼 기술 이후 제약 조건만 별도로 기술
    1번 보다 세세하게 제어하는게 가능
    
3. 테이블 생성 이후, 객체 수정명령을 통해 제약조건을 추가


문제) 1번 방법으로 PRIMARY KEY 생성
dept 테이블과 동일한 컬럼명, 타입으로 dept_test라는 테이블 이름으로 생성

1. dept테이블의 구성정보 확인

DESC dept;
2. 테이블 생성 -컬럼옆에 기술한다
CREATE TABLE dept_test(
    DEPTNO  NUMBER(2) PRIMARY KEY,   
    DNAME   VARCHAR2(14),
    LOC     VARCHAR2(13) 
);

SELECT *
FROM  dept_test

PRIMARY KEY 제약조건 확인
UNIQUE + NOT NULL

1. NULL값 입력 테스트
PRIMARY KEY 제약조건에 의해 deptno 컬럼에는 null값이 들어 갈 수 없다
INSERT INTO dept_test VALUES (null,'ddit','daejeon'); -- cannot insert NULL into NULL값을 입력할 수 없다


2. 값 중복 테스트
INSERT INTO dept_test VALUES (99,'ddit','daejeon'); --99번 부서는 dept_test에 존재

deptno 컬럼의 값이 99번인 데이터가 이미 존재하기 때문에 중복 데이터로 입력이 불가능
INSERT INTO dept_test VALUES (99,'ddit2','대전'); ---제약 조건에 의해 에러가 발생


현 시점에서 dept 테이블에는 deptno 컬럼에 PRIMARY KEY 제약이 걸려있지 않은 상황
==> PRIMARY KEY 제약조건이 없으므로 중복데이터가 들어 갈 수 있다 
==> 이미 존재하는 10번 부서 추가로 등록
INSERT INTO dept VALUES (10,'ddit','daejeon'); ---행 삽입된다

SELECT *
FROM  dept;

테이블생성시 제약조건 명을 설정한 경우
DROP TABLE dept_test;

컬럼명, 컬럼 타입  CONSTRAINT 제약조건이름 제약조건타입 (PRIMARY KEY)
PRIMARY KEY 제약조건 명명 규칙 : PK_테이블명
CREATE TABLE dept_test(
    DEPTNO  NUMBER(2) CONSTRAINT PK_dept_test PRIMARY KEY,   
    DNAME   VARCHAR2(14),
    LOC     VARCHAR2(13) 
);

INSERT INTO dept_test VALUES (99,'ddit','daejeon'); 
INSERT INTO dept_test VALUES (99,'ddit2','대전'); ---입력이 되지 않는다
