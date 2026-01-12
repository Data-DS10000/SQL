with skill_demand AS(
    SELECT
        skills_dim.skill_id,
        skills_dim.skills,
        count(*) as demand_count
    FROM 
        job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    where 
        job_title_short ILIKE 'data analyst'
        AND salary_year_avg IS NOT NULL 
        AND job_work_from_home = TRUE
    GROUP BY
        skills_dim.skill_id

),average_salary as (
    SELECT
        skills_job_dim.skill_id,
        ROUND (avg(job_postings_fact.salary_year_avg),2) as AVG_salary
    FROM
         job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE 
        job_title_short ILIKE 'data analyst' 
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = TRUE
    GROUP BY
        skills_job_dim.skill_id
)

SELECT
    skill_demand.skill_id,
    skill_demand.skills,
    demand_count,
    AVG_salary
from
    skill_demand
INNER JOIN average_salary on skill_demand.skill_id = average_salary.skill_id
WHERE
    demand_count>10
ORDER BY
    AVG_salary DESC,
    demand_count DESC
LIMIT 50


-- rewriting this same query more concisely
SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(*) AS demand_count,
    ROUND(avg(job_postings_fact.salary_year_avg),2) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short ILIKE 'data analyst' AND
    salary_year_avg IS NOT NULL AND
    job_work_from_home = TRUE
GROUP BY
    skills_dim.skill_id
HAVING
    count(*)>10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 50