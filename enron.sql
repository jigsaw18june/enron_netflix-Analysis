Find word frequency in year and month

INSERT OVERWRITE LOCAL DIRECTORY '/home/hduser/proj2/frequencyName.csv' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
select split(ts,' ')[3] as year, split(ts,' ')[2] as month,
fromStr, splitStr, count(*) as counts from enron
LATERAL VIEW
explode(split(toStr,',')) tos AS splitStr
where context rlike 'litigation' or context rlike 'bankrupt' or context rlike 'fraud' AND ts is NOT NULL 
group by fromStr,splitStr, split(ts,' ')[3], split(ts,' ')[2]
order by year,month;


mail frequency comparison enron vs non-enron

INSERT OVERWRITE LOCAL DIRECTORY '/home/hduser/proj2/mailfrequencyEnron.csv' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
select split(ts,' ')[3] as year, split(ts,' ')[2] as month, count(*) as counts from enron where 
(fromStr LIKE '%enron%' OR toStr LIKE '%enron%') and ts is not null
group by split(ts,' ')[3], split(ts,' ')[2]
order by year;

INSERT OVERWRITE LOCAL DIRECTORY '/home/hduser/proj2/mailfrequencyNonEnron.csv' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
select split(ts,' ')[3] as year, split(ts,' ')[2] as month, count(*) as counts from enron where not
(fromStr LIKE '%enron%' OR toStr LIKE '%enron%') and ts is not null
group by split(ts,' ')[3], split(ts,' ')[2]
order by year;


sentiment analysis avg and std deviation 

INSERT OVERWRITE TABLE temp
select eid, split(ts,' ')[3] as year, split(ts,' ')[2] as month, contxt from enron
lateral view
explode(split(context,' ')) tos as contxt
where regexp_replace(fromStr,".*@","") = "enron.com"
order by eid;

INSERT OVERWRITE LOCAL DIRECTORY '/home/hduser/proj2/random2.csv' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
select e.year, e.month, avg(s.value), stddev_pop(s.value)
from temp e join sent_list s on s.sentiment = e.word
group by e.eid,e.year, e.month;

===================================================================

Initialization

CREATE TABLE IF NOT EXISTS Enron 
        (eid STRING, 
        ts STRING,
        fromStr STRING, 
        toStr STRING, 
        ccStr STRING, 
        subject STRING, 
        context STRING) 
     COMMENT 'enron-dataset'
     ROW FORMAT DELIMITED  
     FIELDS TERMINATED BY '\t' 
     STORED AS TEXTFILE;

hadoop fs -put /home/anil/Desktop/proj2/enron.tab /proj2/input/.


LOAD DATA INPATH '/proj2/input/enron.tab' OVERWRITE INTO TABLE Enron;


create table sent_list
(sentiment String, value Int)
COMMENT 'sentiment-list of 60 words'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

hadoop fs -put /home/anil/Desktop/proj2/wordlist proj2/input/.

LOAD DATA INPATH 'proj2/input/wordlist.txt' OVERWRITE INTO TABLE sent_list;

create table temp(eid String,year string, month string, word string)
COMMENT 'temp-dataset'
ROW FORMAT DELIMITED  
FIELDS TERMINATED BY '\t' 
STORED AS TEXTFILE;

======================================================
Extra

who emails whom the most

INSERT OVERWRITE LOCAL DIRECTORY '/home/hduser/proj2/whotoWhomMostinYear.csv' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
SELECT
split(ts,' ')[3] as year, fromStr,
splitStr AS toStr,
count(1) AS count
FROM enron
LATERAL VIEW
explode(split(toStr,',')) tos AS splitStr
GROUP BY fromStr,splitStr,split(ts,' ')[3]
ORDER BY count DESC;


who sends most to receiver

INSERT OVERWRITE LOCAL DIRECTORY '/home/hduser/proj2/sendsMost.csv' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
select fromStr, count(1) as counts 
from enron
LATERAL VIEW
explode(split(toStr,',')) tos AS splitStr
GROUP BY fromStr
order by counts desc;
limit 100;

who receives most from any sender

INSERT OVERWRITE LOCAL DIRECTORY '/home/hduser/proj2/receiveMost.csv' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
select splitStr, count(1) as counts 
from enron
LATERAL VIEW
explode(split(toStr,',')) tos AS splitStr
GROUP BY splitStr
order by counts desc;
limit 100;

most used 5-word phrase

SELECT explode(ngrams(sentences(lower(context)), 5, 20)) AS x FROM enron;


adjacency list

INSERT OVERWRITE LOCAL DIRECTORY '/home/hduser/proj2/collectSet.csv' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
select fromStr, collect_set(splitStr), count(*)
from enron
LATERAL VIEW
explode(split(toStr,',')) tos AS splitStr
group by fromStr
