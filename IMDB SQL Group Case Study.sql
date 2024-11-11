USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT table_name, table_rows -- Finding the total number of rows in each table of our DB imdb
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'imdb';

-- Q2. Which columns in the movie table have null values?
-- Type your code below:
SELECT count(*) FROM movie 
WHERE title IS NULL OR title = '';

SELECT count(*) FROM movie 
WHERE year IS NULL OR year = '';

SELECT count(*) FROM movie 
WHERE date_published IS NULL;

SELECT count(*) FROM movie 
WHERE duration IS NULL; 

SELECT count(*) FROM movie 
WHERE country IS NULL OR country=''; 

SELECT count(*) FROM movie 
WHERE worlwide_gross_income IS NULL OR worlwide_gross_income=''; 

SELECT count(*) FROM movie 
WHERE languages IS NULL OR languages=''; 

SELECT count(*) FROM movie 
WHERE production_company IS NULL OR production_company=''; 

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT year as Year,  
		count(distinct id) as number_of_movies
FROM movie 
group by year;

SELECT month(date_published) as month_num,
		count(distinct id) as number_of_movies
FROM movie
group by month(date_published)
order by month_num;  

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

with USA_Ind  
as            
(
SELECT *
FROM movie
WHERE country regexp 'USA' OR country regexp 'India'
)
SELECT count(distinct id) as count_of_movies_2019_for_USA_or_India
FROM USA_Ind
WHERE year=2019;


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT distinct genre  
FROM genre;


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT count(distinct id) as num_of_movies,  
		genre
FROM genre as g
left join movie as m   
ON g.movie_id=m.id
group by genre
order by num_of_movies desc 
limit 1;                     

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

with Movies_with_1_genre
as
(
SELECT id,
		title,
		count(genre) as num_of_genres 
FROM genre as g
inner join movie as m 
ON g.movie_id=m.id
group by id
having num_of_genres=1  
)
SELECT count(distinct id) as 'count of movies with 1 genre'
FROM Movies_with_1_genre;  

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH movies_with_1_genre AS (
    SELECT
        m.id,
        m.title,
        COUNT(g.genre) AS num_of_genres,
        g.genre,
        m.duration
    FROM genre AS g
    INNER JOIN movie AS m
        ON g.movie_id = m.id
    GROUP BY m.id, m.title, g.genre, m.duration
    HAVING COUNT(g.genre) = 1
)
SELECT
    genre,
    AVG(duration) AS avg_duration
FROM movies_with_1_genre
GROUP BY genre;


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT genre,
		count(distinct id) as movie_count, 
        RANK() OVER(order by count(distinct id) desc) as genre_rank 
FROM genre as g
left join movie as m    
ON g.movie_id=m.id
group by genre; 

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT min(avg_rating) as min_avg_rating,
		max(avg_rating) as max_avg_rating,
        min(total_votes) as min_total_votes,
        max(total_votes) as max_total_votes,
        min(median_rating) as min_median_rating,
        max(median_rating) as max_median_rating
FROM ratings;  

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

with ratings_ranked
as
(
SELECT title,
		avg_rating,
        RANK() OVER(window_rating) as movie_rank -- ranking movies by avg_rating
FROM ratings as r
INNER JOIN movie as m   -- joining ratings and movies tables
ON r.movie_id= m.id
WINDOW window_rating AS (order by avg_rating DESC) -- creating a window for ranking movies by avg_rating
)
SELECT * 
FROM ratings_ranked
WHERE movie_rank<=10;  -- SELECTING movies upto rank 10

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT median_rating,
		count(distinct id) as movie_count
FROM ratings as r 
inner join movie as m 
ON r.movie_id= m.id
group by median_rating  
order by movie_count DESC;  

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

with hit_movies_list   
as
(
SELECT production_company,   
		id,
        title,
        avg_rating
FROM movie as m   
INNER JOIN ratings as r    
ON m.id = r.movie_id
WHERE avg_rating>8    
)
SELECT production_company,
		count(distinct id) as movie_count,      
        RANK() OVER(order by count(distinct id) DESC) as prod_company_rank  
FROM hit_movies_list
group by production_company
order by movie_count DESC;               


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

with movies_usa
as
(                      
SELECT id,                         
		year,
        date_published,
        country,
        genre,
        total_votes
FROM movie as m
INNER JOIN genre as g                   
ON m.id= g.movie_id                      
	INNER JOIN ratings as r              
    ON m.id= r.movie_id
WHERE year= 2017 and month(date_published)=3 and country regexp 'USA' and total_votes>1000
)
SELECT genre,
		count(id) as movie_count         
FROM movies_usa
group by genre
order by movie_count desc;             

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:


SELECT title,
		avg_rating,
        genre
FROM movie as m
INNER JOIN genre as g                   
ON m.id= g.movie_id                     
	INNER JOIN ratings as r              
    ON m.id= r.movie_id
WHERE title regexp '^The' and avg_rating>8      
order by genre;            


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT count(distinct id) as movie_count     
FROM movie as m 
INNER JOIN ratings as r                  
ON m.id= r.movie_id
WHERE (date_published between '2018-04-01' and '2019-04-01') and median_rating=8  
order by date_published;                  
        
-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT sum(total_votes) as votes_count    
FROM movie as m 
INNER JOIN ratings as r                  
ON m.id= r.movie_id
WHERE country regexp 'Germany';       

SELECT sum(total_votes) as votes_count    
FROM movie as m 
INNER JOIN ratings as r                  
ON m.id= r.movie_id
WHERE country regexp 'Italy';            


/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


SELECT count(*) as name_nulls     
FROM names
WHERE name IS NULL;

SELECT count(*) as height_nulls    
FROM names
WHERE height IS NULL;

SELECT count(*) as date_of_birth_nulls    
FROM names
WHERE date_of_birth IS NULL;

SELECT count(*) as known_for_moviesh_nulls
FROM names
WHERE known_for_movies IS NULL;


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

with directors_of_top_3_genres            
as
(
SELECT n.name as director_name,
		d.name_id,
        d.movie_id,
		g.genre
FROM director_mapping as d
INNER JOIN names as n              
ON d.name_id= n.id
	INNER JOIN ratings as r         
	ON d.movie_id= r.movie_id
		INNER JOIN genre as g       
		ON d.movie_id= g.movie_id
where avg_rating>8 and (genre='Drama' or genre='Comedy' or genre='Thriller')  
order by name
)
SELECT director_name,
		count(distinct movie_id) as movie_count       
FROM directors_of_top_3_genres
group by director_name
order by movie_count DESC              
limit 3;                           





/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


with actors
as(                                     
SELECT n.name as actor_name,
		rm.name_id,
		rm.movie_id,
        r.median_rating
FROM role_mapping as rm
INNER JOIN names as n       
ON rm.name_id= n.id
	INNER JOIN ratings as r     
	ON rm.movie_id= r.movie_id
WHERE category= 'actor' and median_rating>=8 
)
SELECT actor_name,
		count(distinct movie_id) as movie_count     
FROM actors
group by actor_name
order by movie_count desc         
limit 2;                                



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

with prod_houses_ranked
as
(                                                  
SELECT m.production_company,
		sum(r.total_votes) as votes_count,           
        row_number() OVER(ORDER BY sum(r.total_votes) DESC) as prod_comp_rank 
FROM movie as m
INNER JOIN ratings as r                        
ON m.id= r.movie_id
group by production_company                    
order by votes_count DESC                       
)
SELECT * 
FROM prod_houses_ranked
WHERE prod_comp_rank<=3;                        

                                           
/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

CREATE VIEW actors AS             
SELECT rm.*, n.*
FROM role_mapping AS rm
INNER JOIN names AS n
ON rm.name_id = n.id
WHERE rm.category = 'actor';


CREATE VIEW movies_India AS           
SELECT *
FROM movie
WHERE country regexp 'India';

SELECT a.name as actor_name,
		sum(r.total_votes) as total_votes,             
        count(distinct a.movie_id) as movie_count,
        (sum(r.avg_rating* r.total_votes)/sum(r.total_votes)) as actor_avg_rating, 
        RANK() OVER(ORDER BY (sum(r.avg_rating* r.total_votes)/sum(r.total_votes)) DESC, r.total_votes DESC) as actor_rank   
FROM ACTORS as a
INNER JOIN movies_India as mi      
ON a.movie_id= mi.id
	INNER JOIN ratings as r          
    ON a.movie_id= r.movie_id
group by actor_name                  
having movie_count>=5
limit 1;               

DROP VIEW ACTORS;          
DROP VIEW movies_India;


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

CREATE VIEW ACTRESSES AS             
SELECT *
FROM role_mapping as rm
INNER JOIN names as n
ON rm.name_id= n.id
WHERE category='actress';

CREATE VIEW hindi_movies_India AS             
SELECT *
FROM movie
WHERE country regexp 'India' and languages regexp 'Hindi';  

SELECT 
    a.name AS actress_name,
    SUM(r.total_votes) AS total_votes,             
    COUNT(DISTINCT a.movie_id) AS movie_count,
    (SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes)) AS actress_avg_rating, 
    RANK() OVER(ORDER BY (SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes)) DESC, SUM(r.total_votes) DESC) AS actress_rank    
FROM 
    actresses AS a
INNER JOIN 
    hindi_movies_india AS mi        
    ON a.movie_id = mi.id
INNER JOIN 
    ratings AS r          
    ON a.movie_id = r.movie_id
GROUP BY 
    a.name
HAVING 
    COUNT(DISTINCT a.movie_id) >= 3
ORDER BY 
    actress_rank
LIMIT 3;
  -- Taapsee Pannu is the top actress





/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

with thriller_movies
as
(                                
SELECT m.title,
		m.id,
        g.genre,
        r.avg_rating
FROM genre as g
INNER JOIN ratings as r        
ON g.movie_id= r.movie_id      
	INNER JOIN movie as m
    ON g.movie_id=m.id
WHERE g.genre= 'Thriller'     
)
SELECT *,
        CASE                                           
			WHEN avg_rating>8 then 'Superhit movies'
            WHEN avg_rating between 7 and 8 then 'Hit movies'
            WHEN avg_rating between 5 and 7 then 'One-time-watch movies'
            WHEN avg_rating<5 then 'Flop movies'
		END as Movie_Category
FROM thriller_movies;



/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

with avg_duration_per_genre
as
(                              
SELECT genre,
		avg(duration) as avg_duration
FROM movie as m
INNER JOIN genre as g
ON m.id= g.movie_id
group by genre
)
SELECT *, 
		sum(round(avg_duration,2)) over w1 as running_total_duration,  
        avg(avg_duration) over w2 as moving_avg_duration    
FROM avg_duration_per_genre
WINDOW w1 as (ORDER BY genre ROWS UNBOUNDED PRECEDING),
w2 as (ORDER BY genre ROWS UNBOUNDED PRECEDING);   
        
        
        







-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies


-- We already know from our previous queries that Drama, Comedy or Thriller are the top 3 genres in terms of number of movies produced
-- So writing the query now

with movies_ranked_by_grossIncome  
as(
select genre,
        year,
        title as movie_name,
        worlwide_gross_income,
        dense_rank() over (partition by year order by worlwide_gross_income desc) as movie_rank  
        
from movie m inner join genre g on               
m.id= g.movie_id
where genre= 'Drama' or genre= 'Comedy' or genre='Thriller'  
)
SELECT * 
FROM movies_ranked_by_grossIncome         
WHERE movie_rank<=5;             


with movies_ranked_by_grossIncome  
as(
select genre,
        year,
        title as movie_name,
        worlwide_gross_income,
        dense_rank() over (partition by year order by worlwide_gross_income desc) as movie_rank 
        
from movie m inner join genre g on             
m.id= g.movie_id
where genre= 'Drama' or genre= 'Comedy' or genre='Thriller'  
)
SELECT * 
FROM movies_ranked_by_grossIncome          
WHERE movie_rank<=5;             
   
SELECT *
FROM movie
WHERE worlwide_gross_income is not null and worlwide_gross_income regexp 'INR';

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

select 
    production_company, count(m.id) as movie_count,               
    rank() over (order by count(m.id) desc) as prod_comp_rank 
    from
         movie m 
    join 
        ratings r 
    on
        m.id = r.movie_id       
    where
        median_rating >= 8 and production_company is not null and POSITION(',' IN languages)>0 
    group by 
        production_company      
    limit 2                     
;
                               -- Star Cinema and Twentieth Century Fox are the top 2 production houses that have produced the highest number of hits among multilingual movies





-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT 
    n.name AS actress_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(DISTINCT rm.movie_id) AS movie_count, 
    AVG(r.avg_rating) AS actress_avg_rating,
    RANK() OVER (ORDER BY AVG(r.avg_rating) DESC) AS actress_rank  
FROM 
    names n
JOIN 
    role_mapping rm ON n.id = rm.name_id
JOIN 
    ratings r ON rm.movie_id = r.movie_id
JOIN 
    genre g ON r.movie_id = g.movie_id
WHERE 
    g.genre = 'drama' 
    AND rm.category = 'actress' 
    AND r.avg_rating > 8  
GROUP BY 
    n.name
HAVING 
    COUNT(DISTINCT rm.movie_id) >= 1
ORDER BY 
    actress_rank
LIMIT 3;
                    -- Sangeetha Bhat, Fatmire Sahiti and Adriana Matoshi are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre



/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH director_details AS (
    SELECT 
        dm.name_id AS director_id,
        n.name AS director_name,
        dm.movie_id,
        m.title,
        m.date_published,
        r.avg_rating,
        r.total_votes,
        m.duration        
    FROM 
        director_mapping AS dm
    INNER JOIN 
        names AS n ON dm.name_id = n.id
    INNER JOIN 
        movie AS m ON dm.movie_id = m.id
    INNER JOIN 
        ratings AS r ON dm.movie_id = r.movie_id
),
next_date_published AS (
    SELECT 
        director_id,
        director_name,
        movie_id,
        title,
        date_published,
        avg_rating,
        total_votes,
        duration,
        LEAD(date_published, 1) OVER(PARTITION BY director_id ORDER BY date_published, movie_id) AS next_date_published  
    FROM 
        director_details
),
diff_in_date_published_in_days AS (
    SELECT 
        director_id,
        director_name,
        movie_id,
        title,
        date_published,
        avg_rating,
        total_votes,
        duration,
        next_date_published,
        DATEDIFF(next_date_published, date_published) AS inter_movie_duration 
    FROM 
        next_date_published
),
directors_ranked AS (
    SELECT 
        director_id,
        director_name,
        COUNT(movie_id) AS number_of_movies,
        AVG(inter_movie_duration) AS avg_inter_movie_days,
        AVG(avg_rating) AS avg_rating,
        SUM(total_votes) AS total_votes,
        MIN(avg_rating) AS min_rating,
        MAX(avg_rating) AS max_rating,
        SUM(duration) AS total_duration,
        ROW_NUMBER() OVER (ORDER BY COUNT(movie_id) DESC, AVG(avg_rating) DESC) AS rank_of_director  
    FROM 
        diff_in_date_published_in_days
    GROUP BY 
        director_id,
        director_name
)
SELECT 
    director_id,
    director_name,
    number_of_movies,
    avg_inter_movie_days,
    avg_rating,
    total_votes,
    min_rating,
    max_rating,
    total_duration                                       
FROM 
    directors_ranked
WHERE 
    rank_of_director <= 9;
                                     
 
        





