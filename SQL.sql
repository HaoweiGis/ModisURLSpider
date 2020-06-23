update threenorth_point set name=id;


COPY(
with
a as(
     select * from eco_function where qu1=1
    ),
b as (select t1.id from threenorth_point t1, a t2 where st_intersects(t1.geom,t2.geom))
select * from b)
TO 'H:\muhaowei\1TheGreatGeenWall\Code\eco-function\Node_MCR\1_list.csv'
WITH csv;


with
a as(
     select * from eco_function where qu1=1
    ),
b as (select t1.*,t2.qu1,t2.name3 from threenorth_point t1, a t2 where st_intersects(t1.geom,t2.geom))
select * into eco_function.eco_function1  from b;

with
a as(
     select t1.*,t2.* from threenorth_point t1,eco_function t2 where st_intersects(t1.geom,t2.geom)
    )select a.region_id,a.name3,a.qu1,count(*) from a group by a.region_id,a.name3,a.qu1;

CREATE INDEX geoindex4 ON corrdior_xiao USING GIST (geom);

select t1.*,t2.* from threenorth_point t1,eco_function t2 where st_intersects(t1.geom,st_transform(t2.geom,3857));



b as (select t1.*,t2.qu1,t2.name3 from threenorth_point t1, a t2 where st_intersects(t1.geom,t2.geom))
select * into eco_function.eco_function1  from b;


update corrdior_xiao set arcid=st_length(geom);


with
b as(
     select t.* from threenorth_point t where t.field7 = '县级'
    ),
a as(
     select t1.id as goubid,t1.arcid, t2.* from corridor_da t1,threenorth_point t2 where st_intersects(st_buffer(t1.geom,100000),st_transform(t2.geom,3857))
    )select goubid,count(*)::numeric/arcid::numeric from a group by goubid,arcid;


-- 国家级 省级 市级 县级

select a.region_id,a.name3,a.qu1,count(*) from a group by a.region_id,a.name3,a.qu1;

select * from shabi1;

select t1.*,t2."?column?" as goubi1 from corridor_da t1,goubi3 t2 where t1.id = t2.goubid;


with
a as (select t1.*,t2."?column?" as goubi1 from corrdior_xiao t1 LEFT JOIN shabi1 t2 on t1.id = t2.goubid ),
b as (select t1.*,t2."?column?" as goubi2 from a t1 LEFT JOIN shabi2 t2 on t1.id = t2.goubid),
c as (select t1.*,t2."?column?" as goubi3 from b t1 LEFT JOIN shabi3 t2 on t1.id = t2.goubid),
d as (select t1.*,t2."?column?" as goubi4 from c t1 LEFT JOIN shabi4 t2 on t1.id = t2.goubid) select * into corridor_xiao_new from d;

update corridor_xiao_new set fid_corrid = goubi1*100+goubi2*70+goubi3*50+goubi4*30;

-- 国家级 省级 市级 县级


select *,st_centroid(geom), from "China2017_city";

select count(*) from geo_bigdata."gaode-guangdong" where c8='广州市';



-- 地球科学大数据工程项目相关代码
ALTER TABLE geo_bigdata.china_county ADD COLUMN geom_gcj geometry;
update geo_bigdata.china_county set geom_gcj = citygis_offset_geometry(geom,'wgs','gcj');
with
a as (select * from geo_bigdata.china_county where "市"='兰州市')
,b as (select * from a where name='城关区' or name='七里河区' or name='西固区' or name='安宁区' or name='红古区')
select *,st_transform(geom_gcj,3857) as geom_gcj_3857 into geo_bigdata.lanzhou_center from b;

select t2.*,st_intersection(t1.geom_gcj_3857,t2.geom) as geom_intersection into geo_bigdata.lanzhou_center_road1 from geo_bigdata.lanzhou_center t1,geo_bigdata.lanzhou_road t2 where t2.type!='9' and t2.type!='10' and st_intersects(t1.geom_gcj_3857,t2.geom);
select t2.*,st_intersection(t1.geom_gcj_3857,t2.geom) as geom_intersection into geo_bigdata.lanzhou_center_road2 from geo_bigdata.lanzhou_center t1,geo_bigdata.lanzhou_road t2 where t2.type!='10' and st_intersects(t1.geom_gcj_3857,t2.geom);

select case when type='1' then st_buffer(geom_intersection,30)
    when type='2' then st_buffer(geom_intersection,30)
    when type='3' then st_buffer(geom_intersection,25)
    when type='4' then st_buffer(geom_intersection,25)
    when type='5' then st_buffer(geom_intersection,20)
    when type='6' then st_buffer(geom_intersection,15)
    when type='7' then st_buffer(geom_intersection,10)
    when type='8' then st_buffer(geom_intersection,10)
    when type='9' then st_buffer(geom_intersection,5)
--     when type='10' then st_buffer(geom_intersection,2)
    end as buffer into geo_bigdata.lanzhou_buffer7
from geo_bigdata.lanzhou_center_road;

select

-- ALTER TABLE geo_bigdata.lanzhou_road ADD COLUMN buffer geometry;
-- update geo_bigdata.lanzhou_road set geom_4326 = citygis_offset_geometry(st_transform(geom,4326),'gcj','wgs');
-- update geo_bigdata.lanzhou_road set geom_3857 = st_transform(geom_4326,3857);


select case when type='1' then st_buffer(geom,25)
    when type='2' then st_buffer(geom,25)
    when type='3' then st_buffer(geom,20)
    when type='4' then st_buffer(geom,20)
    when type='5' then st_buffer(geom,20)
    when type='6' then st_buffer(geom,15)
    when type='7' then st_buffer(geom,10)
    when type='8' then st_buffer(geom,6)
    when type='9' then st_buffer(geom,3)
    when type='10' then st_buffer(geom,2)
    end as buffer into geo_bigdata.lanzhou_buffer_gcj
from geo_bigdata.lanzhou_road;

ALTER TABLE geo_bigdata.lanzhou_community ADD COLUMN buffer_gcj geometry;
update geo_bigdata.lanzhou_community set buffer_gcj = citygis_offset_geometry(st_transform(geom,4326),'wgs','gcj')

ALTER TABLE public.lanzhou_phq ADD COLUMN geomgcj geometry;
update public.lanzhou_phq set geomgcj = citygis_offset_geometry(st_transform(geom,4326),'wgs','gcj')


ALTER TABLE geo_bigdata.export_output ADD COLUMN sum numeric;
update geo_bigdata.export_output set sum = value_11+value_12+value_21+value_22+value_23+value_24+value_31+value_32+value_33+value_41+value_42+value_43+value_45
                                               +value_46+value_51+value_52+value_53+value_61+value_62+value_63+value_64+value_65+value_66+value_67+value_99
ALTER TABLE geo_bigdata.export_output ADD COLUMN jumingdian numeric;

update geo_bigdata.export_output set gengdi = (value_11+value_12)/sum;
update geo_bigdata.export_output set jumingdian = (value_52)/sum;



SELECT t1.*,t2.gengdi,t2.chengzheng,t2.jumingdian into geo_bigdata.euluc2018_updata
FROM  geo_bigdata.euluc2018 t1
LEFT OUTER JOIN geo_bigdata.export_output t2
ON t1.uuid = t2.uuid;

select *  into euluc2018_updata_zhuchengqu from geo_bigdata.euluc2018_updata where gengdi<0.1;

select distinct(city_code) from geo_bigdata.euluc2018_updata;



ALTER TABLE public.china_ph ADD COLUMN geomwgs geometry;
update public.china_ph set geomwgs = st_transform(geom,4326);


select fid,value,geomwgs,name into china_ph_goubi from china_ph;
select distinct(name) from china_ph_goubi;

select name,sum(sum) as pop,sum(area) as area,sum(sum)/sum(area) as ratio into china_phindex_pop from  "china_phindexNew" group by name;


with
a as (select  t1.name as dictname,t2.*,t1.name|| t2.name as newname from china_county t1, "china_phindexNew" t2 where st_intersects(t1.geom,st_transform(t2.geom,4326))),
b as (select t2.* as goubi3 from "china_phindexNew" t1 LEFT JOIN a t2 on t1.fid = t2.fid)
select * into china_phq_dist from b;




create index idx_gis_idx_test on gis_idx_test using brin (pos) with (pages_per_range =1);

select dictname,newname,name,sum(sum) as pop,sum(area) as area,sum(sum)/sum(area) as ratio into china_phq_dist_pop from china_phq_dist group by newname,name,dictname ;

select t1.*,t2.sum as pop,st_area(st_transform(t1.geom,3827)) as area into china_zhuchengqu_pop from euluc2018_updata_zhuchengqu t1 LEFT JOIN zhuchengqu_stats t2 on t1.uuid = t2.uuid;

select city_code,sum(pop) as pop,sum(area) as area into china_city_zhuchengqu_pop from china_zhuchengqu_pop group by city_code ;


select t2.* from shenghui t1 LEFT JOIN china_city_zhuchengqu_pop t2 on t1.c1 = t2.city_code;

select name,city_code,sum(sum) as pop,sum(st_area(st_transform(geom,3857))) as area,sum(sum)/sum(st_area(st_transform(geom,3857))) as ratio from china_intersect_update group by name,city_code;
