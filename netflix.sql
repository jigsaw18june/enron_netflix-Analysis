Sum of views for each year broken down by  movie title

SELECT COUNT(1) as ViewCount, MTitle.title, MTitle.yearofrelease FROM movie_titles MTitle 
JOIN movie_ratings MRatings ON (MTitle.mid = MRatings.mid) AND (MRatings.rating BETWEEN 4 AND 5) AND 
(MTitle.yearofrelease BETWEEN "1950" AND "2000") 
GROUP BY MTitle.title, MTitle.yearofrelease 
ORDER BY ViewCount DESC limit 10;

top 100 movies which have good average rating.

SELECT MTitle.title, MTitle.mid, b.avg_rating FROM movie_titles MTitle join
(SELECT mid,avg(rating) as avg_rating FROM movie_ratings 
GROUP BY mid order by avg_rating desc limit 100)b on MTitle.mid = b.mid 
limit 100;

All the movies that were released in between 1950 and 2000 and have got rating in range of 1 and 2.

SELECT COUNT(1) as ViewCount, MTitle.title, MTitle.yearofrelease from movie_titles MTitle JOIN 
movie_ratings mr ON (MTitle.mid = mr.mid) AND (mr.rating BETWEEN 1 AND 2) AND (MTitle.yearofrelease BETWEEN "1950" AND "2000") 
GROUP BY MTitle.title, MTitle.yearofrelease 
ORDER BY ViewCount DESC 
limit 100;

Most viewed movies:

SELECT a.mid,b.title,a.c_custid FROM (SELECT mid,count(customer_id) as c_custid FROM movie_ratings 
GROUP BY mid order by c_custid DESC limit 10) a JOIN movie_titles b on b.mid=a.mid;

Top 10 movies in year 2000:

select count(1) as ViewCount, MTitle.title,MTitle.yearofrelease from movie_titles MTitle 
JOIN movie_ratings MRatings ON MTitle.mid = MRatings.mid AND MRatings.rating = 5 AND 
MTitle.yearofrelease = 2000 
GROUP BY MTitle.title,MTitle.yearofrelease 
ORDER BY ViewCount DESC 
limit 10;
			
Top 100 movies worst rated

select MTitle.title,MTitle.mid,b.avg_rating from movie_titles MTitle join 
(select mid,avg(rating) as avg_rating from movie_ratings 
group by mid order by avg_rating asc limit 100)b on MTitle.mid = b.mid limit 100;


Top 100 5 rated movies

select MTitle.title,n.c_custid from movie_titles MTitle join 
(select mid,a.c_custid from (select mid,count(customer_id) as c_custid from movie_ratings 
where rating='5' group by mid order by c_custid desc limit 100) a ) n where n.mid = MTitle.mid;

Worst 100 movies in 2000 decade

select count(1) as num1, MTitle.title,MTitle.yearofrelease from movie_titles MTitle 
JOIN movie_ratings MRatings ON (MTitle.mid = MRatings.mid) AND MRatings.rating = 1 
GROUP BY MTitle.title,MTitle.yearofrelease 
ORDER BY num1 DESC 
limit 100;

Similar movies(general query) Recommendation Query:

SELECT MRatings.mid,MRatings.customer_id FROM movie_ratings MRatings 
left outer join (SELECT distinct mid,customer_id,rating FROM movie_ratings limit 1)a on a.customer_id = MRatings.customer_id 
AND a.rating = MRatings.rating AND a.mid is null limit 5;
