복습
outer join <==> inner join 
inner join : 조인조건을 만족하는(조인에 성공하는)데이터만 조회
outer join : 조인 조건을 만족하지 않더라도(조인에 실패해도) 기준이 되는 테이블 쪽의 
            데이터 (컬럼)은 조회가 되도록 하는 조인 방식

outer join ; 
LEFT outer join : 조인 키워드의 왼쪽에 위치하는 테이블을 기준삼아 outer join 시행
RIGHT outer join : 조인 키워드의 왼쪽에 위치하는 테이블을 기준삼아 outer join 시행
FULL outer join :LEFT outer join + RIGHT outer join - 중복되는 것 제외

<ANSI-SQL>
FROM 테이블1 LEFT outer join 테이블2 ON(조인 조건)

<ORACLE-SQL> 데이터가 없는데 나와야하는 테이블의 컬럼
FROM 테이블1, 테이블2
WHERE 테이블1,컬럼 = 테이블2.컬럼(+) --ORACLE에서의 outer join

<ANSI-SQL>
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON(e.mgr = m. empno);

<ORACLE-SQL>
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e ,emp m 
WHERE e.mgr = m. empno(+);

OUTER JOIN 시 조인조건(ON절에 기술)과 일반 조건(WHERE절에 기술) 적용시 주의 사항
: OUTER JOIN을 사용하는데 WHERE 절에 별도의 다른 조건을 기술 할 경우 원하는 결과가 안나올 수 있다
==> OUTER JOIN의 결과과 무시

<ANSI-SQL>
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON(e.mgr = m. empno AND m.deptno =10);

조인 조건을 WHERE 절로 변경한 경우
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON(e.mgr = m. empno) 
WHERE m.deptno =10; 

위의 쿼리는 OUTER JOIN을 적용하지 않은 아래 쿼리와 동일한 결과를 나타낸다
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e JOIN emp m ON(e.mgr = m. empno) 
WHERE m.deptno =10; 

<ORACLE-SQL>
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e ,emp m 
WHERE e.mgr = m. empno(+)
    AND m.deptno(+) =10;

ORACLE에서 ANSI-SQL 조인 조건을 WHERE 절로 변경한 경우    
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e ,emp m 
WHERE e.mgr = m. empno(+)
    AND m.deptno=10;    
    
SELECT e.empno, e.ename, m.empno, m.ename --W질문하기
FROM emp e ,emp m 
WHERE e.mgr = m. empno
    AND m.deptno=10;   

RIGHT OUTER JOIN : 기준 테이블이 오른쪽
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON(e.mgr = m. empno);  --NULL값은 누군가의 매니저가 아니다

FROM emp e LEFT OUTER JOIN emp m ON(e.mgr = m. empno); :14건
FROM emp e RIGHT OUTER JOIN emp m ON(e.mgr = m. empno); : 21건

FULL OUTER JOIN : LEFT OUTER JOIN + RIGHT OUTER JOIN -중복제거
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e FULL OUTER JOIN emp m ON(e.mgr = m. empno); --22건

ORACLE에서는 FULL OUTER 문법을 제공하지 않는다

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e ,emp m 
WHERE e.mgr(+) = m. empno(+); --제공하지 않는다


FULL OUTER JOIN : LEFT OUTER JOIN + RIGHT OUTER JOIN -중복제거
A : {1,3,5}
B : {2,3,4}
A U B : {1,2,3,4,5} 집합에서 중복의 개념은 없다

A : {1,3}
B : {1,3}
C : {1,2,3}
A-B =공집합
A-C =공집합
C-A :{2}

FULL OUTER 검증
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON(e.mgr = m. empno)
UNION --합집합
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON(e.mgr = m. empno) 
MINUS --중복제거
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e FULL OUTER JOIN emp m ON(e.mgr = m. empno);

(LEFT OUTER JOIN + UNION + RIGHT OUTER JOIN )+  MINUS + FULL OUTER JOIN = FULL OUTER JOIN
--> 데이터가 조회 안된다 (==> 차집합이 없는것)

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m ON(e.mgr = m. empno)
UNION 
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON(e.mgr = m. empno) 
INTERSECT --교집합
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e FULL OUTER JOIN emp m ON(e.mgr = m. empno);

LEFT OUTER JOIN + UNION + RIGHT OUTER JOIN + INTERSECT  + FULL OUTER JOIN = FULL OUTER JOIN

과제 실습 OUTER JOIN 1~5

실습 OUTER JOIN 1
SELECT TO_CHAR(b.buy_date,'YY/MM/DD') buy_date,
        b.buy_prod, p.prod_id,p.prod_name,buy_qty
FROM  buyprod b ,prod p   
WHERE b.buy_prod(+) = p.prod_id
     AND buy_date(+)= '05/01/25' ;    

SELECT *
FROM buyprod;

SELECT *
FROM prod;


실습 OUTER JOIN 2
SELECT NVL(TO_CHAR(b.buy_date,'YY/MM/DD'),'05/01/25') buy_date,
        b.buy_prod, p.prod_id,p.prod_name,buy_qty
FROM  buyprod b ,prod p     
WHERE b.buy_prod(+) = p.prod_id
     AND buy_date(+) = '05/01/25' ; 

실습 OUTER JOIN 3
SELECT NVL(TO_CHAR(b.buy_date,'YY/MM/DD'),'05/01/25') buy_date,
        b.buy_prod, p.prod_id,p.prod_name,NVL(buy_qty,0)
FROM  buyprod b ,prod p     
WHERE b.buy_prod(+) = p.prod_id
     AND buy_date(+) = '05/01/25' ; 

실습 OUTER JOIN 4
SELECT p.pid,p.pnm,NVL(c.cid,1),NVL(c.day,0),NVL(c.cnt,0)
FROM  cycle c ,product p     
WHERE p.pid = c.pid(+)
    AND cid(+) =1;
     

실습 OUTER JOIN 5
    
SELECT p.pid,p.pnm,
        NVL(c.cid,1)cid, NVL(cu.cnm,'brown')cnm,NVL(c.day,0)day,NVL(c.cnt,0)cnt
FROM  cycle c ,product p ,customer cu
WHERE p.pid = c.pid(+) --없는 테이블에 (+)를 붙인다
    AND c.cid = cu.cid(+)
    AND c.cid(+) = 1 ;    
    

<지금까지 배운 내용 정리>
WHERE :행을 제한
JOIN : 
GROUP FUNCTION

<간단한 문제풀이>
시도 ; 서울특별시, 충청남도..
시군구 : 강남구, 청주시....
스토어 구분(버거킹,KFC, 맥도날드, 롯데리아)



