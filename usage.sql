DECLARE @pattern NVARCHAR(4000);
SET @pattern = '(?x)^Ar .*? \bken\b .*';

-- simple SELECT that the LIKE operator cannot handle;
-- regular expressions are case-sensitive by default
SELECT * FROM ImdbMovies.dbo.movies
WHERE ImdbMovies.dbo.RegexMatch(title, @pattern)=1;
-- test before UPDATE
SELECT ImdbMovies.dbo.RegexReplace(
    title, '\b(ken)\b', '__XXX__${1}'
)
FROM ImdbMovies.dbo.movies
WHERE ImdbMovies.dbo.RegexMatch(title, @pattern)=1;

-- LIKE operator not case-sensitive, no 'word boundary', and no capture grouping
SELECT * FROM ImdbMovies.dbo.movies
WHERE title like 'ar%ken%'