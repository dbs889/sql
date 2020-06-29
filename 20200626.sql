SELECT *
FROM users;
SELECT *
FROM emp;

<복습>
숫자 : 4칙 연산
날짜 : +, -, 날짜 +- 정수 날짜에 정수만 과거나, 미래 날짜 값을 연산의 결과로 리턴
문자 : 결합연산자를 사용 ( ||, CONCAT )
SELECT empno, ename, sal, sal + 500, 500
FROM emp;

NULL : 아직 모르는 값, 정해지지 않은 값
       1.  NULL 과 숫자타입 0은 다르다
       2.  NULL 과 ''은 다르다
       3. NULL 값을 포함한 연산의 결과는 NULL  : 필요한 경우 NULL 값을 다른값으로 치환
       
alias : 별칭명, 컬럼 혹은 expression에 다른 이름을 부여
        컬럼 | expression [alias] 별칭명
        1. 공백 안됨 ==> "a lias" 가능
        
literal : 값 자체
리터럴 표기법 : ''

WHERE : 테이블에서 조회할 행의 조건을 기술
        WHERE 절에 기술한 조건을 만족하는 행만 조회가 된다
예제 
SELECT *
FROM emp
WHERE ename = 'SMITH';

WHERE 절에서 사용가능한 연산자 * !* <> >= <= < >
        BETWEEN AND 값이 특정 범위에 포함되는지 
        IN : 특정 값이 나열된 리스트에 포함되는지 검사 ==> OR로 대체 가능
        
1. WHERE절에서 사용 가능한 연산자 : LIKE
사용용도 :  문자의 일부분으로 검색을 하고 싶을 때 사용
            EX) ename 칼럼의 값이 s로 시작하는 사원들을 조회
사용방법 : 칼럽 LIKE '패턴문자열'
마스킹 문자열 : 1. %  : 문자가 없거나, 어떤 문자든지 여러개의 문자열
                EX) 's%' : s로 시작하는 모든 문자 열을 (s,ss,SMITH)
              2. _ : 어떤 문자든 딱 하나의 문자를 의미
                EX) 's_' : s로 시작하고 두번째 문자가 어떤 문자든 하나의 문자가 오는 2자리 문자열
                    's____' : s로 시작하고 문자열의 길이가 5글자인 문자열 ----> ____(4개)
q)emp테이블에서 ename 컬럼의 값이 s로 시작하는 사원들만 조회
Q1)
SELECT *
FROM emp
WHERE ename LIKE 'S%';

Q2) 
SELECT mem_id, mem_name
FROM member
WHERE  mem_name LIKE '신%';    

Q3) 
SELECT mem_id, mem_name
FROM member
WHERE  mem_name LIKE '이%'; -----> 오답(오류)

----<테이블에 들어 있는 내용을 바꾸는것>       
UPDATE member set mem_name = '쁜이'
WHERE mem_id = 'b001';
c001 신용환 ==> 신이환
UPDATE member set mem_name = '신이환'
WHERE mem_id = 'c001'; -----> where 절을 하지 않고 update하면 테이블 전체가 동일하게 수정된다!! where절 필수!!

Q3)
SELECT mem_id, mem_name
FROM member
WHERE  mem_name LIKE '%이%'; --->%% : 앞 뒤에 있으면 모두 조회 가능하다

2. NULL 비교 : =연산자로 비교 불가 ==> IS

comm 컬럼의 값이 null인 사원들만 조회
SELECT empno, ename, comm
FROM emp
WHERE comm = NULL; ----> 조회는 되지만 값이 조회 안됨

NULL값의 비교는 =이 아니라 IS 연산자를 사용 한다
SELECT empno, ename, comm
FROM emp
WHERE comm IS NULL; --NULL 값 데이터를 조회 할때는 IS 를 사용한다

Q4)emp테이블에서 comm 값이 NULL이 아닌 데이터를 조회
SELECT empno, ename, comm
FROM emp
WHERE comm IS NOT NULL; ---->NULL 값이 아닌 데이터를 조회 할때는 IS NOT를 사용한다

3. 논리연산 : AND, OR, NOT
AND : 참, 거짓 판단식1 AND 참 거짓 판단식2 ==> 식 두개를 동시에 만족하는 행만 참
        일반적으로 AND 조건이 많이 붙으면 조회되는 행의 수가 줄어든다
OR : 참, 거짓 판단식1 OR 참 거짓 판단식2 ==> 식 두개중에 하나라도 만족하면 참

Q5)emp 테이블에서 mgr 컬럼 값이 7698이면서 sal 컬럼의 값이 1000보다 큰 사원 조회
두 가지 조건을 동시에 만족하는 사원 리스트
SELECT *
FROM emp
WHERE mgr = 7698 AND sal > 1000; 

emp 테이블에서 mgr 컬럼 값이 7698(5명) 이거나 sal 컬럼의 값이 1000보다 큰 사원(12명) 조회
두 가지 조건을 하나라도 만족하는 사원 리스트
SELECT *
FROM emp
WHERE mgr = 7698 OR sal > 1000; 

4. NOT : 조건을 반대로 해석하는 부정형 연산
    NOT IN 
    IS NOT NULL
    
Q6)emp 테이블에서 mgr가 7698, 7839가 아닌 사원들을 조회
SELECT *
FROM emp
WHERE mgr NOT IN (7698, 7839); ----->NULL값이 뺴고 조회됨
**** mgr 컬럼에 NULL 값이 있을 경우 비교연산으로 NULL 비교가 불가하기 떄문에 NULL 갖는 행은 무시가 된다

mgr 사번이 7698이 아니고, 7839가 아니고, NULL이 아닌 직원들을 조회
SELECT *
FROM emp
WHERE mgr NOT IN (7698, 7839,  NULL); ----> 데이터 값이 안 나옴 
 mgr IN (7698, 7839,  NULL); ==> mgr = 7698 OR mgr  = 7839  OR mgr  = NULL
 mgr NOT IN (7698, 7839,  NULL); ==> mgr != 7698 AND mgr ! = 7839  AND mgr != NULL; ---> 앞에 어떤 조건이 오더라도 NULL이 있기 때문에 결과는 FALSE이다 따라서 결과가 안 나온다
                                                                                       ---> IN 연산자에서는 NULL이 오더라도 결과가 나올 수 있다     
mgr IN (7698, 7839) ==> OR   ------>IN은 OR의 역할을 한다
mgr = 7698 OR mgr = 7839

mgr NOT IN (7698, 7839)  --->IN의 부정
!(mgr 7698 OR = 7839) ==>!(mgr != 7698 AND != 7839) 

SELECT *
FROM emp
WHERE mgr != 7698 AND mgr != 7839;


Q7) 
SELECT *
FROM emp
WHERE job = 'SALESMAN' AND hiredate >= TO_DATE('1981/06/01','YYYY/MM/DD'); ---->테이블은 대 소 문자를 가린다

 ---invalid identifier : 오류 식별
 
Q8)
SELECT *
FROM emp
WHERE deptno != 10 AND hiredate >= TO_DATE('1981/06/01','YYYY/MM/DD');

Q9)
SELECT *
FROM emp
WHERE deptno NOT IN(10) AND hiredate >= TO_DATE('1981/06/01','YYYY/MM/DD');

Q10)
SELECT *
FROM emp
WHERE deptno IN(20,30) AND hiredate >= TO_DATE('1981/06/01','YYYY/MM/DD');

Q11)
SELECT *
FROM emp
WHERE job = 'SALESMAN' OR hiredate >= TO_DATE('1981/06/01','YYYY/MM/DD');

Q12) emp 테이블에서 SALSEMAN 이거나 사원번호가 78로 시작하는 직원의 정보 조회
SELECT *
FROM emp
WHERE job = 'SALESMAN' OR empno LIKE '78__'; ----->'78%' 도 가능하지만 묵시적 형변환(오라클에서 알아서)이 일어난다

Q13)
SELECT *
FROM emp
WHERE job = 'SALESMAN' OR empno >= 7800 AND empno <=7899;

Q13) empno 7800~7899,781,78;
SELECT *
FROM emp
WHERE job = 'SALESMAN' OR empno BETWEEN 7800 AND 7899 
                        OR empno BETWEEN 780 AND 789;
                        OR empno = 78;


 
 6.  연산자 우선순위
 + - * /
 * / > + -

 3 + 5 * 7 = 38

Q14) 
SELECT *
FROM emp
WHERE job = 'SALESMAN' OR (empno LIKE '78__' AND hiredate >= TO_DATE('19810601', 'YYYYMMDD'));


7. SQL 작성 순서(반드시는 아니다)
1. SELECT 2 FROM 3 WHERE 4. ORDER BY
8. ORACLE 실행하는 순서
1. FROM  2. WHERE 3.SELECT 4. ORDER BY 순서순으로 처리한다(해석한다)

9. 정렬
RDBMS 집합적인 사상을 따른다
집합에는 순서가 없다 {1, 3, 5} == {3, 5, )}
집합에는 중복이 없다 {1, 3, 5, 1} == {3, 5, 1)}

1. 정렬 방법 ORDER BY 절을 통해 정렬 기분 컬럼을 명시
            컬럼뒤에 [ASC | DESC] 을 기술하여 오름차순, 내림차순을 지정할 수 있다
    1)  ORDER BY 컬럼
    2)  ORDER BY 별칭 
    3)  ORDER BY 절에 나열된 컬럼의 인덱스 번호
    
--<이름 정렬하기-오름차순>
SELECT *
FROM emp
ORDER BY ename;

--<이름 정렬하기-내림차순>
SELECT *
FROM emp
ORDER BY ename DESC;

--<중복이된 값을 정렬 할때-두번째 정렬 추가- 첫번째 오름차순-두번쨰 내림차순으로>
SELECT *
FROM emp
ORDER BY ename DESC, mgr ASC;

Q) 별칭으로  ORDER BY 하기 
SELECT empno, ename, sal, sal * 12 salary
FROM emp
ORDER BY salary; --별칭

SELECT 절에 나열된 컬럼순서(인덱스) 로 정렬 
SELECT empno, ename, sal, sal * 12 salary
FROM emp
ORDER BY 4; ---나열된 컬럼 순서

Q)
SELECT *
FROM dept
ORDER BY dname ;

SELECT *
FROM dept
ORDER BY loc DESC;

Q)상여가 있는 사람 조회, 단 상여가 0이면 없는것
SELECT *
FROM emp
WHERE comm > 0
ORDER BY comm DESC, empno DESC;

과제 
Q3
SELECT *
FROM emp
WHERE mgr > 0
ORDER BY job, empno DESC;

Q4
SELECT *
FROM emp
WHERE deptno IN (10,30) AND sal >=1500
ORDER BY ename DESC;
