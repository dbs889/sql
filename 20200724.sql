select *
from dept;

CREATE TABLE TB_JDBC_BOARD(
    BOARD_NO NUMBER(4) CONSTRAINT pk_TB_JDBC_BOARD PRIMARY KEY  ,   
    TITLE   VARCHAR2(14),
    CONTENT   VARCHAR2(1000),
    USER_ID  VARCHAR2(9),
    RED_DATE   DATE  
);

-----------------------------------------------------------------------------------------
20200724
계층쿼리
1. connect by level <, <=정수
    : 시작행, 연결될 다음 행과의 조건이 없음
     ==> CROSS JOI0N과 유사하다
2. START WITH, CONNECT BY : 일반적인 계층 쿼리
                            시작 행을 지칭, 연결될 다음 행과의 조건을 기술

CREATE TABLE imsi(
    t varchar2(2)
);
insert into imsi values ('a');
insert into imsi values ('b');
commit;

LEVEL의 시작 : 1
SELECT *
FROM imsi --시작점이 없다는 것은 모든행의 조회된다
CONNECT BY LEVEL <= 2; --6건이 조회(2개,4개)

LEVEL의 시작 : 1
SELECT *
FROM imsi 
CONNECT BY LEVEL <= 3; 14건이 조회(2건,4건,8건)-->CROSS조인과 비슷


---계층의 순회 경로를 통해 알아보자
SELECT t, level,LTRIM(sys_connect_by_path(t,'-'),'-')
FROM imsi 
CONNECT BY LEVEL <= 3; 

SELECT DUMMY, level
FROM dual
CONNECT BY LEVEL <= 10; --계층쿼리는 행과 행의 연결이므로 가능한 모든 행을 연결한다

==>CONNECT BY LEVEL 은 가능한 모든행을 연결 하므로 dual에만 쓴다


lag lead :환율에서 많이 사용된다
LAG(COL): 파티션별 이전 행으이 특정 컬럼 값을 가져오는 함수
LEAD(COL) : 파티션별 이후 행의 특정 컬럼 값을 가져오는 함수

실습 5)
자신보다 전체 사원의 급여 순위가 자신보다 1단계 낮은사람의 급여값을 5번째 컬럼으로 생성
단 급여가 같으면 입사일자가 빠른 사람이 우선순위가 높다

추리 쿼리
SELECT empno, ename, hiredate,sal
FROM emp
ORDER BY sal DESC,hiredate;

window함수를 이용하여 구해보자
SELECT empno,ename,hiredate,sal,LEAD(sal) over (order by sal DESC, hiredate) lead_sal ,
                --내다음행의 값은lead//전체행을 대상으로 하면 partion by를 기술하지 않는다
                LAG(sal) over (order by sal DESC, hiredate) leg_sal 
FROM emp;

lead는 맨 마지막행의 값이 null // leg는 맨 처음 행의 값이 null
------------------------------------------------------------------------------------------------
분석함수 없이 풀어보아라 


1. 정렬이 된 상태에서 첫번째 행은 두번쨰 행과 연결 두번쨰는 셋번째랑 연결

select a.*, rownum rn ,b.lv
from 
(select rownum rn,b.lv
from 
(SELECT LEVEL lv FROM dual CONNECT BY LEVEL <=14) b,
(select rownum rn,a.* from (select empno,ename,hiredate,sal from emp order by sal DESC,hiredate)a )a
WHERE a.rn = b.lv )c
where b.lv +1 = a.rn;
------------------------------------------------------------------------------------선생님 답
select a.*,b.sal
from 
(select rownum rn,a.* from (select empno,ename,hiredate,sal from emp order by sal DESC,hiredate)a,
(select rownum rn,a.* from (select empno,ename,hiredate,sal from emp order by sal DESC,hiredate)b
where a.rn - 1 = b.rn(+)
       /* 1 = 
        2 = 1*/
order by a.sal DESC,a.hiredate;


실습 6
SELECT empno, ename, hiredate,job,sal, 
    LAG(sal) over (partition by job order by sal DESC, hiredate) lag_sal 
FROM emp;


SELECT empno, ename,sal,level
FROM emp
CONNECT BY LEVEL <= 
ORDER BY sal,empno;


unbounded : 범위가 없다

WINDOWING : 파티션 내의 행들을 세부적으로 선별하는 범위를 기술
UNBOUNDED PRECEDING : 현재 행을 기준으로 선행(이전) 하는 모든 행들 기술
CURRENT ROW : 현재 행
UNBOUNDED FOLLOWING : 현재행을 기준으로 이후 모든 행들

select empno, ename, sal
from emp
order by sal;

----누적합을 조회해보자-----------
window에는 기본 설정값이 존재 : RANGE UNBOUNDED PRECEDING
                            RANGE UNBOUNDED PRECEDING AND CURRENT ROW
select empno, ename, sal,
    SUM(sal) OVER (ORDER BY sal ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) c_sum,
    
    /*내 행을 기준으로 앞뒤로 하나씩 조회해본다*/
    SUM(sal) OVER (ORDER  BY sal ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) c_sum2
from emp;

select empno, ename, sal,
    SUM(sal) OVER (ORDER BY sal) c_sum
from emp; ----위의 쿼리와 결과가 비슷하다

실습 7
select empno, ename, deptno, sal,
    SUM(sal) OVER ( partition by deptno ORDER BY sal,empno ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) c_sum
from emp;


응용 실습 7 --RANGE :행이 다르더라도 행의 같은 값을 하나로 본다 (논리적인 값의 정의)
select empno, ename, deptno, sal,
    SUM(sal) OVER ( partition by deptno ORDER BY sal,empno RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) c_sum
from emp;




select empno,ename,deptno,sal,
        SUM(sal) Over (ORDER BY sal ROWS UNBOUNDED PRECEDING) rows_sum,
        SUM(sal) Over (ORDER BY sal RANGE UNBOUNDED PRECEDING) range_sum,
        SUM(sal) Over (ORDER BY sal) c_sum
FROM emp;

TO.. 윤혜....슥..호..에게....
안녕 ....지금 자리에 물통이 없는걸 보니 
물을 뜨러갔구나 정수기야...껄껄..
나는 이제 귀찮아서 어디도 갈 수 없어...
너를 기다리고있어 ....
어 서와..........
        BY 승민짱...
        
        
데이터 모델링

모델링 과정(요구사항 파악 이후)
[개념 모델] - (논리 모델 - 물리 모델 )순서로 진행이 된다
논리 모델 - 물리 모델 이 중요
 논리모델의 요약 판 
 
 논리 모델 : 시스템에서 필요로 하는 엔터키(테이블) , 에터키의 속성, 엔터티간의 관계를 기술
            데이터가 어떻게 저장될지는 관심사항이 아니다 ==> 물리 모델에서 고려할 사항
            논리 모델에서는 데이터의 전반적인 큰 틀을 설계
            
 물리 모델 : 논리 모델을 갖고 해당 시스템이 사용할 데이터 베이스를 고려하여 최적화된 
            테이블, 컬럼, 제약조건을 설계하는 단계

 논리 모델               :       물리 모델
 엔터키(entity) type              테이블
 속성(attribute)                  컬럼
 식별자                            키   ==> 행들을 구분할 수 있는 유일한 값
 관계(RELATION)                   제약조건
 관계차수 : 1-N , 1-1,N-N(==>1:N으로 변경대상)
            수직바, 까마귀발
 관계 옵션 : mandatory(vlftn),optional(옵션) o표기
 
요구사항(요구사항 기술서, 장표, 인터뷰)에서 명사를 본다 ==> 엔터티 or 속서일 확률이 높다

명명규칙
엔터티 : 단수명사, 
        서술식 표현은 잘못된 방벙(복수명사도 안됨)