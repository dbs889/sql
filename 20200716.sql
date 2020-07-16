SELECT*
FROM emp e
WHERE EXISTS(SELECT 'X'
            FROM emp m
            WHERE e.mgr = m.empno);
            
과제
1. emp empno(=)
2. dept dept(=)
3. emp가 먼저읽는다는 가정하에 
    emp deptno(=),empno(like)
    dept deptno(=)
4. emp deptno(=),sal(between)
5. 
emp deptno(=)
dept deptno(=),loc(=)
dept를 먼저 읽는 경우
emp empno(=)
dept loc(=)

1. empno(=) e.1
    deptno empno
    deptno sal
    2-2 deptno,empno,sal

  1.deptno,loc --emp테이블을 먼저 생각 할때
   2. loc ---dept테이블을 먼저 생각 할 때

개발자가 sql을 dbms에 요청을 하더라도
1. 오라클 서버가 항상 최적의 실행계획을 선택 할 수는 없음
    (응답성이 중요하기 때문 :OLTP -온라인 트랜잭션 프로세싱
    전체 처리 시간이 중요 :  OLAP - Online Analytical Proccessing 
                        은행이자 ==> 실행계획 세우는 30분이상이 소요 되기도 함)
2. 항상 실행계획을 세우지 않음
    만약 동일한 sql이 이미 실행된적이 있으면 해당 sql의 실행계획을 새롭게 세우지 않고 
    shared pool(메모리)에 존재하는 실행계획을 재사용
    
    동일한 sql :  문자가 완벽하게 동일한 sql
                sql의 실행결과가 같다고 해서 동일한 sql이 아님
                대소문자를 가리고, 공백도 문자로 취급
    EX : select * FROM emp;
         SELECT * FROM emp; 두 개의 sql의 서로 다른 sql로 인식
         
SELECT /* plan_test */ *
FROM emp
WHERE empno = 7698;

select /* plan_test */ *
FROM emp
WHERE empno = 7698;

select /* plan_test */ *
FROM emp
WHERE empno = 7369; ---값 바꿀경우 새로운 sql로 인식

select /* plan_test */ *
FROM emp
WHERE empno = : empno; 


물리적 조인 
Nested Loop JOIN --인덱스가 없으면 루프를 돌면서 계속 찾아 비효율적이다
먼저 읽을 테이블을 정하고 후행테이블을 읽는다
OLTP환경에서 활용
소량의 데이터 조인 -응답성이 빠름
대량의 데이터가 있을 때 싱글블럭 IO가 부담이되는 단점이 있다
응답성 1번째로 빠름
Sort Merge JOIN
조인 컬럼에 인덱스가 없을 경우
대량의 데이터를 조인하는 경우
조인되는 테이블을 각각 정렬 -조인되는 컬럼의 값으로 정렬 양쪽 테이블의 값을 빠르게 찾음
정렬이 되면 조인조건에 해당 데이터를 찾기가 유리
정렬을 해야하기 때문에 응답성이 느림 --정렬이 끝나기전까지 응답을 할 수 없음
HASH조인과 다른 점 : =이 아니어도 가능
응답성 3번째
Hash JOIN
조인 컬럼에 인덱스가 없을 경우 -인덱스 사용 가능
한쪽은 적고 다른 한쪽은 데이터가 많을경우 --테이블이 한쪽이 적은 쪽을 해쉬테이블을 만들어 적용해야한다
연결 조건이 =인 경우 --컬럼의 변종된 값을 사용하므로 =조건이 아닌 조인조건은 사용 불가
CPU자원을 통하여 HASH 함수의 결과 값이 같은 데이터를 추출
응답성 2번째

<B tree>
노드 
* root
* branch
*leaaf : 데이터를 빠르게 찾아가는 용도


접속 권한/생성권한
GRANT CONNECT, RESOURCE TO use_name

DCL 
:Data Control Language : 시스템 권한 또는 객체 권한을 부여/회수

DCL-1 부여
GRANT 권한명 | 롤명 TO 사용자;

DCL-2 회수
REVOKE 권한명 | 롤명 FROM 사용자;

1. 권한
1-1. 시스템권한 :접속을 할 수 있는 권한, 테이블 생성 권한, 시퀀스 생성권한, 사용자생성권한 등
CONNECT, RESOURCE TO --RESOURCE : ROLE이다 
REVOKE RESOURCE FROM
1-2. 객체 권한 : 실제 만들어진 객체에 수정,삭제,조회,입력,인덱스에 대한 권한
GRANT SELECT INSERT ON TO
REVOKE SELECT INSERT ON FROM

WITH GRANT OPTION 
객체권한은 다 같이 회수
시스템 권한은 첫번째 사용자가 두번쨰 사용자에 대해 회수를 하더라도 세번째 사용자한테는 회수하지 않는다


2. 스키마 : 사용자들의 동의
3.ROLE : 권한들의 집합

DATA DICTIONARY
: 오라클 서버가 사용자 정보를 관리하기 위해 저장한 데이터를 볼 수 있는 VIEW

조회
SELECT *
FROM dictionary; ---804건 조회

카테고리(접두어)
USER_ : 해당 사용자가 소유한 객체 조회
ALL_ :해당 사용자가 소유한 객체 + 권한을 부여받은 객체 조회
DBA_ : 데이터베이스에 설치된 모든 객체(DBA권한이 있는 사용자만 가능 -우리는 SYSTEM계정)
V$ : 성능 ,모니터와 관련된 특수 VIEW

자주쓰는 것 
1. 테이블 정보
1.1 
SELECT *
FROM user_tables;

1.2
SELECT *
FROM all_tables; --94건

1.3
SELECT *
FROM dba_tables;  ---시스템계정에서 조회 가능 1712건

2. 테이블의 컬럼 정보 :tab_columns
3. 인덱스에 대한 정보
4. 제약조건 정보 : CONSTRAINTS
    제약조건 컬럼 정보 CONS_COLUMNS
