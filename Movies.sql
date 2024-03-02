-- 1. What are the 10 top-rated movies that received more than 50000 votes?

SELECT title, rating, nvotes
FROM Movies
WHERE nvotes > 50000
ORDER BY rating DESC, title
LIMIT 10

-- 2. Which actor has the highest average rating in movies that they're known for? 

-- create a view for actors have been known for in rated movies
CREATE VIEW ActorsInRatedMovies AS
SELECT p.person_id, p.movie_id, m.rating, p.role
FROM Principals p
JOIN Movies m ON m.id = p.movie_id
JOIN Known_for k ON (k.movie_id = m.id AND k.person_id = p.person_id)
WHERE  p.role = 'actor';

-- create a shortlist for actors in least 2 rated movies
CREATE VIEW ShortList AS
SELECT person_id, count(role)
FROM ActorsInRatedMovies
GROUP BY person_id
HAVING count(role) >=2;

CREATE VIEW ActorsWithRating AS
SELECT p.name, avg(a.rating) ::numeric(5,2) AS avg_rating
FROM ShortList s 
JOIN ActorsInRatedMovies a ON a.person_id = s.person_id
JOIN People p ON p.id = s.person_id
GROUP BY p.name
ORDER BY avg(a.rating) ::numeric(5,2) DESC;

SELECT name
FROM ActorsWithRating
WHERE avg_rating = (SELECT max(avg_rating) FROM ActorsWithRating);

-- 3. For each movie with at least 3 genres, show the movie title and a comma-separated list of the genres.

CREATE VIEW ShortedListMovies AS
SELECT movie_id, string_agg(genre, ',' ORDER BY genre) AS genres_combined
FROM Movie_genres
WHERE genre != 'documentary' AND genre != 'biography'
GROUP BY movie_id
HAVING count(genre) >=3
;

SELECT m.title AS title, s.genres_combined AS genres
FROM ShortedListMovies s
JOIN Movies m ON m.id = s.movie_id
ORDER BY m.title;

-- 4. Which people are noted as being principal actors in a movie, but aren't noted as playing a character in that movie?

-- create view for principal actors
CREATE VIEW Actors AS
SELECT movie_id, person_id
FROM Principals
WHERE role = 'actor';

-- create view for actors with characters
CREATE VIEW ActorsCharacters AS
SELECT a.movie_id, a.person_id, p.character
FROM Actors a
LEFT JOIN Plays p ON (a.movie_id = p.movie_id AND a.person_id = p.person_id);


SELECT pe.name AS actor, m.title AS movie
FROM ActorsCharacters a
JOIN People pe ON pe.id = a.person_id
JOIN Movies m ON m.id = a.movie_id
WHERE a.character IS NULL
ORDER BY pe.name
;

-- 5. Who was the youngest male to have a principal acting role in a movie, and how old were they when the movie was made?

-- create view for principal actors (male)
CREATE VIEW Actors AS
SELECT movie_id, person_id
FROM Principals
WHERE role = 'actor';

-- create view for actors with year born and year when the movie was made
CREATE VIEW ActorsWithAge AS
SELECT a.movie_id, a.person_id, p.name, m.year_made, p.year_born, m.year_made - p.year_born AS age
FROM Actors a
JOIN Movies m ON m.id = a.movie_id
JOIN People p ON p.id = a.person_id;

SELECT name, age
FROM ActorsWithAge
WHERE age = (SELECT min(age) FROM ActorsWithAge)
ORDER BY name;

-- 6. Which actors/actresses played only in movies that rated 8.5 or higher?

-- create view for short list actor/actress
CREATE VIEW ShortList AS 
SELECT person_id, count(role)
FROM Principals
WHERE role = 'actor' OR role = 'actress'
GROUP BY person_id
HAVING count(role) >=3;

CREATE VIEW ShortListWithRating AS
SELECT s.person_id, p.movie_id, m.rating
FROM ShortList s
JOIN Principals p ON p.person_id = s.person_id
JOIN Movies m ON m.id = p.movie_id;

CREATE VIEW PersonID AS
SELECT person_id
FROM ShortListWithRating
GROUP BY person_id
HAVING min(rating) >=8.5;

SELECT pe.name
FROM PersonID p
JOIN People pe ON pe.id = p.person_id;






