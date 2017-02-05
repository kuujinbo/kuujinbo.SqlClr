BULK
INSERT movies
FROM 'D:\downloads\imdb\movies.txt'
WITH
(
   ROWTERMINATOR = '\n'
)
GO


DECLARE @pattern NVARCHAR(4000);
SET @pattern = '(?ix)^Ar.*?\bken\b.*';

-- simple SELECT that the LIKE operator cannot handle
select * from movies
where dbo.RegexMatch(title, @pattern)=1;
-- test before UPDATE
select dbo.RegexReplace(
    title, '^', '__XXX__'
)
from movies
where dbo.RegexMatch(title, @pattern)=1;


--update Customers
--set Region=dbo.RegexReplace(
--    Region, '^', '_'
--);
--select Region from Customers;

--update Customers
--set Region=dbo.RegexReplace(
--    Region, '^_', ''
--);
--select Region from Customers;


select * from movies
where title like 'Ar%ken%'