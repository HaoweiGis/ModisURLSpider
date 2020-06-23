CREATE FUNCTION citygis_offset_geometry(geom geometry, origin text, destination text) returns geometry
LANGUAGE plpgsql
AS $$
DECLARE
 result geometry;
 type text;
BEGIN
 IF geom is null THEN
  return null;
 END IF;
 IF ST_SRID(geom) NOT IN (0, 4326) THEN
  RETURN geom;
 END IF;
 IF origin not in ('wgs', 'gcj', 'bd') or destination not in('wgs', 'gcj', 'bd') THEN
  return geom;
 END IF;
 IF origin = destination THEN
  return geom;
 END IF;
 type := GeometryType(geom);
 IF type = 'POINT' THEN
  result := citygis_offset_point(geom, origin, destination);
 ELSIF type = 'LINESTRING' THEN
  result := citygis_offset_linestring(geom, origin, destination);
 ELSIF type = 'POLYGON' THEN
  result := citygis_offset_polygon(geom, origin, destination);
 ELSIF type in ('GEOMETRYCOLLECTION', 'MULTIPOINT', 'MULTILINESTRING', 'MULTIPOLYGON') THEN
  result := citygis_offset_collection(geom, origin, destination);
 ELSE
  result := geom;
 END IF;
 return ST_SetSRID(result, 4326);
END;
$$;

CREATE FUNCTION citygis_offset_point(geom geometry, origin text, destination text) returns geometry
LANGUAGE plpgsql
AS $$
DECLARE
 pt POINT;
 x double precision;
 y double precision;
BEGIN
 IF geom is null THEN
  return null;
 END IF;
 IF GeometryType(geom) <> 'POINT' THEN
  return geom;
 END IF;
 IF origin not in ('wgs', 'gcj', 'bd') or destination not in('wgs', 'gcj', 'bd') THEN
  return geom;
 END IF;
 IF origin = destination THEN
  return geom;
 END IF;
 x = st_x(geom);
 y = st_y(geom);
 IF origin = 'wgs' and destination = 'gcj' THEN
  pt = citygis_wgs2gcj(x, y);
 elsIF origin = 'wgs' and destination = 'bd' THEN
  pt = citygis_wgs2bd(x, y);
 elsIF origin = 'gcj' and destination = 'wgs' THEN
  pt = citygis_gcj2wgs(x,y);
 elsIF origin ='gcj' and destination = 'bd' THEN
  pt = citygis_gcj2bd(x, y);
 elsIF origin = 'bd' and destination = 'wgs' THEN
  pt = citygis_bd2wgs(x, y);
 elsIF origin = 'bd' and destination = 'gcj' THEN
  pt = citygis_bd2gcj(x, y);
 END IF;
 return st_makePoint(pt[0], pt[1]);
END;
$$;

CREATE FUNCTION citygis_wgs2gcj(wgslon double precision, wgslat double precision) returns point
LANGUAGE plpgsql
AS $$
DECLARE
 dLat double precision;
 dLon double precision;
 a double precision := 6378245.0;
 f double precision := 0.00335233;
 b double precision;
 ee double precision;
 radLat double precision;
 magic double precision;
 sqrtMagic double precision;
 gcjLat double precision;
 gcjLon double precision;
BEGIN
 IF citygis_outofchina(wgsLon, wgsLat) THEN
  return point (wgsLon, wgsLat);
 END IF;
 b := a * (1 - f);
 ee := (a * a - b * b) / (a * a);
 dLat := citygis_transformLat(wgsLon - 105.0, wgsLat - 35.0);
 dLon := citygis_transformLon(wgsLon - 105.0, wgsLat - 35.0);
 radLat := wgsLat / 180.0 * PI();
 magic := sin(radLat);
 magic := 1 - ee * magic * magic;
 sqrtMagic := sqrt(magic);
 dLat := (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * PI());
 dLon := (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * PI());
 gcjLat := wgsLat + dLat;
 gcjLon := wgsLon + dLon;
 return point(gcjLon, gcjLat);
END;
$$;



CREATE FUNCTION citygis_gcj2bd(gcjlon double precision, gcjlat double precision) returns point
LANGUAGE plpgsql
AS $$
DECLARE
 z double precision;
 theta double precision;
 bdLon double precision;
 bdLat double precision;
BEGIN
  z := sqrt(gcjLon * gcjLon + gcjLat * gcjLat) + 0.00002 * sin(gcjLat * PI() * 3000.0 / 180.0);
  theta := atan2(gcjLat, gcjLon) + 0.000003 * cos(gcjLon * PI() * 3000.0 / 180.0);
  bdLon = z * cos(theta) + 0.0065;
  bdLat = z * sin(theta) + 0.006;
  return point(bdLon, bdLat);
END;
$$;



CREATE FUNCTION citygis_gcj2wgs(gcjlon double precision, gcjlat double precision) returns point
LANGUAGE plpgsql
AS $$
DECLARE
    g0 point;
    w0 point;
    g1 point;
    w1 point;
    delta point;
BEGIN
  g0 := point(gcjLon, gcjLat);
  w0 := g0;
  g1 := citygis_wgs2gcj(w0[0], w0[1]);
  w1 := w0 - (g1 - g0);
  delta := w1 - w0;
  WHILE (abs(delta[0]) >= 1e-6 or abs(delta[1]) >= 1e-6) LOOP
    w0 := w1;
    g1 := citygis_wgs2gcj(w0[0], w0[1]);
    w1 := w0 - (g1 - g0);
    delta := w1 - w0;
  end LOOP;
  return w1;
END;
$$;

CREATE FUNCTION citygis_bd2wgs(bdlon double precision, bdlat double precision) returns point
LANGUAGE plpgsql
AS $$
DECLARE
 gcj point;
BEGIN
 gcj := citygis_bd2gcj(bdLon, bdLat);
 return citygis_gcj2wgs(gcj[0], gcj[1]);
END;
$$;

CREATE FUNCTION citygis_bd2gcj(bdlon double precision, bdlat double precision) returns point
LANGUAGE plpgsql
AS $$
DECLARE
  x double precision;
  y double precision;
  z double precision;
  theta double precision;
  gcjLon double precision;
  gcjLat double precision;
BEGIN
  x := bdLon - 0.0065;
  y := bdLat - 0.006;
  z := sqrt(x * x + y * y) - 0.00002 * sin(y * pi() * 3000.0 / 180.0);
  theta := atan2(y, x) - 0.000003 * cos(x * pi() * 3000.0 / 180.0);
  gcjLon := z * cos(theta);
  gcjLat := z * sin(theta);
  return point(gcjLon, gcjLat);
END;
$$;

CREATE FUNCTION citygis_offset_linestring(geom geometry, origin text, destination text) returns geometry
LANGUAGE plpgsql
AS $$
DECLARE
 vertex geometry;
 rowPoint RECORD;
 dump geometry_dump;
 result geometry[];
 i int := 1;
BEGIN
 IF geom is null THEN
  return null;
 END IF;
 IF GeometryType(geom) <> 'LINESTRING' THEN
  RETURN geom;
 END IF;
 IF origin not in ('wgs', 'gcj', 'bd') or destination not in('wgs', 'gcj', 'bd') THEN
  return geom;
 END IF;
 IF origin = destination THEN
  return geom;
 END IF;
 result := array_fill(null::geometry, ARRAY[ST_NumPoints(geom)]);
 FOR rowPoint in SELECT ST_DumpPoints(geom) as f LOOP
  dump := rowPoint.f;
  vertex := citygis_offset_point((dump).geom, origin, destination);
  result[i] := vertex;
  i := i + 1;
 end LOOP;
 return st_MakeLine(result);
END;
$$;


CREATE FUNCTION citygis_offset_polygon(geom geometry, origin text, destination text) returns geometry
LANGUAGE plpgsql
AS $$
DECLARE
 outerRing geometry;
 ring geometry;
 innerRings geometry[];
 i int := 1;
 n int;
BEGIN
 IF geom is null THEN
  return null;
 END IF;
 IF GeometryType(geom) <> 'POLYGON' THEN
  RETURN geom;
 END IF;
 IF origin not in ('wgs', 'gcj', 'bd') or destination not in('wgs', 'gcj', 'bd') THEN
  return geom;
 END IF;
 IF origin = destination THEN
  return geom;
 END IF;
 outerRing := citygis_offset_linestring(st_exteriorRing(geom), origin, destination);
 n := ST_NumInteriorRings(geom);
 innerRings := array_fill(null::geometry, ARRAY[n]);
 for i in 1..n LOOP
  ring := st_InteriorRingN(geom, i);
  ring := citygis_offset_linestring(ring, origin, destination);
  innerRings[i] := ring;
 end LOOP;
 return st_MakePolygon(outerRing, innerRings);
END;
$$;


CREATE FUNCTION citygis_offset_collection(geom geometry, origin text, destination text) returns geometry
LANGUAGE plpgsql
AS $$
DECLARE
 n int;
 i int;
 child geometry;
 type text;
 result geometry[];
BEGIN
 n := st_NumGeometries(geom);
 result := array_fill(null::geometry, ARRAY[n]);
 for i in 1..n LOOP
  child := st_GeometryN(geom, i);
  type := GeometryType(child);
  IF type = 'POINT' THEN
   child := citygis_offset_point(child, origin, destination);
  ELSIF type = 'LINESTRING' THEN
   child := citygis_offset_linestring(child, origin, destination);
  ELSIF type = 'POLYGON' THEN
   child := citygis_offset_polygon(child, origin, destination);
  ELSIF type in ('GEOMETRYCOLLECTION', 'MULTIPOINT', 'MULTILINESTRING', 'MULTIPOLYGON') THEN
   child := citygis_offset_collection(child, origin, destination);
  ELSE
   RAISE NOTICE 'UNKNOWN %', type;
  END IF;
  result[i] := child;
 end LOOP;
 return st_collect(result);
END;
$$;

CREATE FUNCTION citygis_outofchina(lon double precision, lat double precision) returns boolean
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
	IF lon < 72.004 or lon > 137.8347 THEN
		return TRUE;
	END IF;
	IF lat < 0.8293 OR lat > 55.8271 THEN
		return TRUE;
	END IF;
	RETURN FALSE;
END;
$$;

CREATE FUNCTION citygis_transformlat(x double precision, y double precision) returns double precision
LANGUAGE plpgsql
AS $$
DECLARE
	ret double precision;
BEGIN
  ret := -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
  ret := ret + (20.0 * sin(6.0 * x * PI()) + 20.0 * sin(2.0 * x * PI())) * 2.0 / 3.0;
  ret := ret + (20.0 * sin(y * PI()) + 40.0 * sin(y / 3.0 * PI())) * 2.0 / 3.0;
  ret := ret + (160.0 * sin(y / 12.0 * PI()) + 320.0 * sin(y * PI() / 30.0)) * 2.0 / 3.0;
  return ret;
END;
$$;

CREATE FUNCTION citygis_transformlon(x double precision, y double precision) returns double precision
LANGUAGE plpgsql
AS $$
DECLARE
	ret double precision;
BEGIN
  ret := 300.0 + x + 2.0 * y + 0.1 * x * x +  0.1 * x * y + 0.1 * sqrt(abs(x));
  ret := ret + (20.0 * sin(6.0 * x * PI()) + 20.0 * sin(2.0 * x * PI())) * 2.0 / 3.0;
  ret := ret + (20.0 * sin(x * PI()) + 40.0 * sin(x / 3.0 * PI())) * 2.0 / 3.0;
  ret := ret + (150.0 * sin(x / 12.0 * PI()) + 300.0 * sin(x * PI() / 30.0)) * 2.0 / 3.0;
  return ret;
END;
$$;



-- UPDATE public.township_lanzhou
-- SET the_geometry_gcj=citygis_offset_geometry(geom,'gcj','wgs');