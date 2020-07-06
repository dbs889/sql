SELECT *
FROM DBA_USERS;

ALTER USER hr IDENTIFIED BY java;
ALTER USER hr ACCOUNT UNLOCK;

과제8
SELECT r.region_id,r.region_name,c.country_name
FROM countries c,regions r
WHERE c.region_id  = r.region_id
        AND r.region_name ='Europe';
        
과제9
SELECT r.region_id,r.region_name,c.country_name,city
FROM countries c,regions r,locations l
WHERE c.region_id  = r.region_id
        AND c.country_id = l.country_id
        AND r.region_name ='Europe';
        
과제10
SELECT r.region_id,r.region_name,c.country_name,city,department_name
FROM countries c,regions r,locations l,departments d
WHERE c.region_id  = r.region_id
        AND c.country_id = l.country_id
        AND l.location_id = d.location_id
        AND r.region_name ='Europe';
        
과제11
SELECT r.region_id,r.region_name,c.country_name,city,department_name,CONCAT(e.first_name,last_name) name
FROM countries c,regions r,locations l,departments d,employees e
WHERE c.region_id  = r.region_id
        AND c.country_id = l.country_id
        AND l.location_id = d.location_id
        AND d.department_id = e.department_id
        AND r.region_name ='Europe';
        
과제12
SELECT e.employee_id,CONCAT(e.first_name,last_name) name,j.job_id,j.job_title
FROM employees e, jobs j
WHERE e.job_id  = j.job_id;

과제13
SELECT m.employee_id mgr_id, CONCAT(m.first_name,m.last_name) mgr_name,
     e.employee_id,CONCAT(e.first_name,e.last_name) name,j.job_id,j.job_title
FROM employees e,employees m,jobs j
WHERE e.job_id = j.job_id
    AND e.manager_id = m.employee_id;
