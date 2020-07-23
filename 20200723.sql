계층쿼리 
     테이블(데이터셋_의 행과 행사이의 연관관계를 추적 하는 쿼리
        EX) emp테이블 해당 사원의 mgr컬럼을 통해 상급자 추적 사능 
        1. 상급자 직원을 다른 테이블로 관리하지 않음
        1-1. 상급자 구조가 계층이 변경이 되도 테이블의 구조는 변경 할 필요가 없다
        2. join 테이블 간 연결
            FROM emp,dept
            WHERE emp.deptno = dept.deptno
            계층 쿼리는: 행과 행 사이의 연결(자기 참조)
                prior : 현재 읽고 있는 행을 지칭
                x : 앞으로 읽을 행 
                
실습4)
SELECT *
FROM h_sum;

SELECT LPAD(' ',(level-1)*3)|| s_id s_id,value
FROM h_sum
START WITH ps_id IS null
CONNECT BY prior s_id = ps_id;

실습5)

SELECT LPAD(' ', (LEVEL-1)*3)||org_cd org_cd, no_emp
FROM no_emp
START WITH org_cd ='XX회사'
CONNECT BY prior org_cd = parent_org_cd;

SELECT *
FROM no_emp;

가지치기 <pruning branch>
*SELECT 쿼리의 실행 순서 : FROM -> WHERE -> SELECT -> ORDER BY
계층 쿼리의 SELECT 쿼리 실행 순서 : FROM => START WITH, CONNECT BY -> WHERE
계층쿼리에서 조회할 행의 조건을 기술 할 수 있는 부분이 두 곳 존재
1. CONNECT BY : 다음행으로 연결 할지 말지를 결정
2. WHERE :START WITH, CONNECT BY에 의해 조회된 행을 대상으로 적용



SELECT deptcd,p_deptcd,LPAD(' ',(LEVEL-1)*3) || deptnm deptnm
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = P_deptcd 


앞으로 DEPTCD가 P_DEPTCD로 부모코드를 읽고, 정보기획부가 아닌 데이터를 조회하여라 
SELECT deptcd,p_deptcd,LPAD(' ',(LEVEL-1)*3) || deptnm deptnm
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = P_deptcd AND deptnm != '정보기획부';

응용) WHERE절에 기술해보자
SELECT deptcd,p_deptcd,LPAD(' ',(LEVEL-1)*3) || deptnm deptnm
FROM dept_h
WHERE deptnm != '정보기획부'
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = P_deptcd;

계층쿼리에서 사용할 수 있는 특수 함수
CONNECT_BY_ROOT(col) : 최상위 행의 col 컬럼의 값
SYS_CONNECT_CY_PATH(col,구분자) : 계층의 순회 경로를 표현
CONNECT_BY_ISLEAF : 해당 행의 LEAF NODE(1)인지 아닌지(0)를 반환

----------최상위 행의 col값을 구해보자
SELECT deptcd,p_deptcd,LPAD(' ',(LEVEL-1)*3) || deptnm deptnm,
        CONNECT_BY_ROOT(deptnm),
        LTRIM(SYS_CONNECT_BY_PATH(deptnm,'-'),'-')
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = P_deptcd 
--------------------------------------------------------
SELECT deptcd,p_deptcd,LPAD(' ',(LEVEL-1)*3) || deptnm deptnm,
        CONNECT_BY_ROOT(deptnm),
        LTRIM(SYS_CONNECT_BY_PATH(deptnm,'-'),'-'),
        CONNECT_BY_ISLEAF
FROM dept_h
START WITH deptcd = 'dept0'
CONNECT BY PRIOR deptcd = P_deptcd ;


INSTR 문자열에 특정 문자열이 들어 있는지(해당 문자열의 인덱스를 반환)

SELECT *
FROM board_test
실습 6)

SELECT seq, LPAD(' ',(LEVEL-1)*3) || title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq;
---------------------------------------
실습7)
SELECT LPAD(' ',(LEVEL-1)*3) || title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER BY seq DESC;

SIBLINGS: 정렬할 때 계층구조를 유지시켜 준다
SELECT seq, LPAD(' ',(LEVEL-1)*3) || title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY seq DESC;

하향식, siblings의 차이가 궁금
---------------------------------------------------------------------------------------------------
1. 최상위는 최신 순으로 정렬 2.자식노드를 정렬할 값 (답글을 순차적으로)

3)

SELECT seq, seq-parent_seq,LPAD(' ',(LEVEL-1)*3) || title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER SIBLINGS BY seq-parent_seq,seq DESC;




SELECT *
FROM
(SELECT seq, gb,CONNECT_BY_ROOT(seq) s_gn,LPAD(' ',(LEVEL-1)*3) || title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq)
ORDER BY s_gn DESC,seq;

1)컬럼 만들기
ALTER TABLE board_test ADD (gB NUMBER);

2) 4번들 하위에 있는 모든 글들
UPDATE board_test SET gb = 4
WHERE seq IN (4,5,6,7,8,10,11);

2-2)
UPDATE board_test SET gb = 1
WHERE seq IN (1,9);

2-3)
UPDATE board_test SET gb = 2
WHERE seq IN (2,3);


ALTER TABLE board_test DROP (get);
DROP TABLE 
seq In parent_seq
ORDER BY 오름차순

4--> 10,11,5,8,6,7,
2--> 3
1--> 9

행과 행의 연산은 분석함수, WINDOW함수를 사용

도전 실습 부서별 급여 순위

1. 부서별 급여 구하기 
테이블에 있는 값 

SELECT ename,sal,deptno
FROM emp
ORDER BY deptno ,sal DESC;

컬럼을 추가 하기 

1. 내가 등수를 매길 대상 : emp 사원=> 14명
2. 부서별로 인원이 다르다

1. 부서원이 14명이다 
SELECT LEVEL
FROM dual
CONNECT BY LEVEL <= 14;

2.부서별로 등수를 만들기 
2-1.부서의 부서 수 구하기
SELECT COUNT(*)
FROM emp
GROUP BY deptno;


SELECT LEVEL
FROM dual
CONNECT BY LEVEL <= 14;

--------------------------------
SELECT ROWNUM rn,a.*
FROM
(SELECT b.deptno,a.*
FROM(SELECT b.deptno,COUNT(*)
FROM emp
GROUP BY deptno) b,
(SELECT LEVEL lv
FROM dual
CONNECT BY LEVEL <= (SELECT COUNT(*) FROM emp))a
WHERE a.lv <= b.cnt
ORDER BY b.deptno,a.lv) ;

위의 동작을 하는 윈도우 함수
윈도우 함수 미사용 : EMP 테이블 3번 조회
윈도우 함수 사용 : EMP 테이블 1번 조회

SELECT ename, sal, deptno,
    RANK() OVER (PARTITION BY deptno ORDER BY sal DESC)
FROM emp;

윈도우 함수 : 행간 연산이 가능해진다
==> 일반적으로 풀리지 않는 쿼리를 간단하게 만들 수 있다
**모든 DBMS가 동일한 윈도우 함수를 제공하지 않음

WINDOW SQL의 끝판왕

문법 : 윈도우 함수 OVER (PATITION BY 컬럼 ORDER BY 컬럼 WINDOWING)
PARTITION : 행들을 묶을 그룹(그룹함수의 GROUP BY)
ORDER BY : 묶어진 행들간 순서 (RANK 순위의 경우 순서를 설정하는 기준이 된다)
WINDOWING : 파티션 안에서 특정 행들에 대해서만 연산하고 싶을 때 범위를 지정


순위 관련 함수
1. RANK() : 동일 값일 때는 동일 순위 부여, 후순위 중복자만큼 건너 띄고 부여
            1등이 2명이면 후순위는 3등
2. DENSE_RANK(): 동일 값일 때는ㄴ 동일 순위 부여, 후순위는 이어서 부여
                1등이 2명이여도 후순위는 2등
3. ROW_NUMBER():중복되는 값이 없이 순위 부여 (rownum과 유사)
                동점을 무시한다

SELECT ename, sal, deptno,
    RANK() OVER (PARTITION BY deptno ORDER BY sal DESC)sal_rank,
    DENSE_RANK() OVER (PARTITION BY deptno ORDER BY sal DESC)sal_dense_rank,
    ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY sal DESC)sal_row_rank
FROM emp;

no_ana2 실습)
SELECT a.*,b.cnt
FROM
(SELECT empno,ename, deptno
FROM emp) a,
(SELECT deptno,count(*) cnt
FROM emp
group by deptno) b
WHERE a.deptno = b.deptno
order by a.deptno,a.ename;

집계 윈도우 함수 :SUM, MAX,MIN,AVG,COUNT

SELECT empno,ename, deptno,COUNT(*) OVER (PARTITION BY deptno) cnt
FROM emp;

no_ana2 실습)2
SELECT empno,ename,sal, deptno,ROUND(AVG(sal) OVER (PARTITION BY deptno),2)avg_sal
FROM emp;

실습3
SELECT empno,ename,sal, deptno,MAX(sal) OVER (PARTITION BY deptno) MAX_sal
FROM emp;

실습4
SELECT empno,ename,sal, deptno,MIN(sal) OVER (PARTITION BY deptno) MIN_sal
FROM emp;