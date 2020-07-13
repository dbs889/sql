SELECT *
FROM (
SELECT ROWNUM rn, a.*
FROM (SELECT *
FROM emp
ORDER BY hiredate) a)
WHERE rn BETWEEN 1*8 AND 2*7;


2. 제약 조건 생성 방법 : 테이블 생성시 컬럼 기술 이후 별도로 제약조건을 기술하는 방법

DROP TABLE dept_test;
dept_test 테이블의 deptno컬럼을 대상으로 PRIMARY KEY 제약 조건 생성
CREATE TABLE dept_test(
    DEPTNO  NUMBER(2),   
    DNAME   VARCHAR2(14),
    LOC     VARCHAR2(13),
    
    CONSTRAINT pk_dept_test PRIMARY KEY(DEPTNO)
);

dept_test 테이블의 deptno가 동일한 값을 갖는 INSERT 쿼리 2개를 생성하여 2개의 쿼리가 정상적으로 동작하는지 테스트

INSERT INTO dept_test VALUES (99,'ddit','daejeon'); 
INSERT INTO dept_test VALUES (99,'ddit2','대전'); -----제약조건 때문에 삽입이 안된다
                                                ------ unique constraint (UNE.PK_DEPT_TEST) violated

SELECT *
FROM  dept_test;


NOT NULL 제약 조건 : 컬럼 레벨에 기술, 테이블 기술 없음, 테이블 수정시 변경 가능

INSERT INTO dept_test VALUES (98,null,'대전'); ---null값 테스트

dname 컬럼에 NOT NULL 제약 추가
DROP TABLE dept_test;

CREATE TABLE dept_test(
    DEPTNO  NUMBER(2) CONSTRAINT pk_dept_test PRIMARY KEY ,   
    DNAME   VARCHAR2(14) NOT NULL,
    LOC     VARCHAR2(13) 
);

INSERT INTO dept_test VALUES (98,null,'대전');  -- cannot insert NULL into ("UNE"."DEPT_TEST"."DNAME")
                                                --NULL값이 들어가지 않음
                                                
<UNIQUE 제약조건> : 해당 컬럼의 값이 다른 행에 나오지 않도록(중복되지 않도록)
                 데이터 무결성을 지켜주는 조건
                (EX :사번, 학번 등)
      
수업시간에 UNIQUE 제약조건 명명 규칙 : uk_테이블명_해당컬럼명       

DROP TABLE dept_test;

CREATE TABLE dept_test(
    DEPTNO  NUMBER(2) ,   
    DNAME   VARCHAR2(14),
    LOC     VARCHAR2(13),
    
   /* dname,loc를 결합해서 중복되는 데이터가 없으면 됨
    
    다음 두개는 중복
    ddit, daejeon
    ddit, daejeon
    
    아래는 부서명은 동일하지만 loc정보가 다르기 때문에 dname,loc조합은 서로 다른 데이터로 본다
    ddit, daejeon
     ddit, 대전*/
    CONSTRAINT uk_dept_test_dname UNIQUE (dname,loc) ---하나만 해도 되지만 두개를 적용해보자
);
dname,loc컬럼 조합으로 중복된 데이터가 들어가는, 안들어가는 테스트
dname,loc 컬럼 조합의 값이 동일한 데이터인 경우 ==> UNIQUE 제약조건에 의해 에러

INSERT INTO dept_test VALUES (90,'ddit','대전'); 
INSERT INTO dept_test VALUES (90,'ddit','대전');  --unique constraint (UNE.UK_DEPT_TEST_DNAME) violated

SELECT *
FROM  dept_test;

dname,loc 컬럼 조합의 값이 하나의 컬럼만 동일한 데이터인 경우 ==> 성공
ROLLBACK;
INSERT INTO dept_test VALUES (90,'ddit','daejeon'); 
INSERT INTO dept_test VALUES (90,'ddit','대전');  

FOREIGN KEY : 참조키
한 테이블의  컬럼의 값의 참조하는 테이블의 컬럼 값 중에 존재하는 값만 입력되도록 제어하는 제약조건

즉 FOREIGN KEY 경우 두 개의 테이블간의 제약조건

*참조되는 테이블의 컬럼에는 (dept_test.deptno) 인덱스가 생성되어 있어야한다
자세한 내용은 INDEX  편에서 다시 확인

DROP TABLE dept_test;

CREATE TABLE dept_test(
    DEPTNO  NUMBER(2) ,   
    DNAME   VARCHAR2(14),
    LOC     VARCHAR2(13),
    CONSTRAINT pk_dept_test PRIMARY KEY (deptno)
);
테스트 데이터 준비
INSERT INTO dept_test VALUES (1,'ddit','daejeon');           

dept_test 테이블의 deptno 컬럼을 참조하는 emp_test 테이블 생성
DESC emp;
CREATE TABLE emp_test(
    empno  NUMBER(4) ,   
    ename   VARCHAR2(10),
    deptno   NUMBER(2) REFERENCES dept_test (deptno)
);

1. dept_test  테이블에는 부서번호가 1번인 부서가 존재
2. emp_test 테이블의 deptno 컬럼으로 dept_test.deprno 컬럼을 참조
 ==> emp_test 테이블의 deptno 컬럼으로 dept_test.deprno 컬럼에 존재하는 값만 입력하는 것이 가능

dept_test테이블에 존재하는 부서번호 emp_test테이블에 입력하는 경우
INSERT INTO emp_test VALUES (9999,'brown','1');   ---삽입 성공

dept_test테이블에 존재하지 않는 부서번호 emp_test테이블에 입력하는 경우
INSERT INTO emp_test VALUES (9998,'sally','2');  ---에러
---integrity constraint (UNE.SYS_C007111) violated - parent key not found
---parent key not found = forien key

FK 제약조건을 테이블 컬럼 기술이후에 별도로 기술하는 경우
CONSTRAINT 제약조건명 제약조건 타입 (대상컬럼) REFERENCES 참조테이블(참조테이블의 컬럼명)
명명 규칙 :FK_타겟테이블명_참조테이블명[IDX] ----임의의 명명규칙
                                    --[IDX] 인덱스로 속도 개선이 가능
DROP TABLE emp_test;

CREATE TABLE emp_test(
    empno  NUMBER(4) ,   
    ename   VARCHAR2(10),
    deptno   NUMBER(2) ,
    CONSTRAINT FK_emp_test_dept_test FOREIGN KEY(deptno) REFERENCES dept_test(deptno)
);

dept_test테이블에 존재하는 부서번호 emp_test테이블에 입력하는 경우
INSERT INTO emp_test VALUES (9999,'brown','1');   ---삽입 성공

dept_test테이블에 존재하지 않는 부서번호 emp_test테이블에 입력하는 경우
INSERT INTO emp_test VALUES (9998,'sally','2');  ---에러
---integrity constraint (UNE.FK_EMP_TEST_DEPT_TEST) violated - parent key not found

참조되고 있는 부모쪽 데이터를 삭제하는 경우
dept_test 테이블에 1번 부서가 존재하고
emp_test 테이블의 brown 사원이 1번 부서에 속한 상태에서 1번 부서를 삭제하는 경우

FK의 기본 설정에서는 참조하는 데이터가 없어 질 수 없기 떄문에 에러 발생
SELECT *
FROM emp_test;

DELETE dept_test
WHERE deptno =1; ------child record found : 자식 테이블이 있어 오류
                삭제할 때는 자식을 먼저 삭제하고 부모를 삭제해야 한다
FK 생성 시 옵션
0. DEFAULT 무결성이 위배 되는 경우 에러
1. ON DELETE CASCADE :부모 데이터를 삭제할 경우 참고있는 자식 데이터를 같이 삭제
(dept_test 테이블의 1번 부서를 삭제하면 1번 부서에 소속되 brown 사원도 삭제)  --- CASCATE : 종속
2.ON DELETE SET NULL :부모 데이터를 삭제할 경우 참고있는 자식 데이터의 컬럼을 NULL로 수정 

1. 테스트
DROP TABLE emp_test;

CREATE TABLE emp_test(
    empno  NUMBER(4) ,   
    ename   VARCHAR2(10),
    deptno   NUMBER(2),
    CONSTRAINT fk_emp_test_dept_test FOREIGN KEY(deptno)
                        REFERENCES dept_test(deptno) ON DELETE CASCADE
);

INSERT INTO emp_test VALUES (9999,'brown','1'); --삽입
부모 테이터 삭제
DELETE dept_test
WHERE deptno =1; -----삭제 성공

SELECT *
FROM emp_test; ----삭제가 되어진다

2. 테스트 SET NULL
DROP TABLE emp_test;

CREATE TABLE emp_test(
    empno  NUMBER(4) ,   
    ename   VARCHAR2(10),
    deptno   NUMBER(2),
    CONSTRAINT fk_emp_test_dept_test FOREIGN KEY(deptno)
                        REFERENCES dept_test(deptno) ON DELETE SET NULL
);
INSERT INTO dept_test VALUES (1,'ddit','daejeon'); ---위에 삭제 했으니 다시 만들어준다
INSERT INTO emp_test VALUES (9999,'brown','1'); 

부모 테이터 삭제
DELETE dept_test
WHERE deptno =1; -----삭제 성공

SELECT *
FROM emp_test; ----null로 업데이트가 되어진다

check 제약 조건 : 컬럼에 입력되는 값을 검증하는 제약 조건
ex) salary 컬럼(급여) 이 음수가 입력되는 것은 부자연 스러움
    성별 컬럼에 남,여가 아닌 값이 들어오는 데이터가 잘못된 것
    직원 구분이 정직원, 계약직 2개만 존재할 때 다른 값이 들어오면 논리적으로 어긎난다
    

DROP TABLE emp_test;

CREATE TABLE emp_test(
    empno  NUMBER(4) ,   
    ename  VARCHAR2(10),
    --sal NUMBER(7,2) CHECK(sal >0)
    sal NUMBER(7,2) CONSTRAINT sal_no_zero CHECK (sal>0) --제약 조건에 명명규칙을 사용
);

sal 값이 음수인 데이터 입력
INSERT INTO emp_test VALUES (9999,'brown',-500); --check제약조건에 의해 오류
--check constraint (UNE.SAL_NO_ZERO) violated


CTAS : 테이블 생성 + 제약조건 --- 개발할때 사용

테이블 생성과 관련하여 테이블의 내용을 수정 하는것
CREATE TABLE 테이블명 AS
SELECT....

백업
CREATE TABLE member_20200713 AS
SELECT *
FROM member;

CTAS 명령을 이용하여 emp 테이브르이 모든 데이터를 바탕으로 emp_test테이블 생성
DROP TABLE emp_test; ---삭제

CREATE TABLE emp_test AS
SELECT *
FROM emp; ---테이블 생성

SELECT *
FROM emp_test;  ----테이블 생성 조회

테이블 컬럼 구조만 복사하고 싶을 때 WHERE 절에 항상 FALSE가 되는 조건을 기술하여 생성 가능
CREATE TABLE emp_test2 AS
SELECT *
FROM emp
WHERE 1!= 1; ---테이블 틀만 빠르게 생성 할 때 

<테이블 변경>
컬름에 작업하는 과정
1. 존재하지 않았던 새로운 컬럼 추가 
    ** 테이블의 컬럼 기술순서를 제어하는 건 불가능
    ** 신규로 추가하는 컬럼의 경우 컬럼 순서가 항상 테이블의 마지막에 위치한다
    ** 설계를 할 때 컬럼 순서에 충분히 고려, 누락된 컬럼이 없는지도 고려
2. 존재하는 컬럼 삭제
    ** 제약조건(FK) 주의
3. 존재하는 컬럼 변경
    * 컬럼명 변경 ==> FK와 관계 없이 알아서 적용해줌
    * 그 외적인 부분에서는 사실상 불가능 하다고 생각하면 편함
        데이터가 이미 들어가 있는 테이블의 경우 아래 조건이 힘듦
        1. 컬럼 사이즈 변경
        2. 컬럼 타입 변경 ex) DATE->NUMBER로 변경 불가
        
        ==> 설계시 충분히 고려해야한다
        
<테이블과 관련된 제약조건 작업>
1. 제약조건 추가
2. 제약 조건 삭제
3. 제약조건 비활성화/활성화

테이블생성
DROP TABLE emp_test;

CREATE TABLE emp_test(
    empno  NUMBER(4) ,   
    ename   VARCHAR2(10),
    deptno   NUMBER(2) 
);

테이블 수정의 키워드 
ALTER TABLE 테이블명 .....

1. 신규 컬럼 추가

ALTER TABLE emp_test ADD (hp VARCHAR2(11)); ---테이블 추가

SELECT *
FROM emp_test; ---hp의 컬럼이 추가

DESC emp_test; 

2-1. 컬럼 수정 MODIFY

**데이터가 존재하지 않을 때에는 비교적 자유롭게 수정 가능
ALTER TABLE emp_test MODIFY (hp VARCHAR2(5)); ----데이터가 존재하지 않으므로 자유롭게 수정가능(타입변경도 가능)

2 컬럼의 기본 값 설정
ALTER TABLE emp_test MODIFY (hp DEFAULT 123);

INSERT INTO emp_test (empno,ename,deptno) 
                        VALUES (9999,'brown',null); --default 설정이 조회된다
                        
2-2 컬럼 명칭 변경(RENAME COLUMN 현재컬럼명 TO 변경할 컬럼명)
ALTER TABLE emp_test RENAME COLUMN hp TO cell;

2-3 컬럼 삭제 (DROP, DROP COLUMN)
ALTER TABLE emp_test DROP( cell);
ALTER TABLE emp_test DROP COLUMN cell;

DESC emp_test; ---컬럼이 사라진 것을 조회 할 수 있다

3. 제약조건 추가, 삭제(ADD,DROP)
        +
    테이블 레벨의 제약조건 생성
ALTER TABLE 테이블명 ADD CONSTRAINT 제약조건명  PRIMARY KEY  ()

별도의 제약 조건 없이 emp_test 테이블 생성
DROP TABLE emp_test;

CREATE TABLE emp_test(
    empno  NUMBER(4),   
    ename   VARCHAR2(10),
    deptno   NUMBER(2) 
);
3-1 테이블 수정을 통해서 emp_test 테이블의 empno 컬럼에 primary key 제약 조건 추가
ALTER TABLE emp_test ADD CONSTRAINT pk_emp_test PRIMARY KEY (empno);

3-2제약조건  삭제(drop)
ALTER TABLE emp_test DROP CONSTRAINT pk_emp_test; 

제약  조건 활성화 비활성화
제약조건 DROP은 제약조건 자체를 삭제하는 행위
제약조건 비활성화는 제약조선 자체는 남겨두지만, 사용하지는 않는 형태
때가 되면 다시 활성화 하여 데이터 무결성에 대한 부분을 강제할 수 있음

DROP TABLE emp_test;

CREATE TABLE emp_test(
    empno  NUMBER(4) ,   
    ename   VARCHAR2(10),
    deptno   NUMBER(2) 
);
테이블 수정명령을 통해 EMP_TEST 테이블의 empno 컬럼으로  PRIMARY KEY  제약 생성
ALTER TABLE emp_test ADD CONSTRAINT pk_emp_test PRIMARY KEY (empno);
---테이블의 수정 명령 ADD CONSTRAINT

SELECT *
FROM emp_test;

제약 조건을 비활성화 DISABLE
ALTER TABLE emp_test DISABLE CONSTRAINT pk_emp_test; 

pk_emp_test가 비활성화 되었기 때문에 empno 컬럼에 중복되는 값 입력이 가능
INSERT INTO emp_test VALUES (9999,'brown',NULL);
INSERT INTO emp_test VALUES (9999,'sally',NULL);

제약 조건을 활성화 ENABLE
ALTER TABLE emp_test ENABLE  CONSTRAINT pk_emp_test; ---에러가 난다
--cannot validate (UNE.PK_EMP_TEST) - primary key violated


<DICTIONARY>

SELECT *
FROM user_tables;

제약조건을 확인하는 테이블
SELECT *
FROM user_constraints; --활성화/비활성화 확인 :status

특정 제약 조건을 확인하는 테이블
SELECT *
FROM user_constraints 
WHERE constraint_type ='P';

특정 테이블 이름으로 조회
SELECT *
FROM user_constraints 
WHERE table name = 'EMP_TEST';

구성된 컬럼을 확인
SELECT *
FROM user_cons_columns; 

SELECT *
FROM user_cons_columns
WHERE table_name ='CYCLE'
        AND constraint_name = 'PK_CYCLE';

테이블에 대한 커멘트 조회     
SELECT *
FROM user_tab_comments;

컬럼에 대한 커멘트 조회     
SELECT *
FROM user_col_comments;

comment를 기재하는 방법
테이블 ,컬럼 주석 달기
COMMENTS ON TABLE명 IS '주석';
COMMENTS ON TABLE명.컬럼명 IS '주석';

emp_test 테이블에 comment를 기재해보기
COMMENT ON TABLE emp_test IS '사원_복제';
COMMENT ON COLUMN emp_test.empno IS '사번';
COMMENT ON COLUMN emp_test.ename IS '사원이름';
COMMENT ON COLUMN emp_test.deptno IS '소속부서번호';

SELECT *
FROM user_tab_comments;
SELECT *
FROM user_col_comments;



실습 1
SELECT t.*,c.column_name,c.comments col_comment
FROM user_tab_comments t ,user_col_comments  c
WHERE t.table_name = c.table_name
    AND t.table_name in('CYCLE','CUSTOMER','DAILY','PRODUCT');

실습2) 
EMP 테이블과 DEPT 테이블에 pk,fk 제약조건을 설정해라

ALTER TABLE dept ADD CONSTRAINT pk_dept PRIMARY KEY  (deptno)

ALTER TABLE emp ADD CONSTRAINT pk_emp PRIMARY KEY (deptno);