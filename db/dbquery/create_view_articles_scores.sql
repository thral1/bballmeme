DROP VIEW IF EXISTS deviagaz_bballmemeDev.articles_scores;
CREATE VIEW `deviagaz_bballmemeDev`.`articles_scores` AS

select title,publication_name,url
(unix_timestamp(publication_date)-1230768000) as age_in_secs,
num_backward_links,num_comments,num_visitors_per_month,

(num_visitors_per_month / 3500 * .1) as num_v_normalized,
(num_comments * 5 * .4) as num_c_normalized,
(num_backward_links * 200 * .4) as num_bl_normalized,

article_rank,
score

from articles;