날짜관련 오라클 내장함수
내장함수 : 탑재가 되어있다
            오라클에서 제공해주는 함수 (많이 사용하니까, 개발자가 별도로 개발하지 않도록)
            
(활용도 : *)MONTHS_BETWEEN(date1, date2) : 두 날짜 사이의 개월수를 반환 --일수가 다르면 소수점으로 계산(ex 1.2312개월)
(활용도 :*****)ADD_MONTHS(date1, NUMBER) : DATE1 날짜에 NUMBER 만큼의 개월수를 더하고, 뺀 날짜 반환
(활용도 :***)NEXT_DAY(date, 주간요일(1~7)) : date1 이후에 등장하는 첫번째 주간요일의 날짜 반환
                                            (ex 20200630, 7 (2020년 6월 30일 이후에 해당하는 첫번째 토요일은?) ==> 20200704
(활용도 :***)LAST_DAY(date1) : date1 날짜가 속한 월의 마지막 날짜 반환     
                                (ex 2020605 ===> 20200630)
                                모든 달의 첫 번째 날짜는 1일로 정해져 있음
                                하지만 달의 마지막 날짜는 다른 경우가 있다
                                윤년의 경우 2월달이 29일임.

SELECT ename, TO_CHAR(hiredate, 'YYYY-MM-DD') hiredate,
        MONTHS_BETWEEN(SYSDATE, hiredate)
FROM emp;

Q) 오늘 날짜에서 5개월 뒤의 날짜, 5개월 전 날짜(마지막 날짜기준으로 계산)
SELECT ADD_MONTHS(SYSDATE ,5) aft5,
        ADD_MONTHS(SYSDATE ,-5) bef5
FROM dual;

NEXT_DAY : 해당 날짜 이후에 등장하는 첫번째 주간요일의 날짜

Q) SYSDATE : 2020/06/3일 이후에 등장하는 첫번째 토요일(7)은 몇일인가?
SELECT NEXT_DAY(SYSDATE,7)
FROM dual;

LAST_DAY : 해장 일자가 속한 월의 마지막 일자를 반환

Q) SYSDATE : 2020/06/30 실습 당일의 날짜가 월의 마지막이라 SYSDATE 대신 임의의 날짜 문자열로 테스트(2020/06/05)
SELECT LAST_DAY(TO_DATE('2020/06/05', 'YYYY/MM/DD'))
FROM dual;

 LAST_DAY는 있는데 FIRST_DAY는 없다 ==> 모든 월의 첫번째 날짜는 동일(1일)
 
Q) FIRST_DAY 직접 SQL로 구현
  SYSDATE 20200630 ==> 20200601 (마지막 날짜를 처음날짜(1일)로 변경
1. SYSDATE를 문자로 변경하는데 포맷은 YYYYMM ----TO_CHAR
2. 1번의 결과에다가 문자열 결함을 통해 '01' 문자를 뒤에 붙여 준다 ----CONCAT
    YYYMMMDD
3. 2번의 결과를 날짜 타입으로 변경----TO_DATE

SELECT TO_DATE(CONCAT(TO_CHAR(SYSDATE, 'YYYYMM'), '01'), 'YYYY-MM-DD') firstday,
            TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM') || '01', 'YYYY-MM-DD') firstday
FROM dual;  

Q)PPT FN3 '201602' ==> 29,  해당 년월의 일수(마지막 날짜) ==> LAST_DAY
SELECT  param param, TO_CHAR(LAST_DAY((TO_DATE(: param), 'DD') dt1
FROM dual;

SELECT  
    TO_CHAR(LAST_DAY('20191201'), 'YYYYMM') param, TO_CHAR(LAST_DAY('20191201'), 'DD') dt,
        TO_CHAR(LAST_DAY('20191101'), 'YYYYMM') param1, TO_CHAR(LAST_DAY('20191101'), 'DD') dt1,
        TO_CHAR(LAST_DAY('20160201'), 'YYYYMM') param2, TO_CHAR(LAST_DAY('20160201'), 'DD') dt2  
FROM dual;



실행계획 : dbms가 요청 받은 sql을 처리하기 위해 세운 절차
        SQL 자체에는 로직이 없다(어떻게 처리 해라 가 없다. JAVA랑 다른점)
실행계획 보는 방법 : 
1. 실행계획을 생성하는 단계
EXPLAIN PLAN FOR
실행계획을 보고자 하는 SQL

2. 실행계획을 보는 단계
SELECT
FROM TABLE(dbms_xplan.display);
            --오라클에서 제공하는 패키지 중 한개(리턴하는 값을 테이블로 바꿔주는 함수)



empno 컬럼은 NUMBER 타입이지만 형변환이 어떻게 일어 났는지 확인하기 위해
의도적으로 문자열 상수 비교를 진행

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = '7369';

SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 3956160932
 실행계획 읽는 방법 : 
 1. 위에서 아래로
 2. ****중요*****단 자식 노드가 있으면 자식 노드부터 읽는다
    자식 노드 : 들여쓰기가 된 노드
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    38 |     3   (0)| 00:00:01 |--읽는 순서 2번째
|*  1 |  TABLE ACCESS FULL| EMP  |     1 |    38 |     3   (0)| 00:00:01 | -- TABLE ACCESS FULL 앞에 들여쓰기가 되므로 자식 노드(읽는 순서는 1이 첫번째)
----------------------------------------------------------------------------
 --각 단계에 번호를 부여 *특수한 정보
Predicate Information (identified by operation id): ---특수한 정보를 나타냄 
---------------------------------------------------
 
   1 - filter("EMPNO"=7369)
        --거른다라는 의미 --> 7369가 숫자로 변환(묵시적 형변환)
        
EXPLAIN PLAN FOR     
SELECT *
FROM emp
WHERE TO_CHAR(empno) = '7369';

SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 3956160932
 
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    38 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP  |     1 |    38 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter(TO_CHAR("EMPNO")='7369') ----문자열로 변환하는 과정을 거침
   
EXPLAIN PLAN FOR     
SELECT *
FROM emp
WHERE empno = 7369 + '69';

SELECT *
FROM TABLE(dbms_xplan.display);

Plan hash value: 3956160932
 
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    38 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP  |     1 |    38 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("EMPNO"=7438) ----숫자로 변경되었다
   
   
   칠거지약 ; 실행계획에 관심을 가져라
   
형변환 --형변환이 자유스럽다

6,000,0 <==> 60000010
국제화 : i18n
날짜 국가별로 형식이 다르다
한국 : yyyy-mmdd
미국 : mm-dd-yyyy
숫자
한국 : 9,000,000.00
독일 : 9.000.000,00

Q)sal( NUMBER) 컬럼의 값을 문자열 포맷팅 적용
SELECT ename, sal, TO_CHAR(sal, 'L9,999.00') ---L은 원 표시
FROM emp;

Q)다시 숫자로 표현하는법
SELECT ename, sal, TO_NUMBER(TO_CHAR(sal, 'L9,999.00'), 'L9,999.00') -
FROM emp;

***자격증출제***NULL과 관련된 함수 : NULL값을 다른값으로 치환하거나, 혹은 강제로 NULL을 만드는것
1. NVL(expr1, expr2)
--java식 표현
    if(expr == null)
        expr2를 반환; 
        else
        expr1를 반환; 
        
SELECT empno, sal, comm, NVL(comm, 0), --comm이 null인 값은 0으로 조회 100으로 조회하면 100입력
        sal + comm, sal + NVL(comm, 0)
FROM emp;       
        
        
2. NVL2(expr1, expr2, expr3)
--java식 표현
    if(expr1 != null)
        expr2 를 반환
    else 
        expr 3을 반환;
        
SELECT empno, sal, comm, NVL2(comm, comm, 0), 
        sal + comm, sal + NVL2(comm, comm, 0), NVL2(comm, sal + comm, sal)
FROM emp;      

3. NULLIF(expr1,expr2) : null값을 생성하는 목적
--java식 표현
    if(expr1 == expr2)
        null 를 반환
    else 
        expr1을 반환;
        
SELECT ename, sal, comm, NULLIF(sal, 3000) ---sal값이 3000이면 null을 실행 하겠다
FROM emp;         
        
4. COALESCE(expr1, expr2......) --가변식이 없다

인자중에 가장 처음으로 null값이 아닌 값을 갖는 인자를 반환
COALESCE(NULL, NULL, 30, NULL, 50) ==> 30
--java식 표현
    if(expr1 != null)
       expr1 를 반환
    else 
         COALESCE(expr2......) --첫번째 인자를 제외한 두번째부터 다시 시작 --재귀호출
         
SELECT COALESCE(NULL, NULL, 30, NULL, 50)
FROM dual;        

NULL처리 실습

emp테이블에 14명의 사원이 존재, 한명을 추가(INSERT)

INSERT INTO emp( empno, ename, hiredate) VALUES(999, 'brown', NULL);
1명 추가 되어 15명 조회된다

Q)조회컬럼 : ename, mgr, 
            mgr컬럼 값이 NULL이면 111로 치환한값 - NULL이 아니면 mgr 컬럼값
            hiredate, hiredate가 NULL이면 SYSDATE로 표기 - NULL이 아니면 hiredate 컬럼값

SELECT empno, mgr, 
        NVL(mgr, 111), 
        hiredate, NVL(hiredate, SYSDATE)
FROM emp;   

SELECT empno, ename, mgr, 
        NVL(mgr, 9999) mgr_n,
        NVL2(mgr, mgr, 9999) mgr_n_1,
        COALESCE(null, null, null, mgr, 9999)  mgr_n_2
FROM emp; 

Q) users 테이블의 정보를 userid, usernm, reg_dt, reg_dt가 null일경우 sysdate를 적용하여 나타내시오
    brown을 없애시오
SELECT userid, usernm, reg_dt, NVL(reg_dt, SYSDATE) n_reg_dt
FROM users 
WHERE userid NOT IN('brown'); -----조건절 잊지 말자!!
        -- userid != 'brown'
        
SQL 학습 진행 상황
SELECT ROUND((6/28)*100,2) || '%'
FROM dual;
        
<SQL 조건문>
CASE
    WHEN 조건문(참 거짓을 판단할 수 있는 문장) THEN 반환할 값
    WHEN 조건문(참 거짓을 판단할 수 있는 문장) THEN 반환할 값2
    WHEN 조건문(참 거짓을 판단할 수 있는 문장) THEN 반환할 값3
    ELSE 모든 WHEN절을 만족시키지 못할 때 반환할 기본 값
END
==>하나의 컬럼처럼 취급

Q)emp테이블에 저장된 job컬럼의 값 기준으로 급여(sal)컬럼를 인상시키려고 한다
sal 컬럼과 함계 인상된 sal 컬럼의 값을 비교하고 싶은 상황

급여 인상 기준
job이 SALESMAN sal * 1.05
job이 MANAGER sal * 1.10
job이 PRESIDENT sal * 1.20
나머지 기타 직군은 sal로 유지

SELECT ename, job, sal , 
        CASE
         WHEN job = 'SALESMAN' THEN sal * 1.05 --5%인상한 금액
         WHEN job = 'MANAGER' THEN sal * 1.10
         WHEN job = 'PRESIDENT' THEN sal * 1.20
         ELSE sal
        END inc_sal--case~end까지 하나의 컬럼
FROM emp; 

Q) 실습 cond1
SELECT empno, ename,
        CASE
         WHEN deptno = '10' THEN 'ACCOUNTING' --5%인상한 금액
         WHEN deptno = '20' THEN 'RESEARCH'
         WHEN deptno = '30' THEN 'SALES'
         WHEN deptno = '40' THEN 'OPERATIONS'
         ELSE 'DDIT'
        END dname
FROM emp; 

SELECT empno, ename,
        DECODE( deptno, '10', 'ACCOUNTING', --5%인상한 금액
                        '20', 'RESEARCH',
                        '30','SALES',
                        '40', 'OPERATIONS',
                        'DDIT') bonus
FROM emp; 


