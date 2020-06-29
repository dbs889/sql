ROWNUM : SELECT 순서대로 행번호를 부여해주는 가상 컬럼
특징 : WHERE 절에서 사용 하는게 가능
*** 사용 할 수 있는 형태가 정해져 있음
WHERE ROWNUM = 1; -- ROWNUM이 1일 때
WHERE ROWNUM <= N; -- ROWNUM이 N보다 작거나 같은 경우, 작은 경우
WHERE ROWNUM BETWEEN 1 AND N; --ROWNUM이 1보다 크거나 같고 N보다 작거나 같은 경우

==> ROWNUM은 1부터 순차적으로 읽는 환경에서만 사용이 가능

***안되는 경우
WHERE ROWNUM = 2;
WHERE ROWNUM >= 2;

 ROWNUM 사용 용도 : 페이징 처리
 페이징 처리 : 네이버 카페에서 게시글 리스트를 한 화면에 제한적인 갯수로 조회(100개)
            카페 전체 게시글 수는 굉장히 많음 
            ==> 한 화면에 못 보여줌(1.웹브라저가 버벅임, 2. 사용자의 사용성이 굉장히 불편,)
            ==> 한 페이지당 건수를 정해놓고 해당 건수만큼만 조회해서 화면에 보여준다
            
WHERE 절에서 사용할 수 있는 형태
SELECT ROWNUM, empno,ename
FROM emp
WHERE ROWNUM = 1;

SELECT ROWNUM, empno,ename
FROM emp
WHERE ROWNUM <= 10;

WHERE 절에서 사용할 수 없는 형태

SELECT ROWNUM, empno,ename
FROM emp
WHERE ROWNUM >= 10;

 ROWNUM과 ORDER BY
 SELECT SQL의 실행순서 : FROM WHERE SELECT ORDER BY
 
SELECT ROWNUM, empno,ename
FROM emp
ORDER BY ename; ---SQL 실행순서에 의해 정렬 안됨
ROWNUM의 결과를 정렬 이후에 반영하고 싶은 경우  ==> IN-LINE VIEW

VIEW ; SQL - DBMS에 저장되어 있는 SQL
IN-LINE : 직접 기술 했다, 어딘가 저장을 한게 아니라 그 자리에 직접 기술

SELECT ROWNUM empno, ename
FROM (SELECT empno, ename
FROM emp
ORDER BY ename); --괄호로 묶으면 SELECT절로 쓸수 있다



SELECT 절에 *만 단독으로  사용하지 않고 콤마를 통해 
        다른 임의 컬럼이나 EXPRESION을 표기한 경우 *앞에 어떤 테이블(뷰)에서 온것인지 
        한정자(테이블 이름,view 이름)를 붙여 줘야 한다
        
table , view 별칭 : table, view에도 SELECT절의 컬럼처럼 별칭을 부여할 수 있다
단 SELECT 절처럼 AS키워드는 사용하지 않는다 
EX) 
FROM e
FROM (SELECT empno, ename
FROM emp
ORDER BY ename) v_emp
        
SELECT emp.*
FROM emp;

SELECT ROWNUM,* ----오류 발생 
FROM (SELECT empno, ename
FROM emp
ORDER BY ename)
        
SELECT ROWNUM, a.* 
FROM (SELECT empno, ename
FROM emp
ORDER BY ename) a; --괄호로 묶으면 SELECT절로 쓸수 있다 ---a라는 이름으로 지

요구사항  : 1페이지당 10건의 사원 리스트가 보여야한다
페이지 번호, 페이지당 사이즈
1 page  : 1~10
2 page  : 11~20
3 page  : 21~30
.
.
.
n page  :(n-1)*10(pagesize)+1 ~ n*10(pagesize)

페이지 처리 쿼리 1 page : 1~10
SELECT ROWNUM, a.* 
FROM (SELECT empno, ename
FROM emp
ORDER BY ename) a
WHERE ROWNUM BETWEEN 1 AND 10;

페이지 처리 쿼리 2 page : 11~20
SELECT ROWNUM, a.* 
FROM (SELECT empno, ename
FROM emp
ORDER BY ename) a
WHERE ROWNUM BETWEEN 11 AND 20; ------사용할 수 없는 형태 (1번부터 순차적으로만 가능)

ROWNUM의 특성으로 1번부터 읽지 않는 형태이기 때문에 정상적으로 동작하지 않는다
ROWNUM의 값을 별칭을 통해 새로운 컬럼으로 만들고 해당 SELECT SQL을 in-line view로 만들어
외부에서 ROWNUM에 부여한 별칭을 통해 페이징 처리를 한다

페이지 처리 쿼리 2 page : 11~20
SELECT *
FROM (SELECT ROWNUM rn, a.* 
    FROM (SELECT empno, ename
         FROM emp
         ORDER BY ename) a)
WHERE rn BETWEEN 11 AND 20; --select의 결과를 in-line view로 묶어준다

SQL 바인딩 변수 : java 변수
페이지 번호 : page
페이지 사이즈 : pageSize
SQL  바인딩 변수 표기 : 변수명 ==> : page, : pageSize

바인딩 변수 적용 n page  :(page-1) * :pageSize +1 ~ :page * :pagesize
SELECT *
FROM (SELECT ROWNUM rn, a.* 
    FROM (SELECT empno, ename
         FROM emp
         ORDER BY ename) a)
WHERE rn BETWEEN (:page-1) * :pageSize +1 AND :page * :pageSize;



FUNCTION : 입력을 받아들여 특정 로직을 수행 후 결과 값을 반환하는 객체
오라클에서의 함수 구분 : 입력되는 행의 수에 따라
1.Single row FUNCTION
하나의 행이 입력 되서 결과로 하나의 행이 나온다
2. Multi low FUNCTION
여러개의 행이 입력 되서 결과로 하나의 행이 나온다

dual테이블 : oracle의 sys계정에 존재하는 하나의 행, 
            하나의 컬럼(dummy)을 갖는 테이블
            누구나 사용할 수 있도록 권한이 개방됨
            
dual테이블 용도
1. 함수 실행(테스트)
2. 시퀀스 실행
3. merge 구문
4. 데이터 복제 *****!!

*LENGTH 함수 테스트('TEST')
SELECT LENGTH('TEST')
FROM dual;  ----행단위로 입력된다

SELECT LENGTH('TEST'), emp.*
FROM emp;  ----행단위로 입력된다

문자열 관련 함수
SELECT CONCAT('HELLO', CONCAT(', ', 'WORLD')) concat, ---문자열 나타내기
        SUBSTR('HELLO, WORLD', 1, 5) substr, ---h를 첫번째로 시작하여 5번째 글자까지
        LENGTH('HELLO, WORLD') length, ---문자열 길이
        INSTR('HELLO, WORLD', 'O') instr, --O가 몇개 들어가 있는지
        INSTR('HELLO, WORLD', 'O', INSTR('HELLO, WORLD', 'O') +1) instr,
        LPAD('HELLO, WORLD', 15, ' ') lpad,   -----문자열을 추가하겠다는 위미
        RPAD('HELLO, WORLD', 15, ' ') rpad,
        REPLACE('HELLO, WORLD', 'O', 'P') replace, ----O를 P로 바꾸기
        TRIM(' HELLO, WORL D') trim,     ----앞 뒤에 있는 공백만 제거
        TRIM('D' FROM ' HELLO, WORLD') trim, ---특정문자를 제거
        UPPER('HELLO, WORLD') upper,
        INITCAP('hello, world') initcap
FROM dual;

함수는 WHERE절에서도 사용 가능

직원 이름이 smith인 사람
SELECT *
FROM emp
WHERE ename = UPPER('smith'); ---상수에 함수를 적용 해야 한다

SELECT *
FROM emp
WHERE LOWER(ename) = 'smith'; ----실행하기 위해서 모든 건수(14개)를 실행해야하므로 컬럼에 함수를 적용 하는것은 X

위 두개의 쿼리중에서 하지 말아야 할 형태
좌변을 가공하는 형태 (좌변 - 테이블 컬럼을 의미)

오라클 숫자 관려 함수
ROUND (숫자, 반올림 기준 자리) : 반올림 함수
TRUNC (숫자, 내림 기준 자리) : 내림함수
MOD (피제수, 제수) : 나머지 값을 구하는 함수

SELECT ROUND(105.54, 1) round, ----반올림 결과과 소수점 첫번째 까지 표현(소수점 2번째에서 반올림)
        ROUND(105.55, 1) round2,
        ROUND(105.55, 0) round3,
        ROUND(105.55) round3,
        ROUND(105.55, -1) round4 ---단 두번쨰자가 음수이면 반올림결과가 해당 자리에서 반올림
FROM dual;

SELECT TRUNC(105.54, 1) trunc, ----반올림 결과과 소수점 첫번째 까지 표현(소수점 2번째에서 반올림)
        TRUNC(105.55, 1) trunc2,
        TRUNC(105.55, 0) trunc3,
        TRUNC(105.55) trunc3,
        TRUNC(105.55, -1) trunc4 ---단 두번쨰자가 음수이면 반올림결과가 해당 자리에서 반올림
FROM dual;

sal을 100으로 나눈 나머지 ==> mod함수, 별도의 연산자는 없다
SELECT ename, sal, TRUNC(sal/1000, 0) quotien , MOD(sal, 1000) reminder ----quotient : 몫 reminder : 나머지
                    --몫 구하기 : 소수점 내림 ==> TRUNC(sal/1000)도 가능
FROM emp;

날짜 관련 함수
SYSDATE :
    오라클에서 제공해주는 특수함수
    1. 인자가 없다
    2. 오라클이 설치된 서버의 현재 년,월,일,시,분,초 정보를 반환 해주는 함수

SELECT SYSDATE
FROM dual; ----함수로 현재 시간 ,날짜를 알 수 있다

SELECT *
FROM nls_session_parameters;

날짜 타입 +- 정수 : 정수를 일자 취급, 정수만큼 미래 혹은 과거 날짜의 데이트 값을 반환
EX) 오늘 날짜에서 하루 더한 미래 날짜 값은??

SELECT SYSDATE +1
FROM dual;


데이트 + 정수(하루)
하루 == 24시간 ==> 1분 : 1/24/60
1시간 ==>1/24  3시간 ==> 3/24

EX) 현재 날짜에서 3시간 뒤 데이트를 구하면??
SELECT SYSDATE + 3/24
FROM dual;

EX) 현재 날짜에서 30분 뒤 데이트를 구하면??
SELECT SYSDATE + 30/24/60
FROM dual;

날짜(데이트) 표현하는 방법
1. 데이트 리터럴 : nls_session_parameters 설정에 따르기 때문에
                DAMS 환경 마다 다르게 인식 될 수 있음
2. TO_DATE : 문자열을 날짜로 변경해주는 함수

SELECT TO_DATE('20191231','YYYYMMDD') LASTDAY,  TO_DATE('20191231','YYYYMMDD') - 5 LASTDAY_BEFORE5, SYSDATE NOW ,SYSDATE - 3 NOW_BEFORE3
FROM dual;

문자열 ==> 데이트
 TO_DATE(날짜 문자열, 날짜 문자열의 패턴);

데이트 ==> 문자열 (보여주고 싶은 형식을 지정할 떄)
 TO_CHAR(데이트 값, 표현하고 싶은 문자열의 패턴);

SYSDATE 현재 날짜를 YYYY-DD-MM 포맷
SELECT SYSDATE, TO_CHAR(SYSDATE, 'YYYY-MM-DD'),
    TO_CHAR(SYSDATE, 'D'),  TO_CHAR(SYSDATE, 'IW')
FROM dual;

DATE 포맷(FORMAT) --PT참고
YYYY MM DD HH24 MI SS
D 주간 일자를 표현 (일요일이 1 월요일 2 .... 토요일 7)
IW : 주차를 표현 wx) 1주차, 2주차 등 --(1년은52~53주가 있다)


SELECT ename, hiredate, TO_CHAR(hiredate, 'YYYY/MM/DD HH24:MI:SS') h1,
        TO_CHAR(hiredate + 1, 'YYYY/MM/DD HH24:MI:SS') h2,
        TO_CHAR(hiredate + 1/24, 'YYYY/MM/DD HH24:MI:SS') h3
FROM emp;

Q)
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') DT_DASH, 
        TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24-MI-SS') DT_DASH_WITH_TIME,
        TO_CHAR(SYSDATE, 'DD-MM-YYYY') DT_DD_MM_YY
FROM dual;

