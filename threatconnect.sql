ALTER USER postgres WITH PASSWORD 'insecure';
CREATE USER tcuser WITH PASSWORD 'insecure';
CREATE DATABASE threatconnect WITH OWNER tcuser ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';
GRANT ALL PRIVILEGES ON DATABASE threatconnect TO tcuser;
\c threatconnect
ALTER TYPE text OWNER to tcuser;
ALTER TYPE bool OWNER to tcuser;

CREATE FUNCTION public.boolean1(i smallint) RETURNS boolean
  LANGUAGE sql IMMUTABLE STRICT
  AS $$SELECT (i::smallint)::int::bool;$$;

CREATE FUNCTION public.inttobool(val boolean, num integer) RETURNS boolean
  LANGUAGE plpgsql
  AS $$
begin
  return public.inttobool(num,val);
end;
$$;

CREATE FUNCTION public.inttobool(num integer, val boolean) RETURNS boolean
  LANGUAGE plpgsql
  AS $$
begin
if num=0 and not val then
  return true;
elsif num=1 and val then
  return true;
else return false;
end if;
end;
$$;

CREATE FUNCTION public.notinttobool(val boolean, num integer) RETURNS boolean
  LANGUAGE plpgsql
  AS $$
begin
  return not public.inttobool(num,val);
end;
$$;

CREATE FUNCTION public.notinttobool(num integer, val boolean) RETURNS boolean
  LANGUAGE plpgsql
  AS $$
begin
  return not public.inttobool(num,val);
end;
$$;


CREATE FUNCTION public.text(date) RETURNS text
  LANGUAGE sql IMMUTABLE STRICT
  AS $_$SELECT textin(date_out($1));$_$;

CREATE FUNCTION public.text(smallint) RETURNS text
  LANGUAGE sql IMMUTABLE STRICT
  AS $_$SELECT textin(int2out($1));$_$;

CREATE FUNCTION public.text(integer) RETURNS text
  LANGUAGE sql IMMUTABLE STRICT
  AS $_$SELECT textin(int4out($1));$_$;

CREATE FUNCTION public.text(oid) RETURNS text
  LANGUAGE sql IMMUTABLE STRICT
  AS $_$SELECT textin(oidout($1));$_$;

CREATE CAST (date AS text) WITH FUNCTION public.text(date) AS IMPLICIT;

CREATE CAST (smallint AS boolean) WITH FUNCTION public.boolean1(smallint) AS IMPLICIT;

CREATE CAST (smallint AS text) WITH FUNCTION public.text(smallint) AS IMPLICIT;

CREATE CAST (integer AS text) WITH FUNCTION public.text(integer) AS IMPLICIT;

CREATE CAST (oid AS text) WITH FUNCTION public.text(oid) AS IMPLICIT;

