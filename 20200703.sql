Q 실습 1)테이블의 구조 파악

SELECT LPROD.LPROD_GU, lprod_nm, prod_id,prod_name
FROM prod,lprod
WHERE prod.prod_lgu = LPROD.LPROD_GU; --exerd에서 관계선을 클릭하면 두 테이블사이의 조인할 컬럼을 명시한다

응용
ansi-SQL 두 테이블의 연결 컬럼명이 다르기 때문에 NATURAL JOIN, JOIN WITH USING은 사용이 불가
SELECT LPROD.LPROD_GU, lprod_nm, prod_id,prod_name
FROM prod JOIN lprod ON(prod.prod_lgu = LPROD.LPROD_GU); 

SELECT *
FROM prod;

SELECT *
FROM lprod;

SELECT *
FROM cart;

Q 실습 2)

SELECT buyer_id, buyer_name,prod_id, prod_name
FROM buyer,prod --buyer,prod 순서는 상관없다
WHERE buyer.buyer_id = prod.prod_buyer;

Q 실습 3)
ORACLE
SELECT mem_id, mem_name, prod_id, prod_name, cart_qty
FROM member,cart,prod
WHERE member.mem_id = cart.cart_member AND cart.cart_prod = prod.prod_id;


SELECT a.*,prod_id, prod_name
FROM
    (SELECT mem_id, mem_name,cart_prod, cart_qty
    FROM member,cart
    WHERE member.mem_id = cart.cart_member ) a, prod
WHERE a.cart_prod = prod.prod_id;

ANSI-SQL
SELECT mem_id, mem_name, prod_id, prod_name, cart_qty
FROM member JOIN cart ON (member.mem_id = cart.cart_member) 
            JOIN prod ON (cart.cart_prod = prod.prod_id);


SELECT *
FROM customer;     --고객  

SELECT *
FROM cycle; --고객 제품 애음 주기 -- day (요일) 1: 일요일 2: 월요일....7 : 토요일

SELECT *
FROM product; --제품

SELECT *
FROM batch; 

SELECT *
FROM daily;  -- 일 실적 dt(일자)

실습 4)
SELECT customer.cid, cnm, pid, day, cnt
FROM customer,cycle
WHERE customer.cid = cycle.cid 
    AND cnm in('brown','sally');

실습 5)
SELECT customer.cid, cnm, cycle.pid, day, cnt
FROM customer,cycle,product
WHERE customer.cid = cycle.cid 
    AND cycle.pid  = product.pid
    AND customer.cnm in('brown','sally');
    
실습 6)
1. 테이블 조인
SELECT customer.cid, customer.cnm, cycle.pid, product.pnm,cycle.cnt cnt
FROM customer,cycle,product
WHERE customer.cid = cycle.cid 
    AND cycle.pid  = product.pid 

2. 개수의 합구하기
SELECT customer.cid, customer.cnm, cycle.pid, product.pnm,sum(cycle.cnt) cnt
FROM customer,cycle,product
WHERE customer.cid = cycle.cid 
    AND cycle.pid  = product.pid 
    
3. 그룹핑할 기준을 잡기 고객별 /애음 제품별 
SELECT customer.cid, customer.cnm, cycle.pid, product.pnm,sum(cycle.cnt) cnt
FROM customer,cycle,product
WHERE customer.cid = cycle.cid 
    AND cycle.pid  = product.pid 
GROUP BY customer.cid, customer.cnm, cycle.pid, product.pnm
ORDER BY customer.cid;

(SELECT cid,pid,SUM(cnt)
FROM cycle
GROUP BY cid,pid) cycle, cistomer,product;

    
실습 7)
SELECT cycle.pid,product. pnm,sum(cycle.cnt) cnt
FROM cycle,product
WHERE cycle.pid  = product.pid
GROUP BY cycle.pid, product.pnm
ORDER BY cycle.pid;  

HR계정 조회
SELECT *
FROM DBA_USERS;
과제 08~13

조인 성공 여부로 데이터 조회를 결정하는 구분방법
INNER JOIN : 조인에 성공하는 데이터만 조회하는 조인 방법
OUTER JOIN : 조인에 실패하더라도, 개발자가 지정한 기준이 되는 테이블의
                데이터는 나오도록 하는 조인
OUTER <==> INNER JOIN

<OUTER JOIN>
1.LEFT OUTER JOIN
2. RIGHT OUTER JOIN
3. FULL OUTER JOIN(LEFT+RIGHT)

복습 -사원의 관리자 이름을 알고 싶은 상황
조회컬럼 : 사원의 사번, 사원의 이름, 사원의 관리자의 사번, 사원의 관리자의 이름

동일한 테이블끼리 조인이  되었기 떄문에 : self-join
조인 조건을 만족하는 데이터만 조회 되었기 때문에 : INNER JOIN
SELECT e. empno,e. ename,e. mgr,m.ename
FROM emp e,emp m
WHERE e.mgr = m.empno;

KING의 경우 PRESIDENT이기 때문에 mgr 컬럼의 값이 NULL ==> 조인에 실패
==> KING의 데이터는 조회되지 않음(총14건 데이터 중 13건의 데이터만 조인성공)

OUTTER 조인을 이용하여 조인 테이블중 기준이 되는 테이블을 선택하면
조인에 실패하더라도 기준 테이블의 데이터는 조회 되도록 할 수 있다

LEFT OUTER JOIN/ RIGHT OUTER JOIN
ANSI-SQL
테이블1 JOIN 테이블2 ON
테이블1 LEFT OUTER JOIN 테이블2 ON
위 쿼리는 아래와 동일
테이블2 RIGHT OUTER JOIN 테이블1 ON


SELECT e. empno,e. ename, m.empno ,m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno); --OUTER JOIN 조인에 실패해도 나온다